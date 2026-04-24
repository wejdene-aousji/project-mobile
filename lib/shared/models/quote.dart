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
    String asString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      final text = value.toString();
      return text.isEmpty ? fallback : text;
    }

    DateTime parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    final statusRaw = asString(json['status'], fallback: 'PENDING');

    // Support server responses that use either 'items' or 'quoteLines'
    final rawLines = (json['quoteLines'] as List?) ?? (json['items'] as List?) ?? const [];

    return Quote(
      id: asString(json['id'] ?? json['quoteId']),
      clientId: asString(json['client_id'] ?? user['userId']),
      clientName: asString(json['client_name'] ?? user['fullName'], fallback: 'Unknown Client'),
      clientEmail: asString(json['client_email'] ?? user['email']),
      clientPhone: asString(json['client_phone'] ?? user['phone']),
      description: asString(json['description'] ?? json['message']),
      deliveryAddress: asString(json['delivery_address']),
      items: rawLines
        .map((item) => QuoteItem.fromJson(item as Map<String, dynamic>))
        .toList(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? (json['quotedPrice'] as num?)?.toDouble() ?? 0.0,
      status: statusRaw.toLowerCase(),
      rejectReason: json['reject_reason'] as String?,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      respondedAt: json['responded_at'] != null
        ? parseDate(json['responded_at'])
        : null,
      expiresAt: json['expires_at'] != null
        ? parseDate(json['expires_at'])
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
    // Support nested 'product' object (quoteLines) or flat fields (items)
    String pid = '';
    String pname = '';
    if (json['product'] != null && json['product'] is Map) {
      final p = json['product'] as Map<String, dynamic>;
      pid = (p['productId'] ?? p['product_id'] ?? p['id'])?.toString() ?? '';
      pname = (p['name'] ?? p['product_name'] ?? '')?.toString() ?? '';
    } else {
      pid = (json['product_id'] ?? json['productId'] ?? '')?.toString() ?? '';
      pname = (json['product_name'] ?? json['name'] ?? '')?.toString() ?? '';
    }

    int qty = 0;
    final q = json['quantity'] ?? json['qty'] ?? json['amount'];
    if (q is int) qty = q;
    else if (q is num) qty = q.toInt();
    else qty = int.tryParse(q?.toString() ?? '') ?? 0;

    final specs = (json['specifications'] ?? json['specs'] ?? '')?.toString() ?? '';

    return QuoteItem(
      productId: pid,
      productName: pname,
      quantity: qty,
      specifications: specs,
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
