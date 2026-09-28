import { Controller, Post, Patch, Param, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { OrdersService } from './orders.service';
import { OrderStatus, PaymentMethod } from '@prisma/client';

class CreateOrderDto {
  consumerId: string;
  farmerId: string;
  addressId: string;
  items: { productId: string; quantity: number }[];
  paymentMethod: PaymentMethod;
}

class UpdateOrderStatusDto {
  status: OrderStatus;
  note?: string;
}

@ApiTags('Orders Lifecycle')
@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  @ApiOperation({ summary: 'Place a new direct order with server-side price recalculation & stock locking' })
  @ApiResponse({ status: 201, description: 'Order created successfully' })
  async create(@Body() dto: CreateOrderDto) {
    return this.ordersService.createOrder(dto.consumerId, dto);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Transition order state (CONFIRMED, PREPARING, READY_FOR_PICKUP, DELIVERED)' })
  async updateStatus(@Param('id') id: string, @Body() dto: UpdateOrderStatusDto) {
    return this.ordersService.updateStatus(id, dto.status, dto.note);
  }
}
