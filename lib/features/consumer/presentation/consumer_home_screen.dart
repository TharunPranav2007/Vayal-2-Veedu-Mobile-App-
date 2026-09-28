import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../products/domain/product_model.dart';

class ConsumerHomeScreen extends ConsumerStatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  ConsumerState<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends ConsumerState<ConsumerHomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Vegetables', 'Greens', 'Fruits', 'Grains'];

  final List<Product> _products = [
    Product(
      id: 'p1',
      farmerId: 'f1',
      farmerName: 'Green Field Farm',
      categoryId: 'c1',
      categoryName: 'Vegetables',
      name: 'Country Tomatoes',
      description: 'Fresh farm-picked organic tomatoes',
      price: 40.0,
      unit: 'kg',
      stock: 100.0,
      averageRating: 4.8,
      totalReviews: 24,
    ),
    Product(
      id: 'p2',
      farmerId: 'f2',
      farmerName: 'Vayal Fresh Produce',
      categoryId: 'c2',
      categoryName: 'Greens',
      name: 'Organic Palak (Spinach)',
      description: 'Pesticide free leafy spinach',
      price: 25.0,
      unit: 'bunch',
      stock: 45.0,
      averageRating: 4.9,
      totalReviews: 12,
    ),
    Product(
      id: 'p3',
      farmerId: 'f1',
      farmerName: 'Green Field Farm',
      categoryId: 'c1',
      categoryName: 'Vegetables',
      name: 'Fresh Carrots',
      description: 'Crisp orange organic carrots',
      price: 60.0,
      unit: 'kg',
      stock: 50.0,
      averageRating: 4.7,
      totalReviews: 18,
    ),
    Product(
      id: 'p4',
      farmerId: 'f3',
      farmerName: 'Kaveri River Farms',
      categoryId: 'c3',
      categoryName: 'Fruits',
      name: 'Sweet Farm Bananas',
      description: 'Naturally ripened Cavendish bananas',
      price: 50.0,
      unit: 'dozen',
      stock: 30.0,
      averageRating: 4.6,
      totalReviews: 9,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((p) {
      final matchesCat = _selectedCategory == 'All' || p.categoryName == _selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vayal 2 Veedu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/consumer/cart'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search & Filter Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search fresh produce or local farms...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                      suffixIcon: const Icon(Icons.tune, color: AppColors.primaryGreen),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppColors.primaryGreen,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textDark,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Product Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final p = filteredProducts[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 110,
                          color: AppColors.surfaceSubtleGreen,
                          child: const Center(
                            child: Icon(Icons.eco_rounded, size: 48, color: AppColors.primaryGreen),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.farmerName,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${p.averageRating} (${p.totalReviews})',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${p.price}/${p.unit}',
                                    style: const TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${p.name} added to cart!'),
                                          duration: const Duration(seconds: 1),
                                          backgroundColor: AppColors.primaryGreen,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryOrange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: filteredProducts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
