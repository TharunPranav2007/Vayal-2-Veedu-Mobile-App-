import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../products/domain/product_model.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  final List<Product> _mockProducts = [
    Product(
      id: 'p1',
      farmerId: 'f1',
      farmerName: 'Green Field Organic Farm',
      categoryId: 'c1',
      categoryName: 'Fresh Vegetables',
      name: 'Organic Country Tomatoes',
      description: 'Vine-ripened organic tomatoes harvested daily from Madurai farm.',
      price: 40.0,
      unit: 'kg',
      stock: 50.0,
      isPublished: true,
      averageRating: 4.8,
      totalReviews: 14,
    ),
    Product(
      id: 'p2',
      farmerId: 'f1',
      farmerName: 'Green Field Organic Farm',
      categoryId: 'c2',
      categoryName: 'Fresh Greens',
      name: 'Fresh Palak (Spinach)',
      description: 'Pesticide-free fresh spinach leaves packed in bunches.',
      price: 25.0,
      unit: 'bunch',
      stock: 30.0,
      isPublished: true,
      averageRating: 4.9,
      totalReviews: 8,
    ),
    Product(
      id: 'p3',
      farmerId: 'f1',
      farmerName: 'Green Field Organic Farm',
      categoryId: 'c1',
      categoryName: 'Fresh Vegetables',
      name: 'Native Brinjal (Eggplant)',
      description: 'Purple striped native brinjal variety rich in antioxidants.',
      price: 35.0,
      unit: 'kg',
      stock: 15.0,
      isPublished: false,
      averageRating: 4.5,
      totalReviews: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Produce Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/farmer/products/add'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _mockProducts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = _mockProducts[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtleGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.eco, color: AppColors.primaryGreen, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${product.price} / ${product.unit}  •  Stock: ${product.stock} ${product.unit}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: product.isPublished
                                    ? AppColors.primaryGreen.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                product.isPublished ? 'Published' : 'Draft / Off-stock',
                                style: TextStyle(
                                  color: product.isPublished ? AppColors.primaryGreen : Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: product.isPublished,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (val) {
                      setState(() {
                        _mockProducts[index] = Product(
                          id: product.id,
                          farmerId: product.farmerId,
                          farmerName: product.farmerName,
                          categoryId: product.categoryId,
                          categoryName: product.categoryName,
                          name: product.name,
                          description: product.description,
                          price: product.price,
                          unit: product.unit,
                          stock: product.stock,
                          isPublished: val,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        onPressed: () => context.push('/farmer/products/add'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Produce', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
