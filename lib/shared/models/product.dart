/// Product Model
class Product {
  final String id;
  final String? code;
  final String name;
  final String description;
  final double? purchasePrice;
  final double? priceHT;
  final double? priceTTC;
  final double price;
  final double? discountPrice;
  final int stock;
  final String category;
  final String? imageUrl;
  final String supplierId;
  final double? rating;
  final int? reviewCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    this.code,
    required this.name,
    required this.description,
    this.purchasePrice,
    this.priceHT,
    this.priceTTC,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.category,
    this.imageUrl,
    required this.supplierId,
    this.rating,
    this.reviewCount,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    double _toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    int _toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Product(
      id: (json['id'] ?? json['productId'] ?? '').toString(),
      code: json['code']?.toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? json['code'] ?? '').toString(),
      purchasePrice: json['purchasePrice'] != null
          ? _toDouble(json['purchasePrice'])
          : null,
      priceHT: json['priceHT'] != null ? _toDouble(json['priceHT']) : null,
      priceTTC: json['priceTTC'] != null ? _toDouble(json['priceTTC']) : null,
      price: _toDouble(json['price'] ?? json['priceTTC'] ?? json['priceHT']),
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      stock: _toInt(json['stock'] ?? json['stockQuantity']),
      category: (json['category'] ?? 'General').toString(),
      imageUrl: (json['image_url'] ?? json['url']) as String?,
      supplierId: (json['supplier_id'] ?? 'UNKNOWN').toString(),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] as int?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    final numericId = int.tryParse(id);
    return {
      'id': id,
      'productId': numericId,
      'code': code,
      'name': name,
      'description': description,
      'purchasePrice': purchasePrice,
      'priceHT': priceHT,
      'priceTTC': priceTTC,
      'price': price,
      'discount_price': discountPrice,
      'stockQuantity': stock,
      'stock': stock,
      'category': category,
      'url': imageUrl,
      'image_url': imageUrl,
      'supplier_id': supplierId,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get effective price (with discount if available)
  double get effectivePrice => discountPrice ?? price;

  /// Calculate discount percentage
  double? get discountPercentage {
    if (discountPrice == null) return null;
    return ((price - discountPrice!) / price * 100);
  }

  /// Check if product is in stock
  bool get isInStock => stock > 0;

  /// Check if product has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, stock: $stock)';
  }
}
