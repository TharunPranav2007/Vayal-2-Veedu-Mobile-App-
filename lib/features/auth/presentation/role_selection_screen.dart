import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/user_model.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.eco, color: AppColors.primaryGreen, size: 36),
                  const SizedBox(width: 10),
                  Text(
                    'Vayal 2 Veedu',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome! Choose your marketplace role to continue',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      title: 'Farmer / Producer',
                      description: 'List fresh produce, set pricing, manage stock & fulfill direct customer orders.',
                      icon: Icons.agriculture_rounded,
                      role: UserRole.FARMER,
                      accentColor: AppColors.primaryGreen,
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      title: 'Consumer / Buyer',
                      description: 'Discover fresh farm produce, place orders, track delivery & review growers.',
                      icon: Icons.shopping_basket_rounded,
                      role: UserRole.CONSUMER,
                      accentColor: AppColors.secondaryOrange,
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      title: 'Delivery Partner',
                      description: 'Accept order pickup requests, navigate delivery routes & deliver fresh produce.',
                      icon: Icons.local_shipping_rounded,
                      role: UserRole.DELIVERY_PARTNER,
                      accentColor: AppColors.info,
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      title: 'Platform Administrator',
                      description: 'Monitor system activity, oversee users, moderate listings & platform analytics.',
                      icon: Icons.admin_panel_settings_rounded,
                      role: UserRole.ADMIN,
                      accentColor: AppColors.primaryDarkGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final UserRole role;
  final Color accentColor;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.role,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/login?role=${userRoleToString(role)}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
