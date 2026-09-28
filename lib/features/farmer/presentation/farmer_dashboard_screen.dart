import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/auth_provider.dart';

class FarmerDashboardScreen extends ConsumerWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
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
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.primaryLightGreen],
                ),
                borderRadius: BorderRadius.circular(16),
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
                    'Vayal 2 Veedu — Direct Produce Marketplace',
                    style: TextStyle(color: AppColors.accentGreen, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sales & Earnings Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Sales',
                    value: '₹14,500',
                    icon: Icons.currency_rupee,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Orders Received',
                    value: '24',
                    icon: Icons.shopping_bag_outlined,
                    color: AppColors.secondaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Farmer Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.surfaceSubtleGreen,
                child: Icon(Icons.add_shopping_cart, color: AppColors.primaryGreen),
              ),
              title: const Text('Add New Produce Listing'),
              subtitle: const Text('List fresh vegetables, fruits or grain'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/farmer/products/add'),
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.surfaceSubtleGreen,
                child: Icon(Icons.inventory_2_outlined, color: AppColors.primaryGreen),
              ),
              title: const Text('Manage My Products & Stock'),
              subtitle: const Text('Update pricing, stock levels & availability'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.push('/farmer/products'),
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.surfaceSubtleGreen,
                child: Icon(Icons.local_shipping_outlined, color: AppColors.primaryGreen),
              ),
              title: const Text('Incoming Orders to Fulfill'),
              subtitle: const Text('Prepare orders for delivery pickup'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('3 New', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              onTap: () {},
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
