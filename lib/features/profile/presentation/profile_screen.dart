import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/auth_provider.dart';
import '../../auth/domain/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryGreen,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Marketplace User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'user@vayal2veedu.com',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Role: ${userRoleToString(user?.role ?? UserRole.CONSUMER).replaceAll('_', ' ')}',
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.phone_outlined, color: AppColors.primaryGreen),
              title: const Text('Phone Number'),
              subtitle: Text(user?.phone ?? '+91 9876543210'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.secondaryOrange),
              title: const Text('Switch Marketplace Role'),
              subtitle: const Text('Change to Farmer, Consumer, Delivery or Admin'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/role-selection');
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.security_outlined, color: AppColors.primaryGreen),
              title: const Text('Security & JWT Authentication'),
              subtitle: const Text('Role authorization and token storage'),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/role-selection');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
