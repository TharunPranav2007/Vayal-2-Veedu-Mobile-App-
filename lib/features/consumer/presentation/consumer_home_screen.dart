import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app/providers/products_provider.dart';
import '../../../app/providers/cart_provider.dart';

class ConsumerHomeScreen extends ConsumerStatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  ConsumerState<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends ConsumerState<ConsumerHomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Vegetables', 'Greens', 'Fruits', 'Grains'];

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final cartState = ref.watch(cartProvider);

    final filteredProducts = products.where((p) {
      final matchesCat = _selectedCategory == 'All' ||
          p.categoryName.toLowerCase().contains(_selectedCategory.toLowerCase());
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.farmerName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.agriculture_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              'Vayal 2 Veedu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, size: 26),
                onPressed: () => context.push('/consumer/cart'),
              ),
              if (cartState.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryOrange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
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
          IconButton(
            icon: const Icon(Icons.local_shipping_outlined, size: 24),
            tooltip: 'Track Active Orders',
            onPressed: () => context.push('/consumer/orders/track'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 26),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Farm Header Hero Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDarkGreen, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '🌾 100% Direct Farm Fresh',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fresh Harvest Delivered To Your Doorstep',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Zero Middlemen • Fair Pricing for Farmers',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco_rounded, color: AppColors.accentGreen, size: 44),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar & Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search organic veggies, fruits, grains...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
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
                            backgroundColor: Colors.white,
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
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // Marketplace Products Grid
          filteredProducts.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'No produce found in this category.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final p = filteredProducts[index];
                        final isInStock = p.stock > 0;

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Thumbnail Container
                              Stack(
                                children: [
                                  SizedBox(
                                    height: 110,
                                    width: double.infinity,
                                    child: Image.network(
                                      p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: AppColors.surfaceSubtleGreen,
                                        child: Center(
                                          child: Icon(
                                            p.categoryName == 'Greens'
                                                ? Icons.grass
                                                : p.categoryName == 'Fruits'
                                                    ? Icons.apple
                                                    : p.categoryName == 'Grains'
                                                        ? Icons.grain
                                                        : Icons.eco,
                                            size: 52,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ),
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: AppColors.surfaceSubtleGreen,
                                          child: const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 12),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${p.averageRating}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (!isInStock)
                                    Container(
                                      height: 110,
                                      color: Colors.black.withOpacity(0.5),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'SOLD OUT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.storefront_outlined, size: 12, color: AppColors.textMuted),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            p.farmerName,
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Stock: ${p.stock.toStringAsFixed(0)} ${p.unit}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: p.stock < 10 ? AppColors.error : AppColors.primaryLightGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '₹${p.price.toStringAsFixed(0)}/${p.unit}',
                                          style: const TextStyle(
                                            color: AppColors.primaryGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: isInStock
                                              ? () {
                                                  ref.read(cartProvider.notifier).addToCart(p);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('${p.name} added to cart!'),
                                                      duration: const Duration(milliseconds: 1200),
                                                      backgroundColor: AppColors.primaryGreen,
                                                      action: SnackBarAction(
                                                        label: 'VIEW CART',
                                                        textColor: Colors.white,
                                                        onPressed: () => context.push('/consumer/cart'),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              : null,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: isInStock ? AppColors.secondaryOrange : Colors.grey,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.add_shopping_cart,
                                              color: Colors.white,
                                              size: 16,
                                            ),
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
