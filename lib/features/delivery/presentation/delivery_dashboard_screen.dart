import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/auth_provider.dart';
import '../../../app/providers/orders_provider.dart';
import '../../orders/domain/order_model.dart';

class DeliveryDashboardScreen extends ConsumerWidget {
  const DeliveryDashboardScreen({super.key});

  void _showJobDetailModal(BuildContext context, WidgetRef ref, OrderModel ord) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Job Details #${ord.orderNumber}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Farm Pickup Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtleGreen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined, color: AppColors.primaryGreen, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'FARM PICKUP LOCATION',
                          style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Green Field Organic Farm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    const Text('Field Rd, Sector 4, Madurai Farm Belt - 625001', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Calling Farmer (+91 9876543210)...')),
                            );
                          },
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Call Farm'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Consumer Dropoff Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.info.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.home_outlined, color: AppColors.info, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'CUSTOMER DROPOFF LOCATION',
                          style: TextStyle(color: AppColors.info, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Tharun Pranav (Customer)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    const Text('12 Harvest Lane, Farm District, Madurai - 625001', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Calling Customer (+91 9123456789)...')),
                            );
                          },
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Call Customer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.info,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text('Items to Collect & Deliver:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),

              ...ord.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• ${item.productName} (x${item.quantity.toStringAsFixed(0)})', style: const TextStyle(fontSize: 13)),
                      Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment Collect Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    '₹${ord.totalAmount.toStringAsFixed(2)} (COD)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondaryOrange),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              if (ord.status == OrderStatus.CONFIRMED || ord.status == OrderStatus.PLACED || ord.status == OrderStatus.PREPARING)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                    onPressed: () {
                      ref.read(ordersProvider.notifier).updateOrderStatus(ord.id, OrderStatus.OUT_FOR_DELIVERY);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Picked up Order #${ord.orderNumber}! Out for delivery.')),
                      );
                    },
                    icon: const Icon(Icons.two_wheeler),
                    label: const Text('Pick Up Produce & Start Delivery'),
                  ),
                )
              else if (ord.status == OrderStatus.OUT_FOR_DELIVERY)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () {
                      ref.read(ordersProvider.notifier).updateOrderStatus(ord.id, OrderStatus.DELIVERED);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order #${ord.orderNumber} marked as DELIVERED!')),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Order Delivered & Collect Cash'),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Delivery Completed Successfully 🎉', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

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
                            Expanded(
                              child: Text(
                                'Online • $completedDeliveries Delivered Today',
                                style: const TextStyle(color: AppColors.info, fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                : Column(
                    children: orders.map((ord) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showJobDetailModal(context, ref, ord),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Order #${ord.orderNumber}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                                      ],
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

                                // Action Buttons for Rider
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _showJobDetailModal(context, ref, ord),
                                        icon: const Icon(Icons.visibility_outlined, size: 16),
                                        label: const Text('View Full Details'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (ord.status == OrderStatus.CONFIRMED || ord.status == OrderStatus.PLACED || ord.status == OrderStatus.PREPARING)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.info,
                                          minimumSize: const Size(100, 44),
                                        ),
                                        onPressed: () {
                                          ref.read(ordersProvider.notifier).updateOrderStatus(ord.id, OrderStatus.OUT_FOR_DELIVERY);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Picked up Order #${ord.orderNumber}! Out for delivery.')),
                                          );
                                        },
                                        child: const Text('Pick Up'),
                                      )
                                    else if (ord.status == OrderStatus.OUT_FOR_DELIVERY)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.success,
                                          minimumSize: const Size(100, 44),
                                        ),
                                        onPressed: () {
                                          ref.read(ordersProvider.notifier).updateOrderStatus(ord.id, OrderStatus.DELIVERED);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Order #${ord.orderNumber} marked as DELIVERED!')),
                                          );
                                        },
                                        child: const Text('Deliver'),
                                      )
                                    else
                                      const Icon(Icons.verified, color: AppColors.success, size: 24),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
