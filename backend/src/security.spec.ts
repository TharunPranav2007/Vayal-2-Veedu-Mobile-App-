import { Test, TestingModule } from '@nestjs/testing';
import { Reflector } from '@nestjs/core';
import { ExecutionContext, UnauthorizedException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { RolesGuard } from './common/guards/roles.guard';
import { ProductsService } from './products/products.service';
import { OrdersService } from './orders/orders.service';
import { DeliveriesService } from './deliveries/deliveries.service';
import { PrismaService } from './prisma/prisma.service';
import { Role, OrderStatus, DeliveryStatus } from '@prisma/client';
import { AuthenticatedUser } from './common/decorators/current-user.decorator';

describe('Phase 1 Security & Authorization Test Suite', () => {
  let rolesGuard: RolesGuard;
  let jwtAuthGuard: JwtAuthGuard;
  let reflector: Reflector;

  let productsService: ProductsService;
  let ordersService: OrdersService;
  let deliveriesService: DeliveriesService;

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
    },
    farmerProfile: {
      findUnique: jest.fn(),
    },
    consumerProfile: {
      findUnique: jest.fn(),
    },
    deliveryProfile: {
      findUnique: jest.fn(),
    },
    product: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    order: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    delivery: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
    },
  };

  beforeEach(async () => {
    reflector = new Reflector();
    rolesGuard = new RolesGuard(reflector);
    jwtAuthGuard = new JwtAuthGuard(reflector);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProductsService,
        OrdersService,
        DeliveriesService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    productsService = module.get<ProductsService>(ProductsService);
    ordersService = module.get<OrdersService>(OrdersService);
    deliveriesService = module.get<DeliveriesService>(DeliveriesService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  function createMockContext(user: any): ExecutionContext {
    return {
      getHandler: () => ({}),
      getClass: () => ({}),
      switchToHttp: () => ({
        getRequest: () => ({
          user,
          headers: user ? { authorization: 'Bearer test-token' } : {},
        }),
      }),
    } as any;
  }

  // ============================================================
  // TEST 1: Unauthenticated user -> protected endpoint -> 401
  // ============================================================
  it('TEST 1: Unauthenticated user attempting protected route fails authentication with 401 Unauthorized', async () => {
    const unauthenticatedContext = createMockContext(null);
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(false); // Not marked @Public()

    // Mock Passport AuthGuard behavior on unauthenticated request
    jest.spyOn(jwtAuthGuard, 'canActivate').mockImplementation(async (context) => {
      const isPublic = reflector.getAllAndOverride<boolean>('isPublic', [
        context.getHandler(),
        context.getClass(),
      ]);
      if (isPublic) return true;
      const req = context.switchToHttp().getRequest();
      if (!req.user) {
        throw new UnauthorizedException('Missing or invalid JWT authentication token.');
      }
      return true;
    });

    await expect(jwtAuthGuard.canActivate(unauthenticatedContext)).rejects.toThrow(
      UnauthorizedException,
    );
  });

  // ============================================================
  // TEST 2: Authenticated CONSUMER -> FARMER-only endpoint -> 403
  // ============================================================
  it('TEST 2: Authenticated CONSUMER calling FARMER-only endpoint returns 403 Forbidden', () => {
    const consumerUser: AuthenticatedUser = {
      id: 'consumer-user-1',
      email: 'consumer@test.com',
      role: Role.CONSUMER,
    };

    const context = createMockContext(consumerUser);
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([Role.FARMER, Role.ADMIN]); // Endpoint requires FARMER or ADMIN

    const isAllowed = rolesGuard.canActivate(context);
    expect(isAllowed).toBe(false);
  });

  // ============================================================
  // TEST 3: FARMER A -> modify FARMER B's product -> 403
  // ============================================================
  it('TEST 3: FARMER A modifying FARMER B product throws 403 Forbidden (IDOR Protection)', async () => {
    const farmerA: AuthenticatedUser = {
      id: 'farmer-a-user-id',
      email: 'farmerA@test.com',
      role: Role.FARMER,
      farmerProfileId: 'farmer-a-profile-id',
    };

    mockPrismaService.product.findUnique.mockResolvedValue({
      id: 'product-b-id',
      name: 'Organic Tomatoes',
      farmer: {
        userId: 'farmer-b-user-id', // Product belongs to FARMER B
      },
    });

    await expect(
      productsService.update('product-b-id', farmerA, { name: 'Hacked Tomatoes' }),
    ).rejects.toThrow(ForbiddenException);
  });

  // ============================================================
  // TEST 4: CONSUMER A -> access CONSUMER B's order -> 403
  // ============================================================
  it('TEST 4: CONSUMER A inspecting CONSUMER B order throws 403 Forbidden (IDOR Protection)', async () => {
    const consumerA: AuthenticatedUser = {
      id: 'consumer-a-user-id',
      email: 'consumerA@test.com',
      role: Role.CONSUMER,
      consumerProfileId: 'consumer-a-profile-id',
    };

    mockPrismaService.order.findUnique.mockResolvedValue({
      id: 'order-b-id',
      orderNumber: 'ORD-123456',
      consumer: { userId: 'consumer-b-user-id' }, // Order belongs to CONSUMER B
      farmer: { userId: 'farmer-x-user-id' },
      delivery: null,
    });

    await expect(ordersService.findOneForUser('order-b-id', consumerA)).rejects.toThrow(
      ForbiddenException,
    );
  });

  // ============================================================
  // TEST 5: DELIVERY_PARTNER A -> access unrelated delivery -> 403
  // ============================================================
  it('TEST 5: DELIVERY_PARTNER A modifying DELIVERY_PARTNER B delivery throws 403 Forbidden', async () => {
    const deliveryPartnerA: AuthenticatedUser = {
      id: 'dp-a-user-id',
      email: 'dpa@test.com',
      role: Role.DELIVERY_PARTNER,
      deliveryProfileId: 'dp-a-profile-id',
    };

    mockPrismaService.delivery.findUnique.mockResolvedValue({
      id: 'delivery-b-id',
      deliveryPartner: {
        userId: 'dp-b-user-id', // Delivery belongs to DELIVERY PARTNER B
      },
    });

    await expect(
      deliveriesService.updateDeliveryStatus('delivery-b-id', deliveryPartnerA, DeliveryStatus.DELIVERED),
    ).rejects.toThrow(ForbiddenException);
  });

  // ============================================================
  // TEST 6: Normal user -> ADMIN endpoint -> 403
  // ============================================================
  it('TEST 6: Normal CONSUMER user calling ADMIN-only endpoint returns false / 403', () => {
    const consumerUser: AuthenticatedUser = {
      id: 'consumer-user-1',
      email: 'consumer@test.com',
      role: Role.CONSUMER,
    };

    const context = createMockContext(consumerUser);
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([Role.ADMIN]); // ADMIN-only endpoint

    const isAllowed = rolesGuard.canActivate(context);
    expect(isAllowed).toBe(false);
  });

  // ============================================================
  // TEST 7: Valid owner -> own resource -> success
  // ============================================================
  it('TEST 7: Valid FARMER owner updating own product succeeds', async () => {
    const farmerA: AuthenticatedUser = {
      id: 'farmer-a-user-id',
      email: 'farmerA@test.com',
      role: Role.FARMER,
      farmerProfileId: 'farmer-a-profile-id',
    };

    mockPrismaService.product.findUnique.mockResolvedValue({
      id: 'product-a-id',
      name: 'Organic Apples',
      farmer: {
        userId: 'farmer-a-user-id', // Belongs to FARMER A
      },
    });

    mockPrismaService.product.update.mockResolvedValue({
      id: 'product-a-id',
      name: 'Fresh Organic Apples',
      price: 120,
    });

    const result = await productsService.update('product-a-id', farmerA, { name: 'Fresh Organic Apples' });

    expect(result.success).toBe(true);
    expect(result.data.name).toBe('Fresh Organic Apples');
  });
});
