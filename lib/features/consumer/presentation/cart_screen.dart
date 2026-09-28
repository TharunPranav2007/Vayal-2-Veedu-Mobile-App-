import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': 'c1',
      'name': 'Country Tomatoes',
      'farmer': 'Green Field Organic Farm',
      'price': 40.0,
      'unit': 'kg',
      'quantity': 2.0,
    },
    {
      'id': 'c2',
      'name': 'Organic Palak',
      'farmer': 'Vayal Fresh Produce',
      'price': 25.0,
      'unit': 'bunch',
      'quantity': 3.0,
    },
  ];

  double get subtotal => _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  double get deliveryFee => 30.0;
  double get total => subtotal + deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() => _cartItems.clear()),
            ),
        ],
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_shopping_cart_outlined, size: 72, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text('Add fresh produce directly from local farmers'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/consumer/home'),
                    child: const Text('Browse Produce Catalog'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtleGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.eco, color: AppColors.primaryGreen),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      '₹${item['price']}/${item['unit']}  •  ${item['farmer']}',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Item Total: ₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        if (item['quantity'] > 1) {
                                          item['quantity'] -= 1;
                                        } else {
                                          _cartItems.removeAt(index);
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    '${item['quantity'].toInt()}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        item['quantity'] += 1;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Checkout Bottom Sheet
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Fee:'),
                          Text('₹${deliveryFee.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/consumer/checkout'),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
