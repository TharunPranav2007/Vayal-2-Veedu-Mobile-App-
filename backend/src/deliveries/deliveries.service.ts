import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { DeliveryStatus, Role } from '@prisma/client';
import { AuthenticatedUser } from '../common/decorators/current-user.decorator';

@Injectable()
export class DeliveriesService {
  constructor(private prisma: PrismaService) {}

  async getMyDeliveries(user: AuthenticatedUser) {
    let deliveryProfileId = user.deliveryProfileId;

    if (!deliveryProfileId) {
      const dp = await this.prisma.deliveryProfile.findUnique({
        where: { userId: user.id },
      });
      if (!dp) {
        throw new ForbiddenException('User is not registered as a delivery partner.');
      }
      deliveryProfileId = dp.id;
    }

    const deliveries = await this.prisma.delivery.findMany({
      where: { deliveryPartnerId: deliveryProfileId },
      include: {
        order: {
          include: {
            farmer: { select: { farmName: true, farmAddress: true } },
            deliveryAddress: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    return {
      success: true,
      data: deliveries,
    };
  }

  async updateDeliveryStatus(deliveryId: string, user: AuthenticatedUser, status: DeliveryStatus) {
    const delivery = await this.prisma.delivery.findUnique({
      where: { id: deliveryId },
      include: {
        deliveryPartner: { select: { userId: true } },
      },
    });

    if (!delivery) {
      throw new NotFoundException(`Delivery with ID ${deliveryId} not found.`);
    }

    // IDOR Protection: Must be assigned delivery partner or Admin
    if (user.role !== Role.ADMIN && delivery.deliveryPartner?.userId !== user.id) {
      throw new ForbiddenException('You are not authorized to manage this delivery assignment.');
    }

    const updated = await this.prisma.delivery.update({
      where: { id: deliveryId },
      data: {
        status,
        ...(status === DeliveryStatus.PICKED_UP && { pickupTime: new Date() }),
        ...(status === DeliveryStatus.DELIVERED && { deliveredTime: new Date() }),
      },
      include: {
        order: true,
      },
    });

    return {
      success: true,
      message: `Delivery status updated to ${status}`,
      data: updated,
    };
  }
}
