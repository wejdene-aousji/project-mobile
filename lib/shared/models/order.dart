/// Order Model
class Order {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final String deliveryAddress;
  final String deliveryCity;
  final String? deliveryCountry;
  final List<OrderItem> items;
  final double totalAmount;
  final double taxAmount;
  final double shippingAmount;
  final String status; // 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'
  final String paymentStatus; // 'pending', 'paid', 'failed'
  final String paymentMethod; // 'cod' (cash on delivery)
  final String? notes;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.deliveryAddress,
    required this.deliveryCity,
    this.deliveryCountry,
    required this.items,
    required this.totalAmount,
    required this.taxAmount,
    required this.shippingAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.deliveredAt,
  });

  /// Create Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      clientPhone: json['client_phone'] as String,
      deliveryAddress: json['delivery_address'] as String,
      deliveryCity: json['delivery_city'] as String,
      deliveryCountry: json['delivery_country'] as String?,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      shippingAmount: (json['shipping_amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
      paymentMethod: json['payment_method'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
    );
  }

  /// Convert Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'delivery_address': deliveryAddress,
      'delivery_city': deliveryCity,
      'delivery_country': deliveryCountry,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'tax_amount': taxAmount,
      'shipping_amount': shippingAmount,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  /// Check if order is pending
  bool get isPending => status == 'pending';

  /// Check if order is confirmed
  bool get isConfirmed => status == 'confirmed';

  /// Check if order is shipped
  bool get isShipped => status == 'shipped';

  /// Check if order is delivered
  bool get isDelivered => status == 'delivered';

  /// Calculate subtotal (total - shipping)
  double get subtotal => totalAmount - shippingAmount;

  /// Alias for totalAmount (for backward compatibility)
  double get totalPrice => totalAmount;

  @override
  String toString() {
    return 'Order(id: $id, clientId: $clientId, total: $totalAmount, status: $status)';
  }
}

/// Order Item Model
class OrderItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  /// Create OrderItem from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  /// Convert OrderItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }

  /// Calculate total for this item
  double get itemTotal => unitPrice * quantity;

  @override
  String toString() {
    return 'OrderItem(productId: $productId, quantity: $quantity)';
  }
}
