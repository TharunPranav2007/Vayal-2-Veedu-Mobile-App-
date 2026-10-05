import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/orders/domain/order_model.dart';
import 'cart_provider.dart';
import 'products_provider.dart';

class OrdersNotifier extends StateNotifier<List<OrderModel>> {
  final Ref ref;

  OrdersNotifier(this.ref)
      : super([
          OrderModel(
            id: 'ord-101',
            orderNumber: 'ORD-8821',
            consumerId: 'cons-1',
            farmerId: 'f1',
            subtotal: 100.0,
            deliveryFee: 30.0,
            discount: 0.0,
            totalAmount: 135.0,
            status: OrderStatus.CONFIRMED,
            createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
            items: [
              OrderItemModel(
                id: 'item-1',
                productId: 'p1',
                productName: 'Country Red Organic Tomatoes',
                unitPrice: 40.0,
                quantity: 2.0,
                totalPrice: 80.0,
              ),
              OrderItemModel(
                id: 'item-2',
                productId: 'p2',
                productName: 'Fresh Farm Palak (Spinach)',
                unitPrice: 20.0,
                quantity: 1.0,
                totalPrice: 20.0,
              ),
            ],
          ),
          OrderModel(
            id: 'ord-102',
            orderNumber: 'ORD-8822',
            consumerId: 'cons-1',
            farmerId: 'f2',
            subtotal: 170.0,
            deliveryFee: 0.0,
            discount: 10.0,
            totalAmount: 168.5,
            status: OrderStatus.OUT_FOR_DELIVERY,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            items: [
              OrderItemModel(
                id: 'item-3',
                productId: 'p3',
                productName: 'Crisp Sweet Carrots',
                unitPrice: 60.0,
                quantity: 2.0,
                totalPrice: 120.0,
              ),
              OrderItemModel(
                id: 'item-4',
                productId: 'p4',
                productName: 'Organic Tanjore Bananas',
                unitPrice: 50.0,
                quantity: 1.0,
                totalPrice: 50.0,
              ),
            ],
          ),
          OrderModel(
            id: 'ord-103',
            orderNumber: 'ORD-8820',
            consumerId: 'cons-1',
            farmerId: 'f1',
            subtotal: 215.0,
            deliveryFee: 30.0,
            discount: 0.0,
            totalAmount: 255.75,
            status: OrderStatus.DELIVERED,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            items: [
              OrderItemModel(
                id: 'item-5',
                productId: 'p5',
                productName: 'Traditional Brown Rice',
                unitPrice: 85.0,
                quantity: 2.0,
                totalPrice: 170.0,
              ),
              OrderItemModel(
                id: 'item-6',
                productId: 'p7',
                productName: 'Fresh Tender Coconuts',
                unitPrice: 45.0,
                quantity: 1.0,
                totalPrice: 45.0,
              ),
            ],
          ),
          OrderModel(
            id: 'ord-104',
            orderNumber: 'ORD-8823',
            consumerId: 'cons-2',
            farmerId: 'f3',
            subtotal: 120.0,
            deliveryFee: 30.0,
            discount: 0.0,
            totalAmount: 156.0,
            status: OrderStatus.PLACED,
            createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
            items: [
              OrderItemModel(
                id: 'item-7',
                productId: 'p6',
                productName: 'Fresh Farm Bell Peppers',
                unitPrice: 75.0,
                quantity: 1.0,
                totalPrice: 75.0,
              ),
              OrderItemModel(
                id: 'item-8',
                productId: 'p7',
                productName: 'Fresh Tender Coconuts',
                unitPrice: 45.0,
                quantity: 1.0,
                totalPrice: 45.0,
              ),
            ],
          ),
        ]);

  void placeOrderFromCart({
    required String consumerId,
    required List<CartItem> cartItems,
    required double subtotal,
    required double deliveryFee,
    required double taxAmount,
    required double totalAmount,
    required String deliveryAddress,
    required String paymentMethod,
  }) {
    if (cartItems.isEmpty) return;

    final orderId = 'ord-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final orderNum = 'ORD-${(8824 + state.length)}';

    final orderItems = cartItems
        .map(
          (ci) => OrderItemModel(
            id: 'item-${ci.product.id}',
            productId: ci.product.id,
            productName: ci.product.name,
            unitPrice: ci.product.price,
            quantity: ci.quantity,
            totalPrice: ci.totalPrice,
          ),
        )
        .toList();

    // Deduct stock for each purchased product
    for (final item in cartItems) {
      ref.read(productsProvider.notifier).deductStock(item.product.id, item.quantity);
    }

    final newOrder = OrderModel(
      id: orderId,
      orderNumber: orderNum,
      consumerId: consumerId,
      farmerId: cartItems.first.product.farmerId,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: 0.0,
      totalAmount: totalAmount,
      status: OrderStatus.PLACED,
      createdAt: DateTime.now(),
      items: orderItems,
    );

    state = [newOrder, ...state];
    ref.read(cartProvider.notifier).clearCart();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    state = [
      for (final ord in state)
        if (ord.id == orderId)
          OrderModel(
            id: ord.id,
            orderNumber: ord.orderNumber,
            consumerId: ord.consumerId,
            farmerId: ord.farmerId,
            subtotal: ord.subtotal,
            deliveryFee: ord.deliveryFee,
            discount: ord.discount,
            totalAmount: ord.totalAmount,
            status: newStatus,
            createdAt: ord.createdAt,
            items: ord.items,
          )
        else
          ord,
    ];
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderModel>>((ref) {
  return OrdersNotifier(ref);
});
