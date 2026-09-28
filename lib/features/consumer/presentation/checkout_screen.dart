import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 30),
            SizedBox(width: 10),
            Text('Order Confirmed!'),
          ],
        ),
        content: const Text(
          'Your order ORD-1001 has been sent to the farmer. You can track live delivery updates in real-time.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/consumer/tracking?orderId=ORD-1001');
            },
            child: const Text('Track Order Status'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              title: const Text('Mock / Sandbox Online Payment'),
              subtitle: const Text('Instant card or UPI payment simulation'),
              onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Produce Items Subtotal:'),
                        Text('₹155.00', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Direct Farm Delivery Fee:'),
                        Text('₹30.00', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Final Payable Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          '₹185.00',
                          style: TextStyle(
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
              onPressed: _placeOrder,
              child: const Text('Confirm & Place Direct Order'),
            ),
          ],
        ),
      ),
    );
  }
}
