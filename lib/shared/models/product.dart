/// Product Model
class Product {
  final String id;
  final String name;
  final String description;
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
    required this.name,
    required this.description,
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
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      stock: json['stock'] as int,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
      supplierId: json['supplier_id'] as String,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'stock': stock,
      'category': category,
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
