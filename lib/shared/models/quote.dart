/// Quote Model
class Quote {
  final String id;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String description;
  final String deliveryAddress;
  final List<QuoteItem> items;
  final double totalAmount;
  final String status; // 'pending', 'accepted', 'rejected', 'expired'
  final String? rejectReason;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? expiresAt;

  Quote({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.description,
    required this.deliveryAddress,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.rejectReason,
    required this.createdAt,
    this.respondedAt,
    this.expiresAt,
  });

  /// Create Quote from JSON
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      clientEmail: json['client_email'] as String,
      clientPhone: json['client_phone'] as String,
      description: json['description'] as String? ?? '',
      deliveryAddress: json['delivery_address'] as String? ?? '',
      items: (json['items'] as List?)
          ?.map((item) => QuoteItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      rejectReason: json['reject_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Convert Quote to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'description': description,
      'delivery_address': deliveryAddress,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'reject_reason': rejectReason,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Getters for screen compatibility
  DateTime get requestDate => createdAt;
  double get quotedPrice => totalAmount;
  DateTime? get expiryDate => expiresAt;

  /// Check if quote is pending
  bool get isPending => status == 'pending';

  /// Check if quote is accepted
  bool get isAccepted => status == 'accepted';

  /// Check if quote is rejected
  bool get isRejected => status == 'rejected';

  /// Check if quote is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  @override
  String toString() {
    return 'Quote(id: $id, clientId: $clientId, status: $status)';
  }
}

/// Quote Item Model
class QuoteItem {
  final String productId;
  final String productName;
  final int quantity;
  final String specifications;

  QuoteItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.specifications,
  });

  /// Create QuoteItem from JSON
  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      specifications: json['specifications'] as String,
    );
  }

  /// Convert QuoteItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'specifications': specifications,
    };
  }

  @override
  String toString() {
    return 'QuoteItem(productId: $productId, quantity: $quantity)';
  }
}
