import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/orders_provider.dart';
import '../../orders/domain/order_model.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  int _getStatusIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.PLACED:
        return 0;
      case OrderStatus.CONFIRMED:
      case OrderStatus.PREPARING:
        return 1;
      case OrderStatus.READY_FOR_PICKUP:
      case OrderStatus.PICKED_UP:
        return 2;
      case OrderStatus.OUT_FOR_DELIVERY:
        return 3;
      case OrderStatus.DELIVERED:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final order = orders.firstWhere(
      (o) => o.id == orderId || o.orderNumber == orderId,
      orElse: () => orders.isNotEmpty ? orders.first : OrderModel(
        id: 'ord-101',
        orderNumber: 'ORD-8821',
        consumerId: 'cons-1',
        farmerId: 'f1',
        subtotal: 100.0,
        deliveryFee: 30.0,
        discount: 0.0,
        totalAmount: 135.0,
        status: OrderStatus.CONFIRMED,
        createdAt: DateTime.now(),
        items: [],
      ),
    );

    final currentIdx = _getStatusIndex(order.status);

    final statusSteps = [
      {'title': 'Order Placed', 'subtitle': 'Sent to organic farm'},
      {'title': 'Confirmed & Harvested', 'subtitle': 'Farmer packing fresh produce'},
      {'title': 'Picked Up by Delivery', 'subtitle': 'Partner arrived at local farm'},
      {'title': 'Out for Delivery', 'subtitle': 'On the way to your doorstep'},
      {'title': 'Delivered', 'subtitle': 'Enjoy your direct farm produce!'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${order.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.surfaceSubtleGreen, Colors.white],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status: ${order.status.name.replaceAll('_', ' ')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Total Payable: ₹${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Real-Time Dispatch Timeline',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Timeline Steps
            ...statusSteps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              final isDone = idx <= currentIdx;
              final isCurrent = idx == currentIdx;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isDone ? AppColors.primaryGreen : Colors.grey[300],
                        child: isDone
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text('${idx + 1}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ),
                      if (idx < statusSteps.length - 1)
                        Container(
                          width: 2,
                          height: 42,
                          color: isDone ? AppColors.primaryGreen : Colors.grey[300],
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title']!,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isDone ? AppColors.textDark : AppColors.textMuted,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            step['subtitle']!,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/consumer/home'),
              icon: const Icon(Icons.home),
              label: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
