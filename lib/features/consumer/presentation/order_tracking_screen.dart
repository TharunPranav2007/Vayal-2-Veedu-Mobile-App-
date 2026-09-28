import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../orders/domain/order_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  OrderStatus _currentStatus = OrderStatus.PREPARING;

  final List<Map<String, dynamic>> _statusSteps = [
    {'status': OrderStatus.PLACED, 'label': 'Order Placed', 'subtitle': 'Consumer order received'},
    {'status': OrderStatus.CONFIRMED, 'label': 'Order Confirmed', 'subtitle': 'Farmer confirmed produce availability'},
    {'status': OrderStatus.PREPARING, 'label': 'Harvesting & Preparing', 'subtitle': 'Farmer packing fresh produce'},
    {'status': OrderStatus.READY_FOR_PICKUP, 'label': 'Ready for Pickup', 'subtitle': 'Awaiting delivery partner pickup'},
    {'status': OrderStatus.OUT_FOR_DELIVERY, 'label': 'Out for Delivery', 'subtitle': 'Partner delivering produce to your home'},
    {'status': OrderStatus.DELIVERED, 'label': 'Delivered', 'subtitle': 'Produce delivered to doorstep'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order status refreshed from server.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtleGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping, color: AppColors.primaryGreen, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status: ${_currentStatus.name.replaceAll('_', ' ')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Estimated Delivery: Today by 5:30 PM',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Real-Time Fulfillment Timeline',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._statusSteps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              final isDone = idx <= 2; // Simulated status step
              final isCurrent = idx == 2;

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
                      if (idx < _statusSteps.length - 1)
                        Container(
                          width: 2,
                          height: 40,
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
                            step['label'],
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isDone ? AppColors.textDark : AppColors.textMuted,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            step['subtitle'],
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
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
