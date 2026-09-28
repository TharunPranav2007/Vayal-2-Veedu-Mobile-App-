import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/domain/user_model.dart';

// Import Screens
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/role_selection_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/farmer/presentation/farmer_dashboard_screen.dart';
import '../../features/farmer/presentation/add_product_screen.dart';
import '../../features/farmer/presentation/my_products_screen.dart';
import '../../features/consumer/presentation/consumer_home_screen.dart';
import '../../features/consumer/presentation/cart_screen.dart';
import '../../features/consumer/presentation/checkout_screen.dart';
import '../../features/consumer/presentation/order_tracking_screen.dart';
import '../../features/delivery/presentation/delivery_dashboard_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/role-selection' ||
          state.matchedLocation == '/';

      if (!isLoggedIn) {
        return isAuthRoute ? null : '/role-selection';
      }

      // If logged in, redirect to role dashboard if on auth route
      if (isAuthRoute && authState.user != null) {
        switch (authState.user!.role) {
          case UserRole.FARMER:
            return '/farmer/dashboard';
          case UserRole.CONSUMER:
            return '/consumer/home';
          case UserRole.DELIVERY_PARTNER:
            return '/delivery/dashboard';
          case UserRole.ADMIN:
            return '/admin/dashboard';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final roleStr = state.uri.queryParameters['role'] ?? 'CONSUMER';
          return LoginScreen(role: userRoleFromString(roleStr));
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final roleStr = state.uri.queryParameters['role'] ?? 'CONSUMER';
          return RegisterScreen(role: userRoleFromString(roleStr));
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Farmer Routes
      GoRoute(
        path: '/farmer/dashboard',
        builder: (context, state) => const FarmerDashboardScreen(),
      ),
      GoRoute(
        path: '/farmer/products',
        builder: (context, state) => const MyProductsScreen(),
      ),
      GoRoute(
        path: '/farmer/products/add',
        builder: (context, state) => const AddProductScreen(),
      ),

      // Consumer Routes
      GoRoute(
        path: '/consumer/home',
        builder: (context, state) => const ConsumerHomeScreen(),
      ),
      GoRoute(
        path: '/consumer/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/consumer/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/consumer/tracking',
        builder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'] ?? 'ORD-1001';
          return OrderTrackingScreen(orderId: orderId);
        },
      ),

      // Delivery Partner Routes
      GoRoute(
        path: '/delivery/dashboard',
        builder: (context, state) => const DeliveryDashboardScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
});
