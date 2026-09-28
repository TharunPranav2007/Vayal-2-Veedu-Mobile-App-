class Product {
  final String id;
  final String farmerId;
  final String farmerName;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final double price;
  final String unit;
  final double stock;
  final bool isPublished;
  final double averageRating;
  final int totalReviews;
  final List<String> imageUrls;

  Product({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stock,
    this.isPublished = true,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.imageUrls = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String? ?? '',
      farmerName: json['farmer']?['farmName'] as String? ?? json['farmerName'] as String? ?? 'Local Farmer',
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['category']?['name'] as String? ?? json['categoryName'] as String? ?? 'Fresh Produce',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] is String) ? double.parse(json['price']) : (json['price'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'kg',
      stock: (json['stock'] is String) ? double.parse(json['stock']) : (json['stock'] as num).toDouble(),
      isPublished: json['isPublished'] as bool? ?? true,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      imageUrls: (json['images'] as List<dynamic>?)
              ?.map((img) => img['url'] as String)
              .toList() ??
          (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'stock': stock,
      'isPublished': isPublished,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'imageUrls': imageUrls,
    };
  }
}
