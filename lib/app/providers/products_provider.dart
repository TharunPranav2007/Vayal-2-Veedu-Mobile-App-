import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/products/domain/product_model.dart';

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier()
      : super([
          Product(
            id: 'p1',
            farmerId: 'f1',
            farmerName: 'Green Field Farm',
            categoryId: 'c1',
            categoryName: 'Vegetables',
            name: 'Country Organic Tomatoes',
            description: 'Fresh farm-picked red ripe organic tomatoes from local fields.',
            price: 40.0,
            unit: 'kg',
            stock: 120.0,
            averageRating: 4.8,
            totalReviews: 24,
            imageUrls: ['https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500'],
          ),
          Product(
            id: 'p2',
            farmerId: 'f2',
            farmerName: 'Vayal Fresh Produce',
            categoryId: 'c2',
            categoryName: 'Greens',
            name: 'Fresh Organic Palak (Spinach)',
            description: 'Chemical & pesticide-free fresh green leafy spinach harvested this morning.',
            price: 25.0,
            unit: 'bunch',
            stock: 45.0,
            averageRating: 4.9,
            totalReviews: 12,
            imageUrls: ['https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500'],
          ),
          Product(
            id: 'p3',
            farmerId: 'f1',
            farmerName: 'Green Field Farm',
            categoryId: 'c1',
            categoryName: 'Vegetables',
            name: 'Crisp Sweet Carrots',
            description: 'Rich in Beta-Carotene, freshly dug sweet orange farm carrots.',
            price: 60.0,
            unit: 'kg',
            stock: 80.0,
            averageRating: 4.7,
            totalReviews: 18,
            imageUrls: ['https://images.unsplash.com/photo-1598170845058-12ef4a457939?w=500'],
          ),
          Product(
            id: 'p4',
            farmerId: 'f3',
            farmerName: 'Kaveri River Farms',
            categoryId: 'c3',
            categoryName: 'Fruits',
            name: 'Sweet Farm Bananas',
            description: 'Naturally ripened Cavendish organic bananas from Tanjore groves.',
            price: 50.0,
            unit: 'dozen',
            stock: 35.0,
            averageRating: 4.6,
            totalReviews: 9,
            imageUrls: ['https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500'],
          ),
          Product(
            id: 'p5',
            farmerId: 'f2',
            farmerName: 'Vayal Fresh Produce',
            categoryId: 'c4',
            categoryName: 'Grains',
            name: 'Traditional Brown Rice',
            description: 'Unpolished traditional healthy rice harvested directly from local paddies.',
            price: 85.0,
            unit: 'kg',
            stock: 200.0,
            averageRating: 5.0,
            totalReviews: 31,
            imageUrls: ['https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500'],
          ),
        ]);

  void addProduct(Product product) {
    state = [product, ...state];
  }

  void updateProduct(Product updatedProduct) {
    state = [
      for (final p in state)
        if (p.id == updatedProduct.id) updatedProduct else p,
    ];
  }

  void deleteProduct(String productId) {
    state = state.where((p) => p.id != productId).toList();
  }

  void deductStock(String productId, double quantity) {
    state = [
      for (final p in state)
        if (p.id == productId)
          Product(
            id: p.id,
            farmerId: p.farmerId,
            farmerName: p.farmerName,
            categoryId: p.categoryId,
            categoryName: p.categoryName,
            name: p.name,
            description: p.description,
            price: p.price,
            unit: p.unit,
            stock: (p.stock - quantity) < 0 ? 0.0 : p.stock - quantity,
            isPublished: p.isPublished,
            averageRating: p.averageRating,
            totalReviews: p.totalReviews,
            imageUrls: p.imageUrls,
          )
        else
          p,
    ];
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier();
});
