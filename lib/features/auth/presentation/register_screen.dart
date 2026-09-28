import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/auth_provider.dart';
import '../domain/user_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final UserRole role;

  const RegisterScreen({super.key, required this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _phoneController.text.trim(),
            _passwordController.text.trim(),
            widget.role,
          );

      if (success && mounted) {
        switch (widget.role) {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Register as ${userRoleToString(widget.role).replaceAll('_', ' ')}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Vayal 2 Veedu marketplace',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name / Farm Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) => val == null || !val.contains('@') ? 'Enter valid email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (val) => val == null || val.length < 10 ? 'Enter valid phone number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Password min 6 chars' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleRegister,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
