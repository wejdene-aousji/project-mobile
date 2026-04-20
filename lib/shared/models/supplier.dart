/// Supplier Model
class Supplier {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String? country;
  final String? website;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Supplier({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    this.country,
    this.website,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create Supplier from JSON
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Supplier to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'website': website,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Supplier(id: $id, name: $name, email: $email)';
  }
}
