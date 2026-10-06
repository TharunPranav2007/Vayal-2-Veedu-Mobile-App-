import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_standard_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/produce_image_widget.dart';
import '../../../app/providers/orders_provider.dart';
import '../../orders/domain/order_model.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  String? _selectedOrderId;

  @override
  void initState() {
    super.initState();
    _selectedOrderId = widget.orderId;
  }

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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.DELIVERED:
        return AppColors.success;
      case OrderStatus.OUT_FOR_DELIVERY:
      case OrderStatus.PICKED_UP:
        return AppColors.secondaryOrange;
      case OrderStatus.CONFIRMED:
      case OrderStatus.PREPARING:
      case OrderStatus.READY_FOR_PICKUP:
        return AppColors.info;
      case OrderStatus.CANCELLED:
        return AppColors.error;
      default:
        return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(ordersProvider);
    // Filter orders for current consumer profile (cons-1) or show all placed orders
    final consumerOrders = allOrders.where((o) => o.consumerId == 'cons-1' || true).toList();

    // Determine current active order
    final selectedOrder = consumerOrders.firstWhere(
      (o) => o.id == _selectedOrderId || o.orderNumber == _selectedOrderId,
      orElse: () => consumerOrders.isNotEmpty
          ? consumerOrders.first
          : OrderModel(
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

    final currentIdx = _getStatusIndex(selectedOrder.status);

    final statusSteps = [
      {'title': 'Order Placed', 'subtitle': 'Sent to organic farm'},
      {'title': 'Confirmed & Packaged', 'subtitle': 'Farmer packing fresh produce'},
      {'title': 'Picked Up by Delivery', 'subtitle': 'Partner arrived at local farm'},
      {'title': 'Out for Delivery', 'subtitle': 'On the way to your doorstep'},
      {'title': 'Delivered', 'subtitle': 'Enjoy your direct farm produce!'},
    ];

    return Scaffold(
      appBar: const AppStandardHeader(
        subtitle: 'Order Tracking & History',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Selector Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Placed Orders (${consumerOrders.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tap to track',
                  style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Horizontal Order Cards List
            SizedBox(
              height: 95,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: consumerOrders.length,
                itemBuilder: (context, index) {
                  final ord = consumerOrders[index];
                  final isSelected = ord.id == selectedOrder.id;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedOrderId = ord.id),
                    child: Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.surfaceSubtleGreen : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ord.orderNumber,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected ? AppColors.primaryDarkGreen : AppColors.textDark,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 16),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(ord.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ord.status.name.replaceAll('_', ' '),
                              style: TextStyle(
                                color: _getStatusColor(ord.status),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '₹${ord.totalAmount.toStringAsFixed(2)} • ${ord.items.length} item(s)',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Active Selected Order Summary Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: selectedOrder.status == OrderStatus.CANCELLED
                      ? [AppColors.error, Colors.red.shade700]
                      : [AppColors.primaryDarkGreen, AppColors.primaryGreen],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (selectedOrder.status == OrderStatus.CANCELLED ? AppColors.error : AppColors.primaryGreen).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          selectedOrder.status == OrderStatus.CANCELLED ? Icons.cancel : Icons.local_shipping_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${selectedOrder.orderNumber}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Status: ${selectedOrder.status.name.replaceAll('_', ' ')}',
                              style: const TextStyle(color: AppColors.accentGreen, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '₹${selectedOrder.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white30, height: 20),
                  Row(
                    children: [
                      const Icon(Icons.agriculture, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Farm Origin: ${selectedOrder.farmName ?? "Green Field Organic Farm"} (${selectedOrder.farmerName ?? "M. Ramanathan"})',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (selectedOrder.status == OrderStatus.CANCELLED) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Reason for Cancellation: ${selectedOrder.cancellationReason ?? "Produce unavailable / harvest delay"}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Real-Time Fulfillment Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Live 5-Step Status Timeline
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

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Itemized Order Contents Card
            Text(
              'Order Items Breakdown (${selectedOrder.items.length} produce)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    ...selectedOrder.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  ProduceImageWidget(
                                    productName: item.productName,
                                    categoryName: '',
                                    width: 32,
                                    height: 32,
                                    borderRadius: 6,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${item.productName} (x${item.quantity.toStringAsFixed(0)})',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Fee:', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        Text(
                          selectedOrder.deliveryFee == 0 ? 'FREE' : '₹${selectedOrder.deliveryFee.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount Paid:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                          '₹${selectedOrder.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/consumer/home'),
                icon: const Icon(Icons.storefront),
                label: const Text('Return to Marketplace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
