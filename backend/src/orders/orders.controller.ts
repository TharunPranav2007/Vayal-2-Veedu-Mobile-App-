import { Controller, Get, Post, Patch, Param, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { OrdersService, CreateOrderDto } from './orders.service';
import { OrderStatus } from '@prisma/client';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser, AuthenticatedUser } from '../common/decorators/current-user.decorator';
import { Role } from '@prisma/client';

class UpdateOrderStatusDto {
  status: OrderStatus;
  note?: string;
}

@ApiTags('Orders Lifecycle')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  @Roles(Role.CONSUMER, Role.ADMIN)
  @ApiOperation({ summary: 'Place a new direct order with server-side consumer binding & stock locking' })
  @ApiResponse({ status: 201, description: 'Order created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Only Consumers or Admins can place orders' })
  async create(@CurrentUser() user: AuthenticatedUser, @Body() dto: CreateOrderDto) {
    return this.ordersService.createOrder(user, dto);
  }

  @Get()
  @Roles(Role.CONSUMER, Role.FARMER, Role.DELIVERY_PARTNER, Role.ADMIN)
  @ApiOperation({ summary: 'Get orders scoped to the authenticated user profile' })
  @ApiResponse({ status: 200, description: 'User orders retrieved successfully' })
  async findAll(@CurrentUser() user: AuthenticatedUser) {
    return this.ordersService.findAllForUser(user);
  }

  @Get(':id')
  @Roles(Role.CONSUMER, Role.FARMER, Role.DELIVERY_PARTNER, Role.ADMIN)
  @ApiOperation({ summary: 'Get single order details with IDOR ownership validation' })
  @ApiResponse({ status: 200, description: 'Order details' })
  @ApiResponse({ status: 403, description: 'Forbidden - User is not a participant in this order' })
  @ApiResponse({ status: 404, description: 'Order not found' })
  async findOne(@Param('id') id: string, @CurrentUser() user: AuthenticatedUser) {
    return this.ordersService.findOneForUser(id, user);
  }

  @Patch(':id/status')
  @Roles(Role.FARMER, Role.DELIVERY_PARTNER, Role.CONSUMER, Role.ADMIN)
  @ApiOperation({ summary: 'Transition order status with role & ownership enforcement' })
  @ApiResponse({ status: 200, description: 'Order status updated' })
  @ApiResponse({ status: 400, description: 'Invalid status transition for role' })
  @ApiResponse({ status: 403, description: 'Forbidden - User does not own/manage this order' })
  async updateStatus(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateOrderStatusDto,
  ) {
    return this.ordersService.updateStatus(id, user, dto.status, dto.note);
  }
}
