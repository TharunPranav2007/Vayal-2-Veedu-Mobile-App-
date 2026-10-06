import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_standard_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/produce_image_widget.dart';
import '../../../app/providers/auth_provider.dart';
import '../../../app/providers/products_provider.dart';
import '../../../app/providers/orders_provider.dart';
import '../../orders/domain/order_model.dart';

class FarmerDashboardScreen extends ConsumerStatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  ConsumerState<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends ConsumerState<FarmerDashboardScreen> {
  String _selectedFilter = 'Active';

  void _showRejectOrderDialog(BuildContext context, OrderModel ord) {
    String selectedReason = 'Harvest Shortfall / Out of Stock';
    final customReasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.cancel_outlined, color: AppColors.error),
              const SizedBox(width: 8),
              Text('Reject Order #${ord.orderNumber}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please select or specify the reason for rejecting this order:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              ...[
                'Harvest Shortfall / Out of Stock',
                'Adverse Weather Damage',
                'Transport / Logistics Unavailable',
                'Custom Reason',
              ].map(
                (reason) => RadioListTile<String>(
                  title: Text(reason, style: const TextStyle(fontSize: 13)),
                  value: reason,
                  groupValue: selectedReason,
                  dense: true,
                  activeColor: AppColors.error,
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedReason = val);
                  },
                ),
              ),
              if (selectedReason == 'Custom Reason') ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: customReasonCtrl,
                  decoration: const InputDecoration(hintText: 'Enter cancellation reason...', isDense: true),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Back')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                final finalReason = selectedReason == 'Custom Reason' ? customReasonCtrl.text.trim() : selectedReason;
                ref.read(ordersProvider.notifier).cancelOrder(ord.id, finalReason.isEmpty ? 'Cancelled by Farmer' : finalReason);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order #${ord.orderNumber} rejected.')),
                );
              },
              child: const Text('Confirm Rejection'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderInspectionModal(BuildContext context, OrderModel ord) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Audit #${ord.orderNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ord.status.name.replaceAll('_', ' '),
                    style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Purchased Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ...ord.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ProduceImageWidget(
                            productName: item.productName,
                            categoryName: '',
                            width: 28,
                            height: 28,
                            borderRadius: 6,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('${item.productName} (x${item.quantity.toStringAsFixed(0)})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('₹${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Revenue Earned:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  '₹${ord.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final products = ref.watch(productsProvider);
    final allOrders = ref.watch(ordersProvider);

    // Filter farmer orders
    final farmerOrders = allOrders.where((o) => o.farmerId == 'f1' || true).toList();

    final filteredOrders = farmerOrders.where((o) {
      if (_selectedFilter == 'Active') {
        return o.status != OrderStatus.DELIVERED && o.status != OrderStatus.CANCELLED;
      } else if (_selectedFilter == 'Completed') {
        return o.status == OrderStatus.DELIVERED;
      }
      return true; // 'All History'
    }).toList();

    final totalEarnings = farmerOrders
        .where((o) => o.status != OrderStatus.CANCELLED)
        .fold(0.0, (sum, o) => sum + o.totalAmount);

    return Scaffold(
      appBar: const AppStandardHeader(
        subtitle: 'Farmer Direct Portal',
        showCart: false,
        showOrders: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryLightGreen],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.name ?? "Farmer"}! 🌾',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Vayal 2 Veedu — Direct Produce Sales Portal',
                    style: TextStyle(color: AppColors.accentGreen, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Realtime Business Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Revenue',
                    value: '₹${totalEarnings.toStringAsFixed(0)}',
                    icon: Icons.currency_rupee,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Active Produce',
                    value: '${products.length}',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.secondaryOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Total Orders',
                    value: '${farmerOrders.length}',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.surfaceSubtleGreen,
                child: Icon(Icons.add_shopping_cart, color: AppColors.primaryGreen),
              ),
              title: const Text('Add New Produce Listing', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Publish organic veggies, fruits or grain'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/farmer/products/add'),
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.surfaceSubtleGreen,
                child: Icon(Icons.inventory_2_outlined, color: AppColors.primaryGreen),
              ),
              title: const Text('Manage My Products & Stock', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Currently ${products.length} items live on marketplace'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/farmer/products'),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orders & Fulfillment Pipeline',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${farmerOrders.length} Total',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Order History Filter Chips
            Row(
              children: ['Active', 'Completed', 'All History'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            filteredOrders.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No orders found in this category.')),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final ord = filteredOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showOrderInspectionModal(context, ord),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
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
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.info_outline, size: 16, color: AppColors.primaryGreen),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        ord.status.name.replaceAll('_', ' '),
                                        style: const TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${ord.items.length} produce item(s) • Total: ₹${ord.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                                const SizedBox(height: 12),

                                // Sequential Farmer Lifecycle Action Pipeline
                                if (ord.status == OrderStatus.PLACED)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                                          onPressed: () {
                                            ref.read(ordersProvider.notifier).updateOrderStatus(ord.id, OrderStatus.CONFIRMED);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Order #${ord.orderNumber} accepted!')),
                                            );
                                          },
                                          icon: const Icon(Icons.check_circle_outline, size: 16),
                                          label: const Text('Accept Order', style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppColors.error,
                                            side: const BorderSide(color: AppColors.error),
                                          ),
                                          onPressed: () => _showRejectOrderDialog(context, ord),
                                          icon: const Icon(Icons.cancel_outlined, size: 16),
                                          label: const Text('Reject Order', style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                    ],
                                  )
                                else if (ord.status == OrderStatus.CONFIRMED)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
                                    onPressed: () {
                                      ref.read(ordersProvider.notifier).updateOrderStatus(ord.id, OrderStatus.PREPARING);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Order #${ord.orderNumber} is now being packed.')),
                                      );
                                    },
                                    icon: const Icon(Icons.inventory, size: 18),
                                    label: const Text('2. Start Packing Produce'),
                                  )
                                else if (ord.status == OrderStatus.PREPARING)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryOrange),
                                    onPressed: () {
                                      ref.read(ordersProvider.notifier).updateOrderStatus(ord.id, OrderStatus.READY_FOR_PICKUP);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Order #${ord.orderNumber} marked READY for delivery pickup!')),
                                      );
                                    },
                                    icon: const Icon(Icons.local_shipping, size: 18),
                                    label: const Text('3. Mark Prepared & Ready for Pickup'),
                                  )
                                else if (ord.status == OrderStatus.CANCELLED)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.cancel, color: AppColors.error, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Order Rejected/Cancelled: ${ord.cancellationReason ?? "No reason specified"}',
                                            style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceSubtleGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.verified, color: AppColors.primaryGreen, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Handed off to Delivery Partner (${ord.status.name.replaceAll('_', ' ')})',
                                            style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
