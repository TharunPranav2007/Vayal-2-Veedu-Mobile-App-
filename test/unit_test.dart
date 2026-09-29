import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vayal2veedu/app/providers/cart_provider.dart';
import 'package:vayal2veedu/app/providers/products_provider.dart';
import 'package:vayal2veedu/app/providers/orders_provider.dart';
import 'package:vayal2veedu/features/products/domain/product_model.dart';
import 'package:vayal2veedu/features/orders/domain/order_model.dart';

void main() {
  group('ProductsNotifier Unit Tests', () {
    test('Initial products list contains default items', () {
      final container = ProviderContainer();
      final products = container.read(productsProvider);

      expect(products.isNotEmpty, true);
      expect(products.first.name, 'Country Organic Tomatoes');
    });

    test('Add Product appends new item to products list', () {
      final container = ProviderContainer();
      final newProduct = Product(
        id: 'test-p1',
        farmerId: 'f1',
        farmerName: 'Test Farm',
        categoryId: 'c1',
        categoryName: 'Vegetables',
        name: 'Test Organic Pepper',
        description: 'Test description',
        price: 50.0,
        unit: 'kg',
        stock: 10.0,
      );

      container.read(productsProvider.notifier).addProduct(newProduct);
      final products = container.read(productsProvider);

      expect(products.first.id, 'test-p1');
      expect(products.first.name, 'Test Organic Pepper');
    });

    test('Deduct Stock reduces available inventory stock', () {
      final container = ProviderContainer();
      final initialStock = container.read(productsProvider).firstWhere((p) => p.id == 'p1').stock;

      container.read(productsProvider.notifier).deductStock('p1', 5.0);
      final updatedStock = container.read(productsProvider).firstWhere((p) => p.id == 'p1').stock;

      expect(updatedStock, initialStock - 5.0);
    });
  });

  group('CartNotifier Unit Tests', () {
    test('Add item to cart updates total calculation & GST', () {
      final container = ProviderContainer();
      final product = Product(
        id: 'cart-p1',
        farmerId: 'f1',
        farmerName: 'Farm',
        categoryId: 'c1',
        categoryName: 'Vegetables',
        name: 'Organic Carrots',
        description: 'Fresh',
        price: 100.0,
        unit: 'kg',
        stock: 20.0,
      );

      container.read(cartProvider.notifier).addToCart(product, quantity: 2.0);
      final cart = container.read(cartProvider);

      expect(cart.itemCount, 2);
      expect(cart.subtotal, 200.0);
      expect(cart.taxAmount, 10.0); // 5% GST on 200
      expect(cart.totalAmount, 240.0); // 200 + 10 GST + 30 Delivery Fee
    });

    test('Clear Cart resets cart state to empty', () {
      final container = ProviderContainer();
      final product = Product(
        id: 'cart-p2',
        farmerId: 'f1',
        farmerName: 'Farm',
        categoryId: 'c1',
        categoryName: 'Vegetables',
        name: 'Organic Tomatoes',
        description: 'Fresh',
        price: 40.0,
        unit: 'kg',
        stock: 10.0,
      );

      container.read(cartProvider.notifier).addToCart(product);
      container.read(cartProvider.notifier).clearCart();

      final cart = container.read(cartProvider);
      expect(cart.items.isEmpty, true);
      expect(cart.totalAmount, 0.0);
    });
  });

  group('OrdersNotifier Unit Tests', () {
    test('Update Order Status transitions status cleanly', () {
      final container = ProviderContainer();
      final initialOrders = container.read(ordersProvider);
      final orderId = initialOrders.first.id;

      container.read(ordersProvider.notifier).updateOrderStatus(orderId, OrderStatus.DELIVERED);
      final updatedOrder = container.read(ordersProvider).firstWhere((o) => o.id == orderId);

      expect(updatedOrder.status, OrderStatus.DELIVERED);
    });
  });
}
