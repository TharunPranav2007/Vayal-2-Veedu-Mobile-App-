import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../../app/providers/cart_provider.dart';
import '../../app/providers/auth_provider.dart';
import '../../features/auth/domain/user_model.dart';

class AppStandardHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showCart;
  final bool showOrders;
  final bool showProfile;
  final bool showBackButton;

  const AppStandardHeader({
    super.key,
    this.title = 'Vayal 2 Veedu',
    this.subtitle,
    this.showCart = true,
    this.showOrders = true,
    this.showProfile = true,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final roleTitle = subtitle ??
        (user != null
            ? '${userRoleToString(user.role).replaceAll('_', ' ')} Portal'
            : 'Organic Farm Marketplace');

    return AppBar(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 2,
      automaticallyImplyLeading: showBackButton,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              image: const DecorationImage(
                image: AssetImage('assets/images/app_logo_icon.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  roleTitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (showCart && (user == null || user.role == UserRole.CONSUMER)) ...[
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Shopping Cart',
                icon: const Icon(Icons.shopping_cart_outlined, size: 24),
                onPressed: () => context.push('/consumer/cart'),
              ),
              if (cartState.itemCount > 0)
                Positioned(
                  right: 4,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryOrange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartState.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (showOrders && (user == null || user.role == UserRole.CONSUMER)) ...[
          IconButton(
            tooltip: 'Track Orders',
            icon: const Icon(Icons.local_shipping_outlined, size: 24),
            onPressed: () => context.push('/consumer/orders/track'),
          ),
        ],
        if (showProfile) ...[
          PopupMenuButton<String>(
            tooltip: 'Account & Navigation Options',
            icon: const Icon(Icons.account_circle_outlined, size: 26, color: Colors.white),
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) async {
              if (value == 'profile') {
                context.push('/profile');
              } else if (value == 'logout') {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/role-selection');
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppColors.primaryGreen, size: 20),
                    SizedBox(width: 12),
                    Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error, size: 20),
                    SizedBox(width: 12),
                    Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(width: 4),
      ],
    );
  }
}
