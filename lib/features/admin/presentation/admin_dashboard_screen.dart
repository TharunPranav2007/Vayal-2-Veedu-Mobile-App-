import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/products_provider.dart';
import '../../../app/providers/orders_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final orders = ref.watch(ordersProvider);

    final totalGMV = orders.fold(0.0, (sum, o) => sum + o.totalAmount);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vayal 2 Veedu System Overview 🛡️',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Services Operational: NestJS REST API, PostgreSQL, WebSocket',
                          style: TextStyle(color: AppColors.accentGreen, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
                  value: '48',
                  icon: Icons.agriculture_outlined,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Platform Moderation & Controls',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined, color: AppColors.primaryGreen),
              title: const Text('Farmer Accounts & Verification', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All 48 farmers verified.')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: AppColors.primaryGreen),
              title: const Text('Product Catalog Moderation', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${products.length} produce listings active'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/farmer/products'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primaryGreen),
              title: const Text('Platform Order Oversight', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${orders.length} order transactions logged'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/consumer/orders/track'),
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
