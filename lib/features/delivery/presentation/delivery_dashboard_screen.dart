import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/auth_provider.dart';
import '../../../app/providers/orders_provider.dart';
import '../../orders/domain/order_model.dart';

class DeliveryDashboardScreen extends ConsumerWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final orders = ref.watch(ordersProvider);

    final completedDeliveries = orders.where((o) => o.status == OrderStatus.DELIVERED).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Partner Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.two_wheeler_rounded, color: AppColors.info, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Partner: ${user?.name ?? "Delivery Rider"}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Online • $completedDeliveries Delivered Today',
                              style: const TextStyle(color: AppColors.info, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Dispatch Jobs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length} Jobs',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            orders.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No active delivery jobs currently available.')),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final ord = orders[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #${ord.orderNumber}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: ord.status == OrderStatus.DELIVERED
                                          ? AppColors.success.withOpacity(0.15)
                                          : AppColors.warning.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      ord.status.name.replaceAll('_', ' '),
                                      style: TextStyle(
                                        color: ord.status == OrderStatus.DELIVERED ? AppColors.success : AppColors.warning,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Row(
                                children: [
                                  Icon(Icons.storefront, size: 16, color: AppColors.primaryGreen),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Pickup: Green Field Organic Farm, Madurai',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Row(
                                children: [
                                  Icon(Icons.home, size: 16, color: AppColors.secondaryOrange),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Dropoff: 12 Harvest Lane, Farm District, Madurai',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Dynamic Action Buttons for Rider
                              if (ord.status == OrderStatus.CONFIRMED || ord.status == OrderStatus.PLACED)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                                  onPressed: () {
                                    ref.read(ordersProvider.notifier).updateOrderStatus(ord.id, OrderStatus.OUT_FOR_DELIVERY);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Picked up Order #${ord.orderNumber}! Out for delivery.')),
                                    );
                                  },
                                  icon: const Icon(Icons.two_wheeler),
                                  label: const Text('Pick Up & Start Delivery'),
                                )
                              else if (ord.status == OrderStatus.OUT_FOR_DELIVERY)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                  onPressed: () {
                                    ref.read(ordersProvider.notifier).updateOrderStatus(ord.id, OrderStatus.DELIVERED);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Order #${ord.orderNumber} marked as DELIVERED!')),
                                    );
                                  },
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('Mark Order as Delivered'),
                                )
                              else if (ord.status == OrderStatus.DELIVERED)
                                const Row(
                                  children: [
                                    Icon(Icons.verified, color: AppColors.success, size: 18),
                                    SizedBox(width: 6),
                                    Text('Delivery Completed Successfully', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
