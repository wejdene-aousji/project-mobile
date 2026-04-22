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
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    final lines = (json['orderLines'] as List?) ?? (json['items'] as List?) ?? const [];
    final createdAtRaw = json['createdAt'] ?? json['created_at'];
    final deliveredAtRaw = json['deliveredAt'] ?? json['delivered_at'];
    final rawStatus = (json['status'] ?? 'pending').toString();

    return Order(
      id: (json['id'] ?? json['orderId'] ?? '').toString(),
      clientId: (json['client_id'] ?? user['userId'] ?? '').toString(),
      clientName: (json['client_name'] ?? user['fullName'] ?? 'Unknown Customer').toString(),
      clientPhone: (json['client_phone'] ?? user['phone'] ?? '').toString(),
      deliveryAddress: (json['delivery_address'] ?? 'N/A').toString(),
      deliveryCity: (json['delivery_city'] ?? 'N/A').toString(),
      deliveryCountry: (json['delivery_country'] ?? '').toString().isEmpty
          ? null
          : (json['delivery_country'] ?? '').toString(),
      items: lines
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: toDouble(json['total_amount'] ?? json['totalPrice']),
      taxAmount: toDouble(json['tax_amount'] ?? 0),
      shippingAmount: toDouble(json['shipping_amount'] ?? 0),
      status: rawStatus.toLowerCase(),
      paymentStatus: (json['payment_status'] ?? 'paid').toString().toLowerCase(),
      paymentMethod: (json['payment_method'] ?? json['paymentMethod'] ?? 'unknown').toString().toLowerCase(),
      notes: json['notes'] as String?,
      createdAt: createdAtRaw is String
          ? (DateTime.tryParse(createdAtRaw) ?? DateTime.now())
          : DateTime.now(),
      deliveredAt: deliveredAtRaw != null
          ? DateTime.tryParse(deliveredAtRaw.toString())
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
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final product = (json['product'] as Map<String, dynamic>?) ?? const {};

    return OrderItem(
      productId: (json['product_id'] ?? product['productId'] ?? '').toString(),
      productName: (json['product_name'] ?? product['name'] ?? 'Unknown Product').toString(),
      unitPrice: toDouble(json['unit_price'] ?? json['unitPrice']),
      quantity: toInt(json['quantity']),
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
