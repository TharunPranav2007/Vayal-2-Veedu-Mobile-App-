import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/auth_provider.dart';
import '../domain/user_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && authState.user != null) {
      switch (authState.user!.role) {
        case UserRole.FARMER:
          context.go('/farmer/dashboard');
          break;
        case UserRole.CONSUMER:
          context.go('/consumer/home');
          break;
        case UserRole.DELIVERY_PARTNER:
          context.go('/delivery/dashboard');
          break;
        case UserRole.ADMIN:
          context.go('/admin/dashboard');
          break;
      }
    } else {
      context.go('/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco_rounded,
                size: 64,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vayal 2 Veedu',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'From the Field to Your Home',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryOrange),
            ),
          ],
        ),
      ),
    );
  }
}
