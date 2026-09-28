import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { OrderStatus, PaymentMethod, PaymentStatus } from '@prisma/client';

@Injectable()
export class OrdersService {
  constructor(private prisma: PrismaService) {}

  async createOrder(consumerProfileId: string, dto: { farmerId: string; addressId: string; items: { productId: string; quantity: number }[]; paymentMethod: PaymentMethod }) {
    if (!dto.items || dto.items.length === 0) {
      throw new BadRequestException('Cannot place an empty order.');
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
            },
          },
        },
        include: {
          items: true,
          payment: true,
        },
      });

      return {
        success: true,
        message: 'Order created successfully',
        data: order,
      };
    });
  }

  async updateStatus(orderId: string, status: OrderStatus, note?: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) {
      throw new NotFoundException(`Order ${orderId} not found.`);
    }

    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: {
        status,
        statusHistory: {
          create: {
            status,
            note: note || `Order status updated to ${status}`,
          },
        },
      },
      include: {
        statusHistory: true,
      },
    });

    return {
      success: true,
      message: `Order status updated to ${status}`,
      data: updated,
    };
  }
}
