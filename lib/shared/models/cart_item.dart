/// Cart Item Model
class CartItem {
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final String? productImage;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    this.productImage,
  });

  /// Calculate total price for this item
  double get totalPrice => productPrice * quantity;

  /// Create a copy with modified fields
  CartItem copyWith({
    String? productId,
    String? productName,
    double? productPrice,
    int? quantity,
    String? productImage,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      quantity: quantity ?? this.quantity,
      productImage: productImage ?? this.productImage,
    );
  }

  @override
  String toString() {
    return 'CartItem(productId: $productId, quantity: $quantity, total: $totalPrice)';
  }
}
