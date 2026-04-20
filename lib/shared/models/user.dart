/// User Model
class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String? address;
  final String? city;
  final String? country;
  final String role; // 'admin' or 'client'
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.address,
    this.city,
    this.country,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      role: json['role'] as String? ?? 'client',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy of User with modified fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is client
  bool get isClient => role == 'client';

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role)';
  }
}
