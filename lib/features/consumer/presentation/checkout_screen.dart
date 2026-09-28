import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/cart_provider.dart';
import '../../../app/providers/orders_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'CASH_ON_DELIVERY';
  final _addressController = TextEditingController(
    text: '12 Harvest Lane, Farm District, Madurai - 625001',
  );

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    final cartState = ref.read(cartProvider);
    final cartItems = cartState.items.values.toList();

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Add items before placing an order.')),
      );
      return;
    }

    ref.read(ordersProvider.notifier).placeOrderFromCart(
          consumerId: 'cons-1',
          cartItems: cartItems,
          subtotal: cartState.subtotal,
          deliveryFee: cartState.deliveryFee,
          taxAmount: cartState.taxAmount,
          totalAmount: cartState.totalAmount,
          deliveryAddress: _addressController.text,
          paymentMethod: _selectedPaymentMethod,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 30),
            SizedBox(width: 10),
            Text('Order Dispatched!'),
          ],
        ),
        content: const Text(
          'Your order has been sent to the farmer and delivery partner! Inventory stock has been locked.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/consumer/orders/track');
            },
            child: const Text('Track Order Timeline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Address',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primaryGreen),
                labelText: 'Street Address & Landmark',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              value: 'CASH_ON_DELIVERY',
              groupValue: _selectedPaymentMethod,
              activeColor: AppColors.primaryGreen,
              title: const Text('Cash on Delivery (COD)'),
              subtitle: const Text('Pay when fresh produce is delivered to your door'),
              onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
            ),
            RadioListTile<String>(
              value: 'TEST_PAYMENT_GATEWAY',
              groupValue: _selectedPaymentMethod,
              activeColor: AppColors.primaryGreen,
              title: const Text('Mock Online Payment (UPI / Card)'),
              subtitle: const Text('Instant card or UPI payment simulation'),
              onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items Subtotal:'),
                        Text('₹${cartState.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Fee:'),
                        Text(
                          cartState.deliveryFee == 0 ? 'FREE' : '₹${cartState.deliveryFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: cartState.deliveryFee == 0 ? AppColors.success : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST (5%):'),
                        Text('₹${cartState.taxAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Final Payable Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          '₹${cartState.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: cartState.items.isNotEmpty ? _placeOrder : null,
              child: const Text('Confirm & Place Direct Order'),
            ),
          ],
        ),
      ),
    );
  }
}
