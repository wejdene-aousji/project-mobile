import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/mock_api_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/models/product.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'admin', 'user'
  final DateTime createdAt;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String? ?? 'user',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AdminProvider extends ChangeNotifier {
  late ApiService _apiService;
  final MockApiService _mockApiService = MockApiService();

  // Data lists
  List<Order> _orders = [];
  List<Quote> _quotes = [];
  List<Product> _products = [];
  List<AdminUser> _users = [];

  // State
  bool _isLoading = false;
  String? _error;
  
  // Statistics
  Map<String, dynamic> _stats = {};

  AdminProvider() {
    _apiService = ServiceLocator.apiService;
  }

  // Getters
  List<Order> get orders => _orders;
  List<Quote> get quotes => _quotes;
  List<Product> get products => _products;
  List<AdminUser> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;

  // ============ Orders Management ============
  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        _orders = await _mockApiService.fetchAllOrders();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/orders',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final List<dynamic> ordersJson = response.data is List
            ? response.data
            : response.data['orders'] ?? response.data['data'] ?? [];

        _orders = ordersJson
            .map((json) => Order.fromJson(json as Map<String, dynamic>))
            .toList();
        _error = null;
      } else {
        _error = response.error ?? 'Failed to fetch orders';
      }
    } catch (e) {
      _error = 'Error fetching orders: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      if (AppConfig.useMockApi) {
        final success = await _mockApiService.updateOrderStatus(orderId, newStatus);
        if (!success) {
          _error = 'Failed to update order status';
          return false;
        }
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          final order = _orders[index];
          _orders[index] = Order(
            id: order.id,
            clientId: order.clientId,
            clientName: order.clientName,
            clientPhone: order.clientPhone,
            deliveryAddress: order.deliveryAddress,
            deliveryCity: order.deliveryCity,
            deliveryCountry: order.deliveryCountry,
            items: order.items,
            totalAmount: order.totalAmount,
            taxAmount: order.taxAmount,
            shippingAmount: order.shippingAmount,
            status: newStatus,
            paymentStatus: order.paymentStatus,
            paymentMethod: order.paymentMethod,
            notes: order.notes,
            createdAt: order.createdAt,
            deliveredAt: newStatus == 'delivered' ? DateTime.now() : order.deliveredAt,
          );
        }
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/admin/orders/$orderId/status',
        body: {'status': newStatus},
        fromJson: (json) => json,
      );

      if (response.success) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = Order.fromJson(response.data is Map
              ? response.data
              : response.data['order'] ?? response.data['data']);
        }
        return true;
      } else {
        _error = response.error ?? 'Failed to update order status';
        return false;
      }
    } catch (e) {
      _error = 'Error updating order: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  // ============ Quotes Management ============
  Future<void> fetchAllQuotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        _quotes = await _mockApiService.fetchAllQuotes();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/quotes',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final List<dynamic> quotesJson = response.data is List
            ? response.data
            : response.data['quotes'] ?? response.data['data'] ?? [];

        _quotes = quotesJson
            .map((json) => Quote.fromJson(json as Map<String, dynamic>))
            .toList();
        _error = null;
      } else {
        _error = response.error ?? 'Failed to fetch quotes';
      }
    } catch (e) {
      _error = 'Error fetching quotes: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addQuotePrice(String quoteId, double price, DateTime? expiryDate) async {
    try {
      if (AppConfig.useMockApi) {
        final success = await _mockApiService.addQuotePrice(quoteId, price, expiryDate);
        if (!success) {
          _error = 'Failed to add quote price';
          return false;
        }
        final index = _quotes.indexWhere((q) => q.id == quoteId);
        if (index != -1) {
          final quote = _quotes[index];
          _quotes[index] = Quote(
            id: quote.id,
            clientId: quote.clientId,
            clientName: quote.clientName,
            clientEmail: quote.clientEmail,
            clientPhone: quote.clientPhone,
            description: quote.description,
            deliveryAddress: quote.deliveryAddress,
            items: quote.items,
            totalAmount: price,
            status: quote.status,
            rejectReason: quote.rejectReason,
            createdAt: quote.createdAt,
            respondedAt: DateTime.now(),
            expiresAt: expiryDate,
          );
        }
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/admin/quotes/$quoteId/price',
        body: {
          'quoted_price': price,
          'expires_at': expiryDate?.toIso8601String(),
        },
        fromJson: (json) => json,
      );

      if (response.success) {
        final index = _quotes.indexWhere((q) => q.id == quoteId);
        if (index != -1) {
          _quotes[index] = Quote.fromJson(response.data is Map
              ? response.data
              : response.data['quote'] ?? response.data['data']);
        }
        return true;
      } else {
        _error = response.error ?? 'Failed to add quote price';
        return false;
      }
    } catch (e) {
      _error = 'Error adding quote price: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  // ============ Products Management ============
  Future<void> fetchAllProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        _products = await _mockApiService.fetchAllProducts();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/products',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final List<dynamic> productsJson = response.data is List
            ? response.data
            : response.data['products'] ?? response.data['data'] ?? [];

        _products = productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
        _error = null;
      } else {
        _error = response.error ?? 'Failed to fetch products';
      }
    } catch (e) {
      _error = 'Error fetching products: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    String? category,
  }) async {
    try {
      if (AppConfig.useMockApi) {
        final success = await _mockApiService.createProduct(
          name: name,
          description: description,
          price: price,
          stock: stock,
          category: category,
        );
        if (!success) {
          _error = 'Failed to create product';
          return false;
        }
        _products = await _mockApiService.fetchAllProducts();
        _error = null;
        return true;
      }

      final response = await _apiService.post(
        '/admin/products',
        body: {
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category': category,
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final newProduct = Product.fromJson(response.data is Map
            ? response.data
            : response.data['product'] ?? response.data['data']);
        _products.add(newProduct);
        return true;
      } else {
        _error = response.error ?? 'Failed to create product';
        return false;
      }
    } catch (e) {
      _error = 'Error creating product: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? category,
  }) async {
    try {
      if (AppConfig.useMockApi) {
        final success = await _mockApiService.updateProduct(
          productId: productId,
          name: name,
          description: description,
          price: price,
          stock: stock,
          category: category,
        );
        if (!success) {
          _error = 'Failed to update product';
          return false;
        }
        _products = await _mockApiService.fetchAllProducts();
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/admin/products/$productId',
        body: {
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category': category,
        },
        fromJson: (json) => json,
      );

      if (response.success) {
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = Product.fromJson(response.data is Map
              ? response.data
              : response.data['product'] ?? response.data['data']);
        }
        return true;
      } else {
        _error = response.error ?? 'Failed to update product';
        return false;
      }
    } catch (e) {
      _error = 'Error updating product: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      if (AppConfig.useMockApi) {
        final success = await _mockApiService.deleteProduct(productId);
        if (!success) {
          _error = 'Failed to delete product';
          return false;
        }
        _products.removeWhere((p) => p.id == productId);
        _error = null;
        return true;
      }

      final response = await _apiService.delete(
        '/admin/products/$productId',
        fromJson: (json) => json,
      );

      if (response.success) {
        _products.removeWhere((p) => p.id == productId);
        return true;
      } else {
        _error = response.error ?? 'Failed to delete product';
        return false;
      }
    } catch (e) {
      _error = 'Error deleting product: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  // ============ Users Management ============
  Future<void> fetchAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        _users = [
          AdminUser(
            id: 'USR001',
            name: 'System Admin',
            email: 'admin@test.com',
            phone: '+1-555-0001',
            role: 'admin',
            createdAt: DateTime.now().subtract(Duration(days: 100)),
          ),
          AdminUser(
            id: 'USR002',
            name: 'Client User',
            email: 'user@test.com',
            phone: '+1-555-0002',
            role: 'user',
            createdAt: DateTime.now().subtract(Duration(days: 40)),
          ),
        ];
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/users',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final List<dynamic> usersJson = response.data is List
            ? response.data
            : response.data['users'] ?? response.data['data'] ?? [];

        _users = usersJson
            .map((json) => AdminUser.fromJson(json as Map<String, dynamic>))
            .toList();
        _error = null;
      } else {
        _error = response.error ?? 'Failed to fetch users';
      }
    } catch (e) {
      _error = 'Error fetching users: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteUser(String userId) async {
    try {
      if (AppConfig.useMockApi) {
        _users.removeWhere((u) => u.id == userId);
        _error = null;
        return true;
      }

      final response = await _apiService.delete(
        '/admin/users/$userId',
        fromJson: (json) => json,
      );

      if (response.success) {
        _users.removeWhere((u) => u.id == userId);
        return true;
      } else {
        _error = response.error ?? 'Failed to delete user';
        return false;
      }
    } catch (e) {
      _error = 'Error deleting user: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  // ============ Statistics ============
  Future<void> fetchStatistics() async {
    try {
      if (AppConfig.useMockApi) {
        _stats = _calculateLocalStats();
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/statistics',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        _stats = response.data is Map ? response.data : {};
      } else {
        // Calculate from local data if API fails
        _stats = _calculateLocalStats();
      }
    } catch (e) {
      // Calculate from local data if error
      _stats = _calculateLocalStats();
    }
    notifyListeners();
  }

  Map<String, dynamic> _calculateLocalStats() {
    final totalOrders = _orders.length;
    final totalQuotes = _quotes.length;
    final totalProducts = _products.length;
    final totalUsers = _users.length;

    final pendingOrders = _orders.where((o) => o.status == 'pending').length;
    final pendingQuotes = _quotes.where((q) => q.status == 'pending').length;

    final totalRevenue = _orders
        .where((o) => o.status == 'delivered')
        .fold<double>(0, (sum, o) => sum + o.totalAmount);

    return {
      'total_orders': totalOrders,
      'total_quotes': totalQuotes,
      'total_products': totalProducts,
      'total_users': totalUsers,
      'pending_orders': pendingOrders,
      'pending_quotes': pendingQuotes,
      'total_revenue': totalRevenue,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
