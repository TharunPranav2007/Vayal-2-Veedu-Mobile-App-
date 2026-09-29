import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { OrderStatus, PaymentMethod, PaymentStatus, Role } from '@prisma/client';
import { AuthenticatedUser } from '../common/decorators/current-user.decorator';

export interface CreateOrderDto {
  farmerId: string;
  addressId: string;
  items: { productId: string; quantity: number }[];
  paymentMethod: PaymentMethod;
}

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async createOrder(user: AuthenticatedUser, dto: CreateOrderDto) {
    if (!dto.items || dto.items.length === 0) {
      throw new BadRequestException('Cannot place an empty order.');
    }

    let consumerProfileId = user.consumerProfileId;

    if (!consumerProfileId) {
      const consumerProfile = await this.prisma.consumerProfile.findUnique({
        where: { userId: user.id },
      });
      if (!consumerProfile) {
        throw new ForbiddenException('User is not registered as a consumer.');
      }
      consumerProfileId = consumerProfile.id;
    }

    // Execute in a database transaction with stock validation and locking
    return this.prisma.$transaction(async (tx) => {
      let subtotal = 0;
      const orderItemsData = [];

      for (const item of dto.items) {
        const product = await tx.product.findUnique({
          where: { id: item.productId },
        });

        if (!product || !product.isPublished) {
          throw new NotFoundException(`Product ${item.productId} is not available.`);
        }

        const requestedQty = item.quantity;
        const availableStock = Number(product.stock);

        if (availableStock < requestedQty) {
          throw new BadRequestException(`Insufficient stock for ${product.name}. Available: ${availableStock} ${product.unit}`);
        }

        // Deduct inventory stock
        await tx.product.update({
          where: { id: product.id },
          data: {
            stock: { decrement: requestedQty },
          },
        });

        const unitPrice = Number(product.price);
        const totalPrice = unitPrice * requestedQty;
        subtotal += totalPrice;

        orderItemsData.push({
          productId: product.id,
          productName: product.name,
          unitPrice,
          quantity: requestedQty,
          totalPrice,
        });
      }

      const deliveryFee = 30.0;
      const totalAmount = subtotal + deliveryFee;
      const orderNumber = `ORD-${Date.now().toString().slice(-6)}`;

      const order = await tx.order.create({
        data: {
          orderNumber,
          consumerId: consumerProfileId,
          farmerId: dto.farmerId,
          addressId: dto.addressId,
          subtotal,
          deliveryFee,
          totalAmount,
          status: OrderStatus.PLACED,
          items: {
            create: orderItemsData,
          },
          payment: {
            create: {
              method: dto.paymentMethod,
              status: dto.paymentMethod === PaymentMethod.CASH_ON_DELIVERY ? PaymentStatus.PENDING : PaymentStatus.SUCCESS,
              amount: totalAmount,
            },
          },
          statusHistory: {
            create: {
              status: OrderStatus.PLACED,
              note: 'Order placed by consumer',
              changedBy: user.id,
            },
          },
        },
        include: {
          items: true,
          payment: true,
          consumer: { select: { id: true, userId: true } },
          farmer: { select: { id: true, farmName: true, userId: true } },
        },
      });

      return {
        success: true,
        message: 'Order created successfully',
        data: order,
      };
    });
  }

  async findAllForUser(user: AuthenticatedUser) {
    let where: any = {};

    if (user.role === Role.CONSUMER) {
      let consumerProfileId = user.consumerProfileId;
      if (!consumerProfileId) {
        const cp = await this.prisma.consumerProfile.findUnique({ where: { userId: user.id } });
        consumerProfileId = cp?.id;
      }
      if (!consumerProfileId) return { success: true, data: [] };
      where.consumerId = consumerProfileId;
    } else if (user.role === Role.FARMER) {
      let farmerProfileId = user.farmerProfileId;
      if (!farmerProfileId) {
        const fp = await this.prisma.farmerProfile.findUnique({ where: { userId: user.id } });
        farmerProfileId = fp?.id;
      }
      if (!farmerProfileId) return { success: true, data: [] };
      where.farmerId = farmerProfileId;
    } else if (user.role === Role.DELIVERY_PARTNER) {
      let deliveryProfileId = user.deliveryProfileId;
      if (!deliveryProfileId) {
        const dp = await this.prisma.deliveryProfile.findUnique({ where: { userId: user.id } });
        deliveryProfileId = dp?.id;
      }
      if (!deliveryProfileId) return { success: true, data: [] };
      where.delivery = { deliveryPartnerId: deliveryProfileId };
    } else if (user.role !== Role.ADMIN) {
      throw new ForbiddenException('Invalid role for accessing orders.');
    }

    const orders = await this.prisma.order.findMany({
      where,
      include: {
        items: true,
        payment: true,
        delivery: true,
        consumer: { select: { id: true, user: { select: { name: true, phone: true } } } },
        farmer: { select: { id: true, farmName: true, user: { select: { name: true, phone: true } } } },
      },
      orderBy: { createdAt: 'desc' },
    });

    return {
      success: true,
      data: orders,
    };
  }

  async findOneForUser(orderId: string, user: AuthenticatedUser) {
    const order = await this.prisma.order.findUnique({
      where: { id: orderId },
      include: {
        items: true,
        payment: true,
        delivery: { include: { deliveryPartner: { select: { id: true, userId: true } } } },
        statusHistory: { orderBy: { createdAt: 'desc' } },
        consumer: { select: { id: true, userId: true, user: { select: { name: true, phone: true, email: true } } } },
        farmer: { select: { id: true, userId: true, farmName: true, user: { select: { name: true, phone: true } } } },
        deliveryAddress: true,
      },
    });

    if (!order) {
      throw new NotFoundException(`Order with ID ${orderId} not found.`);
    }

    // IDOR Protection: User must be related to the order (Consumer, Farmer, Delivery Partner, or Admin)
    const isConsumerOwner = order.consumer.userId === user.id;
    const isFarmerOwner = order.farmer.userId === user.id;
    const isDeliveryOwner = order.delivery?.deliveryPartner?.userId === user.id;
    const isAdmin = user.role === Role.ADMIN;

    if (!isConsumerOwner && !isFarmerOwner && !isDeliveryOwner && !isAdmin) {
      throw new ForbiddenException('You do not have permission to view this order.');
    }

    return {
      success: true,
      data: order,
    };
  }

  async updateStatus(orderId: string, user: AuthenticatedUser, newStatus: OrderStatus, note?: string) {
    const order = await this.prisma.order.findUnique({
      where: { id: orderId },
      include: {
        consumer: { select: { id: true, userId: true } },
        farmer: { select: { id: true, userId: true } },
        delivery: { include: { deliveryPartner: { select: { id: true, userId: true } } } },
      },
    });

    if (!order) {
      throw new NotFoundException(`Order with ID ${orderId} not found.`);
    }

    const currentStatus = order.status;

    // State transition validation per role
    if (user.role === Role.FARMER) {
      if (order.farmer.userId !== user.id) {
        throw new ForbiddenException('You do not own this order and cannot update its status.');
      }
      const allowedFarmerTransitions: Record<string, OrderStatus[]> = {
        [OrderStatus.PLACED]: [OrderStatus.CONFIRMED, OrderStatus.CANCELLED],
        [OrderStatus.CONFIRMED]: [OrderStatus.PREPARING],
        [OrderStatus.PREPARING]: [OrderStatus.READY_FOR_PICKUP],
      };

      const allowedNext = allowedFarmerTransitions[currentStatus] || [];
      if (!allowedNext.includes(newStatus)) {
        throw new BadRequestException(
          `Farmers cannot transition order from ${currentStatus} to ${newStatus}.`,
        );
      }
    } else if (user.role === Role.DELIVERY_PARTNER) {
      if (order.delivery?.deliveryPartner?.userId !== user.id) {
        throw new ForbiddenException('You are not assigned to this delivery.');
      }
      const allowedDeliveryTransitions: Record<string, OrderStatus[]> = {
        [OrderStatus.READY_FOR_PICKUP]: [OrderStatus.PICKED_UP],
        [OrderStatus.PICKED_UP]: [OrderStatus.OUT_FOR_DELIVERY],
        [OrderStatus.OUT_FOR_DELIVERY]: [OrderStatus.DELIVERED],
      };

      const allowedNext = allowedDeliveryTransitions[currentStatus] || [];
      if (!allowedNext.includes(newStatus)) {
        throw new BadRequestException(
          `Delivery partners cannot transition order from ${currentStatus} to ${newStatus}.`,
        );
      }
    } else if (user.role === Role.CONSUMER) {
      if (order.consumer.userId !== user.id) {
        throw new ForbiddenException('You do not own this order.');
      }
      // Consumer can only cancel order when it is still in PLACED status
      if (currentStatus !== OrderStatus.PLACED || newStatus !== OrderStatus.CANCELLED) {
        throw new BadRequestException(
          `Consumers can only cancel orders that are currently in PLACED status.`,
        );
      }
    } else if (user.role !== Role.ADMIN) {
      throw new ForbiddenException('You are not authorized to update order status.');
    }

    // Execute order status update
    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: {
        status: newStatus,
        statusHistory: {
          create: {
            status: newStatus,
            note: note || `Status updated to ${newStatus} by ${user.role}`,
            changedBy: user.id,
          },
        },
      },
      include: {
        statusHistory: { orderBy: { createdAt: 'desc' } },
      },
    });

    return {
      success: true,
      message: `Order status updated to ${newStatus}`,
      data: updated,
    };
  }
}
