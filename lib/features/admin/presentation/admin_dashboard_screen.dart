import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/products_provider.dart';
import '../../../app/providers/orders_provider.dart';
import '../../orders/domain/order_model.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String _orderFilter = 'All';

  void _showFarmerAccountsModal(BuildContext context) {
    final farmers = [
      {'name': 'Green Field Organic Farm', 'farmer': 'Tharun Pranav', 'location': 'Madurai Sector 4', 'status': 'VERIFIED', 'products': 3},
      {'name': 'Vayal Fresh Produce', 'farmer': 'Murugan K.', 'location': 'Dindigul Road', 'status': 'VERIFIED', 'products': 2},
      {'name': 'Kaveri River Farms', 'farmer': 'Ramanathan S.', 'location': 'Tanjore District', 'status': 'VERIFIED', 'products': 2},
    ];

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
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            Text('Registered Farmer Accounts (${farmers.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ...farmers.map(
              (f) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceSubtleGreen,
                    child: Icon(Icons.agriculture, color: AppColors.primaryGreen),
                  ),
                  title: Text(f['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Owner: ${f['farmer']} • ${f['location']}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(f['status'] as String, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeliveryPartnersModal(BuildContext context) {
    final partners = [
      {'name': 'Karthik R. (Rider #1)', 'vehicle': 'TN-58-AB-1234 (Two Wheeler)', 'status': 'ONLINE', 'deliveries': 18},
      {'name': 'Senthil V. (Rider #2)', 'vehicle': 'TN-58-XY-9876 (Two Wheeler)', 'status': 'ONLINE', 'deliveries': 14},
    ];

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
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            Text('Delivery Partner Accounts (${partners.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            ...partners.map(
              (p) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.info,
                    child: Icon(Icons.two_wheeler, color: Colors.white),
                  ),
                  title: Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Vehicle: ${p['vehicle']} • Completed: ${p['deliveries']}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(p['status'] as String, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transaction Audit #${ord.orderNumber}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(ord.status.name.replaceAll('_', ' '), style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Consumer ID: ${ord.consumerId} • Farmer ID: ${ord.farmerId}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 14),
            const Text('Purchased Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                const Text('Transaction GMV Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('₹${ord.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryGreen)),
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
    final products = ref.watch(productsProvider);
    final orders = ref.watch(ordersProvider);

    final totalGMV = orders.fold(0.0, (sum, o) => sum + o.totalAmount);

    final filteredOrders = orders.where((o) {
      if (_orderFilter == 'Active') {
        return o.status != OrderStatus.DELIVERED && o.status != OrderStatus.CANCELLED;
      } else if (_orderFilter == 'Delivered') {
        return o.status == OrderStatus.DELIVERED;
      }
      return true; // 'All'
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Administrator'),
        backgroundColor: AppColors.primaryDarkGreen,
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
            // Admin Banner Header (Services operational text removed as requested)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryDarkGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vayal 2 Veedu System Overview 🛡️',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Central Platform Oversight & Marketplace Moderation Control',
                    style: TextStyle(color: AppColors.accentGreen, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Realtime Platform Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _AdminCard(
                  title: 'Active Listings',
                  value: '${products.length}',
                  icon: Icons.eco_outlined,
                  color: AppColors.primaryGreen,
                ),
                _AdminCard(
                  title: 'Total GMV',
                  value: '₹${totalGMV.toStringAsFixed(0)}',
                  icon: Icons.payments_outlined,
                  color: AppColors.secondaryOrange,
                ),
                _AdminCard(
                  title: 'Total Orders',
                  value: '${orders.length}',
                  icon: Icons.shopping_bag_outlined,
                  color: AppColors.info,
                ),
                const _AdminCard(
                  title: 'Verified Farmers',
                  value: '3 Active',
                  icon: Icons.agriculture_outlined,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Platform Moderation & Accounts Control',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined, color: AppColors.primaryGreen),
              title: const Text('Farmer Accounts & Verification', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('3 registered farms verified'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showFarmerAccountsModal(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.two_wheeler_outlined, color: AppColors.info),
              title: const Text('Delivery Partner Accounts', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('2 registered riders active'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showDeliveryPartnersModal(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: AppColors.primaryGreen),
              title: const Text('Product Catalog Moderation', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${products.length} produce listings active'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/farmer/products'),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Platform Order Oversight (${orders.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(12)),
                  child: Text('${orders.length} Logged', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Order Filter Chips
            Row(
              children: ['All', 'Active', 'Delivered'].map((filter) {
                final isSelected = _orderFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    onSelected: (_) => setState(() => _orderFilter = filter),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // All Orders List View
            filteredOrders.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No order transactions found.')),
                    ),
                  )
                : Column(
                    children: filteredOrders.map((ord) {
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
                                        Text('Order #${ord.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.verified_outlined, size: 16, color: AppColors.primaryGreen),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: ord.status == OrderStatus.DELIVERED ? AppColors.success.withOpacity(0.15) : AppColors.info.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ord.status.name.replaceAll('_', ' '),
                                        style: TextStyle(
                                          color: ord.status == OrderStatus.DELIVERED ? AppColors.success : AppColors.info,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('${ord.items.length} produce item(s) • Total GMV: ₹${ord.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () => context.push('/consumer/orders/track?orderId=${ord.id}'),
                                  icon: const Icon(Icons.timeline, size: 16),
                                  label: const Text('Inspect Live Dispatch Timeline'),
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

class _AdminCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminCard({required this.title, required this.value, required this.icon, required this.color});

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
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
