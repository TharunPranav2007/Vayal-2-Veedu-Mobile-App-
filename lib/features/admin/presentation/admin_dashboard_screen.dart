import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vayal 2 Veedu System Overview 🛡️',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'System Status: All Services Operational (PostgreSQL, NestJS REST API, FCM, WSS)',
                    style: TextStyle(color: AppColors.accentGreen, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Marketplace Platform Analytics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                _AdminCard(title: 'Total Users', value: '1,240', icon: Icons.people_outline, color: AppColors.primaryGreen),
                _AdminCard(title: 'Active Farmers', value: '185', icon: Icons.agriculture_outlined, color: AppColors.secondaryOrange),
                _AdminCard(title: 'Total GMV', value: '₹4.2L', icon: Icons.payments_outlined, color: AppColors.info),
                _AdminCard(title: 'Total Orders', value: '3,410', icon: Icons.shopping_bag_outlined, color: Colors.purple),
              ],
            ),
            const SizedBox(height: 24),
            Text('Platform Management Options', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined, color: AppColors.primaryGreen),
              title: const Text('Farmer Accounts & Verification'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: AppColors.primaryGreen),
              title: const Text('Product Catalog Moderation'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primaryGreen),
              title: const Text('Platform Order Oversight'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
