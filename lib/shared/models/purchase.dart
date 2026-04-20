/// Purchase Model (for admin)
class Purchase {
  final String id;
  final String supplierId;
  final String supplierName;
  final List<PurchaseItem> items;
  final double totalAmount;
  final String status; // 'pending', 'received', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime? receivedAt;

  Purchase({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    this.receivedAt,
  });

  /// Create Purchase from JSON
  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      supplierId: json['supplier_id'] as String,
      supplierName: json['supplier_name'] as String,
      items: (json['items'] as List)
          .map((item) => PurchaseItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'] as String)
          : null,
    );
  }

  /// Convert Purchase to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'received_at': receivedAt?.toIso8601String(),
    };
  }

  /// Check if purchase is pending
  bool get isPending => status == 'pending';

  /// Check if purchase is received
  bool get isReceived => status == 'received';

  @override
  String toString() {
    return 'Purchase(id: $id, supplierId: $supplierId, total: $totalAmount)';
  }
}

/// Purchase Item Model
class PurchaseItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitCost;

  PurchaseItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitCost,
  });

  /// Create PurchaseItem from JSON
  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      unitCost: (json['unit_cost'] as num).toDouble(),
    );
  }

  /// Convert PurchaseItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_cost': unitCost,
    };
  }

  /// Calculate total for this item
  double get itemTotal => unitCost * quantity;

  @override
  String toString() {
    return 'PurchaseItem(productId: $productId, quantity: $quantity)';
  }
}
