import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/products_provider.dart';

class MyProductsScreen extends ConsumerWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

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
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('No produce listed yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/farmer/products/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Produce Listing'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 65,
                            height: 65,
                            child: Image.network(
                              product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.surfaceSubtleGreen,
                                child: const Icon(Icons.eco, color: AppColors.primaryGreen, size: 36),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '₹${product.price.toStringAsFixed(0)} / ${product.unit}  •  Stock: ${product.stock.toStringAsFixed(0)} ${product.unit}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Category: ${product.categoryName}',
                                  style: const TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                          tooltip: 'Delete Product',
                          onPressed: () {
                            ref.read(productsProvider.notifier).deleteProduct(product.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Removed "${product.name}" from catalog')),
                            );
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
