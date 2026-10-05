enum OrderStatus {
  PLACED,
  CONFIRMED,
  PREPARING,
  READY_FOR_PICKUP,
  PICKED_UP,
  OUT_FOR_DELIVERY,
  DELIVERED,
  CANCELLED,
}

OrderStatus orderStatusFromString(String statusStr) {
  switch (statusStr.toUpperCase()) {
    case 'PLACED':
      return OrderStatus.PLACED;
    case 'CONFIRMED':
      return OrderStatus.CONFIRMED;
    case 'PREPARING':
      return OrderStatus.PREPARING;
    case 'READY_FOR_PICKUP':
      return OrderStatus.READY_FOR_PICKUP;
    case 'PICKED_UP':
      return OrderStatus.PICKED_UP;
    case 'OUT_FOR_DELIVERY':
      return OrderStatus.OUT_FOR_DELIVERY;
    case 'DELIVERED':
      return OrderStatus.DELIVERED;
    case 'CANCELLED':
      return OrderStatus.CANCELLED;
    default:
      return OrderStatus.PLACED;
  }
}

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final double unitPrice;
  final double quantity;
  final double totalPrice;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      unitPrice: (json['unitPrice'] is String) ? double.parse(json['unitPrice']) : (json['unitPrice'] as num).toDouble(),
      quantity: (json['quantity'] is String) ? double.parse(json['quantity']) : (json['quantity'] as num).toDouble(),
      totalPrice: (json['totalPrice'] is String) ? double.parse(json['totalPrice']) : (json['totalPrice'] as num).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String consumerId;
  final String farmerId;
  final String farmName;
  final String farmerName;
  final String farmerPhone;
  final String? cancellationReason;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.consumerId,
    required this.farmerId,
    this.farmName = 'Green Field Organic Farm, Madurai',
    this.farmerName = 'M. Ramanathan (Organic Farmer)',
    this.farmerPhone = '+91 98421 54321',
    this.cancellationReason,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? 'ORD-0000',
      consumerId: json['consumerId'] as String? ?? '',
      farmerId: json['farmerId'] as String? ?? '',
      farmName: json['farmName'] as String? ?? 'Green Field Organic Farm, Madurai',
      farmerName: json['farmerName'] as String? ?? 'M. Ramanathan (Organic Farmer)',
      farmerPhone: json['farmerPhone'] as String? ?? '+91 98421 54321',
      cancellationReason: json['cancellationReason'] as String?,
      subtotal: (json['subtotal'] is String) ? double.parse(json['subtotal']) : (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] is String) ? double.parse(json['deliveryFee']) : (json['deliveryFee'] as num).toDouble(),
      discount: (json['discount'] is String) ? double.parse(json['discount']) : (json['discount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] is String) ? double.parse(json['totalAmount']) : (json['totalAmount'] as num).toDouble(),
      status: orderStatusFromString(json['status'] as String? ?? 'PLACED'),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
