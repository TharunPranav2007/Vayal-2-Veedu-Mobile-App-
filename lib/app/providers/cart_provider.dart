import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/products/domain/product_model.dart';

class CartItem {
  final Product product;
  final double quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({Product? product, double? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartState {
  final Map<String, CartItem> items;

  CartState({this.items = const {}});

  int get itemCount => items.values.fold(0, (sum, i) => sum + i.quantity.toInt());

  double get subtotal => items.values.fold(0.0, (sum, i) => sum + i.totalPrice);

  double get deliveryFee => subtotal == 0 ? 0.0 : (subtotal >= 300 ? 0.0 : 30.0);

  double get taxAmount => subtotal * 0.05; // 5% GST

  double get totalAmount => subtotal + deliveryFee + taxAmount;

  CartState copyWith({Map<String, CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addToCart(Product product, {double quantity = 1.0}) {
    final currentItems = Map<String, CartItem>.from(state.items);
    if (currentItems.containsKey(product.id)) {
      final existing = currentItems[product.id]!;
      currentItems[product.id] = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      currentItems[product.id] = CartItem(product: product, quantity: quantity);
    }
    state = state.copyWith(items: currentItems);
  }

  void removeFromCart(String productId) {
    final currentItems = Map<String, CartItem>.from(state.items);
    currentItems.remove(productId);
    state = state.copyWith(items: currentItems);
  }

  void updateQuantity(String productId, double quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final currentItems = Map<String, CartItem>.from(state.items);
    if (currentItems.containsKey(productId)) {
      currentItems[productId] = currentItems[productId]!.copyWith(quantity: quantity);
      state = state.copyWith(items: currentItems);
    }
  }

  void clearCart() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
