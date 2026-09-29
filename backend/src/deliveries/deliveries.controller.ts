import { Controller, Get, Patch, Param, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { DeliveriesService } from './deliveries.service';
import { DeliveryStatus, Role } from '@prisma/client';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser, AuthenticatedUser } from '../common/decorators/current-user.decorator';

class UpdateDeliveryStatusDto {
  status: DeliveryStatus;
}

@ApiTags('Deliveries & Logistics')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('deliveries')
export class DeliveriesController {
  constructor(private readonly deliveriesService: DeliveriesService) {}

  @Get('my-deliveries')
  @Roles(Role.DELIVERY_PARTNER, Role.ADMIN)
  @ApiOperation({ summary: 'Get assigned deliveries for current delivery partner' })
  @ApiResponse({ status: 200, description: 'Assigned deliveries retrieved' })
  async getMyDeliveries(@CurrentUser() user: AuthenticatedUser) {
    return this.deliveriesService.getMyDeliveries(user);
  }

  @Patch(':id/status')
  @Roles(Role.DELIVERY_PARTNER, Role.ADMIN)
  @ApiOperation({ summary: 'Update status of assigned delivery with IDOR protection' })
  @ApiResponse({ status: 200, description: 'Delivery status updated' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not assigned to this delivery' })
  async updateStatus(
    @Param('id') id: string,
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateDeliveryStatusDto,
  ) {
    return this.deliveriesService.updateDeliveryStatus(id, user, dto.status);
  }
}
