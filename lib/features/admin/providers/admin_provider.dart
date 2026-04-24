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
  final String? password;
  final String phone;
  final String role;
  final DateTime createdAt;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'] ?? json['createdAt'];
    return AdminUser(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      password: json['password']?.toString(),
      phone: (json['phone'] ?? '').toString(),
      role: (json['role'] ?? 'CLIENT').toString(),
      createdAt: createdRaw is String
          ? (DateTime.tryParse(createdRaw) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final numericId = int.tryParse(id);
    return {
      'id': id,
      'userId': numericId,
      'name': name,
      'fullName': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AdminSupplier {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;

  AdminSupplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory AdminSupplier.fromJson(Map<String, dynamic> json) {
    return AdminSupplier(
      id: (json['id'] ?? json['supplierId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final numericId = int.tryParse(id);
    return {
      'supplierId': numericId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}

class AdminPurchaseLine {
  final String id;
  final int quantity;
  final double unitCost;
  final double subtotal;
  final Product product;

  AdminPurchaseLine({
    required this.id,
    required this.quantity,
    required this.unitCost,
    required this.subtotal,
    required this.product,
  });

  factory AdminPurchaseLine.fromJson(Map<String, dynamic> json) {
    final quantity = json['quantity'] is int
        ? json['quantity'] as int
        : int.tryParse('${json['quantity']}') ?? 0;
    final unitCost = json['unitCost'] is num
        ? (json['unitCost'] as num).toDouble()
        : double.tryParse('${json['unitCost']}') ?? 0;
    final subtotal = json['subtotal'] is num
        ? (json['subtotal'] as num).toDouble()
        : double.tryParse('${json['subtotal']}') ?? (quantity * unitCost).toDouble();

    return AdminPurchaseLine(
      id: (json['purchaseLineId'] ?? json['id'] ?? '').toString(),
      quantity: quantity,
      unitCost: unitCost,
      subtotal: subtotal,
      product: Product.fromJson((json['product'] ?? <String, dynamic>{}) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    final numericLineId = int.tryParse(id);
    return {
      if (numericLineId != null) 'purchaseLineId': numericLineId,
      'quantity': quantity,
      'unitCost': unitCost,
      'subtotal': subtotal,
      'product': product.toJson(),
    };
  }
}

class AdminPurchase {
  final String id;
  final double totalCost;
  final DateTime purchaseDate;
  final List<AdminPurchaseLine> lines;
  final AdminSupplier supplier;

  AdminPurchase({
    required this.id,
    required this.totalCost,
    required this.purchaseDate,
    required this.lines,
    required this.supplier,
  });

  factory AdminPurchase.fromJson(Map<String, dynamic> json) {
    final totalCost = json['totalCost'] is num
        ? (json['totalCost'] as num).toDouble()
        : double.tryParse('${json['totalCost']}') ?? 0;

    final purchaseDateRaw = json['purchaseDate']?.toString();
    final purchaseDate = purchaseDateRaw != null
        ? DateTime.tryParse(purchaseDateRaw) ?? DateTime.now()
        : DateTime.now();

    final linesJson = (json['lines'] as List?) ?? const [];

    return AdminPurchase(
      id: (json['purchaseId'] ?? json['id'] ?? '').toString(),
      totalCost: totalCost,
      purchaseDate: purchaseDate,
      lines: linesJson
          .map((line) => AdminPurchaseLine.fromJson(line as Map<String, dynamic>))
          .toList(),
      supplier: AdminSupplier.fromJson((json['supplier'] ?? <String, dynamic>{}) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    final numericPurchaseId = int.tryParse(id);
    return {
      if (numericPurchaseId != null) 'purchaseId': numericPurchaseId,
      'totalCost': totalCost,
      'purchaseDate': purchaseDate.toIso8601String().split('T').first,
      'lines': lines.map((line) => line.toJson()).toList(),
      'supplier': supplier.toJson(),
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
  List<AdminSupplier> _suppliers = [];
  List<AdminPurchase> _purchases = [];

  // State
  bool _isLoading = false;
  String? _error;
  
  // Statistics
  Map<String, dynamic> _stats = {};
  Map<String, int> _topProductsStats = {};
  Map<String, int> _lowProductsStats = {};
  Map<String, int> _dailySalesStats = {};
  Map<String, double> _dailyRevenueStats = {};
  double _periodRevenue = 0;

  AdminProvider() {
    _apiService = ServiceLocator.apiService;
  }

  // Getters
  List<Order> get orders => _orders;
  List<Quote> get quotes => _quotes;
  List<Product> get products => _products;
  List<AdminUser> get users => _users;
  List<AdminSupplier> get suppliers => _suppliers;
  List<AdminPurchase> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;
  Map<String, int> get topProductsStats => _topProductsStats;
  Map<String, int> get lowProductsStats => _lowProductsStats;
  Map<String, int> get dailySalesStats => _dailySalesStats;
  Map<String, double> get dailyRevenueStats => _dailyRevenueStats;
  double get periodRevenue => _periodRevenue;

  // ============ Orders Management ============
  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi && !AppConfig.useRealSalesApi) {
        _orders = await _mockApiService.fetchAllOrders();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/sales',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final List<dynamic> ordersJson = response.data is List
            ? response.data
            : response.data['sales'] ?? response.data['orders'] ?? response.data['data'] ?? [];

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

  Future<bool> createSale({
    required String userId,
    required List<OrderItem> lines,
  }) async {
    return _createSaleAtEndpoint(
      endpoint: '/admin/sales',
      userId: userId,
      lines: lines,
    );
  }

  Future<bool> createInStoreSale({
    required String userId,
    required List<OrderItem> lines,
  }) async {
    return _createSaleAtEndpoint(
      endpoint: '/admin/sales/store',
      userId: userId,
      lines: lines,
    );
  }

  Future<bool> createOnlineSale({
    required String userId,
    required List<OrderItem> lines,
  }) async {
    return _createSaleAtEndpoint(
      endpoint: '/admin/sales/online',
      userId: userId,
      lines: lines,
    );
  }

  Future<bool> _createSaleAtEndpoint({
    required String endpoint,
    required String userId,
    required List<OrderItem> lines,
  }) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealSalesApi) {
        final total = lines.fold<double>(0, (sum, line) => sum + line.itemTotal);
        final now = DateTime.now();
        _orders.insert(
          0,
          Order(
            id: now.millisecondsSinceEpoch.toString(),
            clientId: userId,
            clientName: 'Client $userId',
            clientPhone: '',
            deliveryAddress: 'N/A',
            deliveryCity: 'N/A',
            deliveryCountry: null,
            items: lines,
            totalAmount: total,
            taxAmount: 0,
            shippingAmount: 0,
            status: 'confirmed',
            paymentStatus: 'paid',
            paymentMethod: endpoint.endsWith('/online') ? 'online' : 'cash',
            notes: null,
            createdAt: now,
            deliveredAt: null,
          ),
        );
        _error = null;
        return true;
      }

      final response = await _apiService.post(
        endpoint,
        body: {
          'user': {
            'userId': int.tryParse(userId) ?? userId,
          },
          'orderLines': lines
              .map(
                (line) => {
                  'quantity': line.quantity,
                  'unitPrice': line.unitPrice,
                  'product': {
                    'productId': int.tryParse(line.productId) ?? line.productId,
                  },
                },
              )
              .toList(),
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final raw = response.data is Map<String, dynamic>
            ? response.data
            : response.data['sale'] ?? response.data['order'] ?? response.data['data'];
        _orders.insert(0, Order.fromJson(raw as Map<String, dynamic>));
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to create sale';
      return false;
    } catch (e) {
      _error = 'Error creating sale: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealSalesApi) {
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

      // If the new status is cancelled, use the dedicated cancel endpoint
      final lowered = newStatus.toLowerCase();
      if (lowered == 'cancelled' || lowered == 'canceled') {
        return await cancelOrder(orderId);
      }

      // Use the dedicated status endpoint with query parameter
      final endpoint = '/admin/sales/$orderId/status?status=${Uri.encodeComponent(newStatus.toUpperCase())}';
      final response = await _apiService.put(
        endpoint,
        body: {},
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

  Future<bool> cancelOrder(String orderId) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealSalesApi) {
        return updateOrderStatus(orderId, 'cancelled');
      }

      final response = await _apiService.put(
        '/admin/sales/$orderId/cancel',
        body: const {},
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final raw = response.data is Map<String, dynamic>
            ? response.data
            : response.data['sale'] ?? response.data['order'] ?? response.data['data'];
        final updated = Order.fromJson(raw as Map<String, dynamic>);
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = updated;
        } else {
          _orders.insert(0, updated);
        }
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to cancel order';
      return false;
    } catch (e) {
      _error = 'Error cancelling order: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealSalesApi) {
        _orders.removeWhere((o) => o.id == orderId);
        _error = null;
        return true;
      }

      final response = await _apiService.delete(
        '/admin/sales/$orderId',
        fromJson: (json) => json,
      );

      if (response.success) {
        _orders.removeWhere((o) => o.id == orderId);
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to delete order';
      return false;
    } catch (e) {
      _error = 'Error deleting order: $e';
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
      if (AppConfig.useMockApi && !AppConfig.useRealQuotesApi) {
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

  Future<void> fetchQuotesByStatus(String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi && !AppConfig.useRealQuotesApi) {
        final all = await _mockApiService.fetchAllQuotes();
        _quotes = all.where((q) => q.status.toLowerCase() == status.toLowerCase()).toList();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/quotes/status/${status.toUpperCase()}',
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
        _error = response.error ?? 'Failed to fetch quotes by status';
      }
    } catch (e) {
      _error = 'Error fetching quotes by status: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> approveQuote(String quoteId) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealQuotesApi) {
        final index = _quotes.indexWhere((q) => q.id == quoteId);
        if (index == -1) {
          _error = 'Quote not found';
          return false;
        }
        final current = _quotes[index];
        _quotes[index] = Quote(
          id: current.id,
          clientId: current.clientId,
          clientName: current.clientName,
          clientEmail: current.clientEmail,
          clientPhone: current.clientPhone,
          description: current.description,
          deliveryAddress: current.deliveryAddress,
          items: current.items,
          totalAmount: current.totalAmount,
          status: 'accepted',
          rejectReason: current.rejectReason,
          createdAt: current.createdAt,
          respondedAt: DateTime.now(),
          expiresAt: current.expiresAt,
        );
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/admin/quotes/$quoteId/approve',
        body: const {},
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final updated = Quote.fromJson(response.data is Map<String, dynamic>
            ? response.data
            : response.data['quote'] ?? response.data['data']);
        final index = _quotes.indexWhere((q) => q.id == quoteId);
        if (index != -1) {
          _quotes[index] = updated;
        } else {
          _quotes.insert(0, updated);
        }
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to approve quote';
      return false;
    } catch (e) {
      _error = 'Error approving quote: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> rejectQuote(String quoteId) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealQuotesApi) {
        final index = _quotes.indexWhere((q) => q.id == quoteId);
        if (index == -1) {
          _error = 'Quote not found';
          return false;
        }
        final current = _quotes[index];
        _quotes[index] = Quote(
          id: current.id,
          clientId: current.clientId,
          clientName: current.clientName,
          clientEmail: current.clientEmail,
          clientPhone: current.clientPhone,
          description: current.description,
          deliveryAddress: current.deliveryAddress,
          items: current.items,
          totalAmount: current.totalAmount,
          status: 'rejected',
          rejectReason: current.rejectReason,
          createdAt: current.createdAt,
          respondedAt: DateTime.now(),
          expiresAt: current.expiresAt,
        );
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/admin/quotes/$quoteId/reject',
        body: const {},
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final updated = Quote.fromJson(response.data is Map<String, dynamic>
            ? response.data
            : response.data['quote'] ?? response.data['data']);
        final index = _quotes.indexWhere((q) => q.id == quoteId);
        if (index != -1) {
          _quotes[index] = updated;
        } else {
          _quotes.insert(0, updated);
        }
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to reject quote';
      return false;
    } catch (e) {
      _error = 'Error rejecting quote: $e';
      return false;
    } finally {
      notifyListeners();
    }
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
      if (AppConfig.useMockApi && !AppConfig.useRealProductsApi) {
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
    String? productId,
    required String code,
    required String name,
    required int stockQuantity,
    required double purchasePrice,
    double? priceHT,
    double? priceTTC,
    String? url,
  }) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealProductsApi) {
        final success = await _mockApiService.createProduct(
          name: name,
          description: code,
          price: priceTTC ?? purchasePrice,
          stock: stockQuantity,
          category: 'General',
        );
        if (!success) {
          _error = 'Failed to create product';
          return false;
        }
        _products = await _mockApiService.fetchAllProducts();
        _error = null;
        return true;
      }

      final body = <String, dynamic>{
        if (productId != null && productId.isNotEmpty) 'productId': int.tryParse(productId) ?? productId,
        'code': code,
        'name': name,
        'stockQuantity': stockQuantity,
        'purchasePrice': purchasePrice,
        if (priceHT != null) 'priceHT': priceHT,
        if (priceTTC != null) 'priceTTC': priceTTC,
        if (url != null && url.trim().isNotEmpty) 'url': url.trim(),
      };

      final response = await _apiService.post(
        '/admin/products',
        body: body,
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
    required String code,
    required String name,
    required int stockQuantity,
    required double purchasePrice,
    double? priceHT,
    double? priceTTC,
    String? url,
  }) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealProductsApi) {
        final success = await _mockApiService.updateProduct(
          productId: productId,
          name: name,
          description: code,
          price: priceTTC ?? purchasePrice,
          stock: stockQuantity,
          category: 'General',
        );
        if (!success) {
          _error = 'Failed to update product';
          return false;
        }
        _products = await _mockApiService.fetchAllProducts();
        _error = null;
        return true;
      }

      final body = <String, dynamic>{
        'productId': int.tryParse(productId) ?? productId,
        'code': code,
        'name': name,
        'stockQuantity': stockQuantity,
        'purchasePrice': purchasePrice,
        if (priceHT != null) 'priceHT': priceHT,
        if (priceTTC != null) 'priceTTC': priceTTC,
        if (url != null && url.trim().isNotEmpty) 'url': url.trim(),
      };

      final response = await _apiService.patch(
        '/admin/products/$productId',
        body: body,
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
      if (AppConfig.useMockApi && !AppConfig.useRealProductsApi) {
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
      if (AppConfig.useMockApi && !AppConfig.useRealUsersApi) {
        _users = [
          AdminUser(
            id: 'USR001',
            name: 'System Admin',
            email: 'admin@test.com',
            password: null,
            phone: '+1-555-0001',
            role: 'ADMIN',
            createdAt: DateTime.now().subtract(Duration(days: 100)),
          ),
          AdminUser(
            id: 'USR002',
            name: 'Client User',
            email: 'user@test.com',
            password: null,
            phone: '+1-555-0002',
            role: 'CLIENT',
            createdAt: DateTime.now().subtract(Duration(days: 40)),
          ),
        ];
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/customers',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final List<dynamic> usersJson = response.data is List
            ? response.data
            : response.data['customers'] ?? response.data['users'] ?? response.data['data'] ?? [];

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

  Future<bool> createUser({
    required String fullName,
    required String email,
    required String phone,
    required String role,
    required String password,
  }) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealUsersApi) {
        _users.insert(
          0,
          AdminUser(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: fullName,
            email: email,
            password: password,
            phone: phone,
            role: role,
            createdAt: DateTime.now(),
          ),
        );
        _error = null;
        return true;
      }

      final response = await _apiService.post(
        '/admin/customers',
        body: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
          'createdAt': DateTime.now().toIso8601String(),
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final raw = response.data is Map<String, dynamic>
            ? response.data
            : response.data['customer'] ?? response.data['data'];
        _users.insert(0, AdminUser.fromJson(raw as Map<String, dynamic>));
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to create user';
      return false;
    } catch (e) {
      _error = 'Error creating user: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealUsersApi) {
        _users.removeWhere((u) => u.id == userId);
        _error = null;
        return true;
      }

      final response = await _apiService.delete(
        '/admin/customers/$userId',
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

  // ============ Suppliers Management ============
  Future<void> fetchAllSuppliers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi && !AppConfig.useRealSuppliersApi) {
        _suppliers = [
          AdminSupplier(
            id: 'SUP001',
            name: 'Auto Parts Global',
            phone: '+1-555-0101',
            email: 'contact@autopartsglobal.test',
            address: '123 Industrial Road',
          ),
          AdminSupplier(
            id: 'SUP002',
            name: 'Engine Components Ltd',
            phone: '+1-555-0102',
            email: 'sales@enginecomponents.test',
            address: '45 Mechanic Avenue',
          ),
        ];
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/suppliers',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final List<dynamic> suppliersJson = response.data is List
            ? response.data
            : response.data['suppliers'] ?? response.data['data'] ?? [];

        _suppliers = suppliersJson
            .map((json) => AdminSupplier.fromJson(json as Map<String, dynamic>))
            .toList();
        _error = null;
      } else {
        _error = response.error ?? 'Failed to fetch suppliers';
      }
    } catch (e) {
      _error = 'Error fetching suppliers: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createSupplier({
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealSuppliersApi) {
        _suppliers.add(
          AdminSupplier(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            phone: phone,
            email: email,
            address: address,
          ),
        );
        _error = null;
        return true;
      }

      final response = await _apiService.post(
        '/admin/suppliers',
        body: {
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final raw = response.data is Map<String, dynamic>
            ? response.data
            : response.data['supplier'] ?? response.data['data'];
        _suppliers.add(AdminSupplier.fromJson(raw as Map<String, dynamic>));
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to create supplier';
      return false;
    } catch (e) {
      _error = 'Error creating supplier: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateSupplier({
    required String supplierId,
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealSuppliersApi) {
        final index = _suppliers.indexWhere((s) => s.id == supplierId);
        if (index == -1) {
          _error = 'Supplier not found';
          return false;
        }
        _suppliers[index] = AdminSupplier(
          id: supplierId,
          name: name,
          phone: phone,
          email: email,
          address: address,
        );
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/admin/suppliers/$supplierId',
        body: {
          'supplierId': int.tryParse(supplierId) ?? supplierId,
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final raw = response.data is Map<String, dynamic>
            ? response.data
            : response.data['supplier'] ?? response.data['data'];
        final updated = AdminSupplier.fromJson(raw as Map<String, dynamic>);
        final index = _suppliers.indexWhere((s) => s.id == supplierId);
        if (index != -1) {
          _suppliers[index] = updated;
        } else {
          _suppliers.add(updated);
        }
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to update supplier';
      return false;
    } catch (e) {
      _error = 'Error updating supplier: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteSupplier(String supplierId) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealSuppliersApi) {
        _suppliers.removeWhere((s) => s.id == supplierId);
        _error = null;
        return true;
      }

      final response = await _apiService.delete(
        '/admin/suppliers/$supplierId',
        fromJson: (json) => json,
      );

      if (response.success) {
        _suppliers.removeWhere((s) => s.id == supplierId);
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to delete supplier';
      return false;
    } catch (e) {
      _error = 'Error deleting supplier: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  // ============ Purchases Management ============
  Future<void> fetchAllPurchases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi && !AppConfig.useRealPurchasesApi) {
        _purchases = [];
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/purchases',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final List<dynamic> purchasesJson = response.data is List
            ? response.data
            : response.data['purchases'] ?? response.data['data'] ?? [];

        _purchases = purchasesJson
            .map((json) => AdminPurchase.fromJson(json as Map<String, dynamic>))
            .toList();
        _error = null;
      } else {
        _error = response.error ?? 'Failed to fetch purchases';
      }
    } catch (e) {
      _error = 'Error fetching purchases: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPurchase({
    required DateTime purchaseDate,
    required AdminSupplier supplier,
    required List<AdminPurchaseLine> lines,
  }) async {
    try {
      final totalCost = lines.fold<double>(0, (sum, line) => sum + line.subtotal);

      if (AppConfig.useMockApi && !AppConfig.useRealPurchasesApi) {
        _purchases.insert(
          0,
          AdminPurchase(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            totalCost: totalCost,
            purchaseDate: purchaseDate,
            lines: lines,
            supplier: supplier,
          ),
        );
        _error = null;
        return true;
      }

      final response = await _apiService.post(
        '/admin/purchases',
        body: _buildPurchaseRequestBody(
          purchaseDate: purchaseDate,
          supplier: supplier,
          lines: lines,
        ),
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final raw = response.data is Map<String, dynamic>
            ? response.data
            : response.data['purchase'] ?? response.data['data'];
        _purchases.insert(0, AdminPurchase.fromJson(raw as Map<String, dynamic>));
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to create purchase';
      return false;
    } catch (e) {
      _error = 'Error creating purchase: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updatePurchase({
    required String purchaseId,
    required DateTime purchaseDate,
    required AdminSupplier supplier,
    required List<AdminPurchaseLine> lines,
  }) async {
    try {
      final totalCost = lines.fold<double>(0, (sum, line) => sum + line.subtotal);

      if (AppConfig.useMockApi && !AppConfig.useRealPurchasesApi) {
        final index = _purchases.indexWhere((p) => p.id == purchaseId);
        if (index == -1) {
          _error = 'Purchase not found';
          return false;
        }
        _purchases[index] = AdminPurchase(
          id: purchaseId,
          totalCost: totalCost,
          purchaseDate: purchaseDate,
          lines: lines,
          supplier: supplier,
        );
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/admin/purchases/$purchaseId',
        body: _buildPurchaseRequestBody(
          purchaseDate: purchaseDate,
          supplier: supplier,
          lines: lines,
        ),
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final raw = response.data is Map<String, dynamic>
            ? response.data
            : response.data['purchase'] ?? response.data['data'];
        final updated = AdminPurchase.fromJson(raw as Map<String, dynamic>);
        final index = _purchases.indexWhere((p) => p.id == purchaseId);
        if (index != -1) {
          _purchases[index] = updated;
        } else {
          _purchases.insert(0, updated);
        }
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to update purchase';
      return false;
    } catch (e) {
      _error = 'Error updating purchase: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deletePurchase(String purchaseId) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealPurchasesApi) {
        _purchases.removeWhere((p) => p.id == purchaseId);
        _error = null;
        return true;
      }

      final response = await _apiService.delete(
        '/admin/purchases/$purchaseId',
        fromJson: (json) => json,
      );

      if (response.success) {
        _purchases.removeWhere((p) => p.id == purchaseId);
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to delete purchase';
      return false;
    } catch (e) {
      _error = 'Error deleting purchase: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updatePurchaseStock(String purchaseId) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealPurchasesApi) {
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/admin/purchases/$purchaseId/stock',
        body: const {},
        fromJson: (json) => json,
      );

      if (response.success) {
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to update purchase stock';
      return false;
    } catch (e) {
      _error = 'Error updating purchase stock: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Map<String, dynamic> _buildPurchaseRequestBody({
    required DateTime purchaseDate,
    required AdminSupplier supplier,
    required List<AdminPurchaseLine> lines,
  }) {
    return {
      'purchaseDate': purchaseDate.toIso8601String().split('T').first,
      'supplier': {
        'supplierId': int.tryParse(supplier.id) ?? supplier.id,
      },
      'lines': lines
          .map(
            (line) => {
              'quantity': line.quantity,
              'unitCost': line.unitCost,
              'product': {
                'productId': int.tryParse(line.product.id) ?? line.product.id,
              },
            },
          )
          .toList(),
    };
  }

  Future<AdminUser?> fetchUserById(String userId) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealUsersApi) {
        final index = _users.indexWhere((u) => u.id == userId);
        return index == -1 ? null : _users[index];
      }

      final response = await _apiService.get(
        '/admin/customers/$userId',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final raw = response.data is Map<String, dynamic>
            ? response.data
            : response.data['customer'] ?? response.data['data'];
        return AdminUser.fromJson(raw as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateUser({
    required String userId,
    required String fullName,
    required String email,
    required String phone,
    required String role,
    String? password,
    DateTime? createdAt,
  }) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealUsersApi) {
        final index = _users.indexWhere((u) => u.id == userId);
        if (index == -1) {
          _error = 'User not found';
          return false;
        }
        final existing = _users[index];
        _users[index] = AdminUser(
          id: existing.id,
          name: fullName,
          email: email,
          password: password ?? existing.password,
          phone: phone,
          role: role,
          createdAt: createdAt ?? existing.createdAt,
        );
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/admin/customers/$userId',
        body: {
          'userId': int.tryParse(userId) ?? userId,
          'fullName': fullName,
          'email': email,
          'password': password ?? '',
          'phone': phone,
          'role': role,
          'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final raw = response.data is Map<String, dynamic>
            ? response.data
            : response.data['customer'] ?? response.data['data'];
        final updated = AdminUser.fromJson(raw as Map<String, dynamic>);

        final index = _users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          _users[index] = updated;
        } else {
          _users.add(updated);
        }
        _error = null;
        return true;
      }

      _error = response.error ?? 'Failed to update user';
      return false;
    } catch (e) {
      _error = 'Error updating user: $e';
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

  Future<void> fetchTopProductsStats() async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealStatsApi) {
        _topProductsStats = {};
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/stats/top-products',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        _topProductsStats = _extractIntStatsMap(response.data);
      }
    } catch (_) {
      // Keep previous values if fetch fails.
    }
    notifyListeners();
  }

  Future<void> fetchLowProductsStats() async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealStatsApi) {
        _lowProductsStats = {};
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/stats/low-products',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        _lowProductsStats = _extractIntStatsMap(response.data);
      }
    } catch (_) {
      // Keep previous values if fetch fails.
    }
    notifyListeners();
  }

  Future<void> fetchDailySalesStats() async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealStatsApi) {
        _dailySalesStats = {};
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/stats/daily-sales',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        _dailySalesStats = _extractIntStatsMap(response.data);
      }
    } catch (_) {
      // Keep previous values if fetch fails.
    }
    notifyListeners();
  }

  Future<void> fetchDailyRevenueStats() async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealStatsApi) {
        _dailyRevenueStats = {};
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/admin/stats/daily-revenue',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        _dailyRevenueStats = _extractDoubleStatsMap(response.data);
      }
    } catch (_) {
      // Keep previous values if fetch fails.
    }
    notifyListeners();
  }

  Future<void> fetchPeriodRevenue({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      if (AppConfig.useMockApi && !AppConfig.useRealStatsApi) {
        _periodRevenue = 0;
        notifyListeners();
        return;
      }

      final startDate = start.toIso8601String().split('T').first;
      final endDate = end.toIso8601String().split('T').first;

      final response = await _apiService.get(
        '/admin/stats/period-revenue?start=$startDate&end=$endDate',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        _periodRevenue = _toDouble(response.data);
      }
    } catch (_) {
      // Keep previous values if fetch fails.
    }
    notifyListeners();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, int> _extractIntStatsMap(dynamic source) {
    final rawMap = _extractMapPayload(source);
    return rawMap.map((key, value) => MapEntry(key.toString(), _toInt(value)));
  }

  Map<String, double> _extractDoubleStatsMap(dynamic source) {
    final rawMap = _extractMapPayload(source);
    return rawMap.map((key, value) => MapEntry(key.toString(), _toDouble(value)));
  }

  Map<dynamic, dynamic> _extractMapPayload(dynamic source) {
    if (source is Map) {
      if (source['data'] is Map) return source['data'] as Map;
      if (source['stats'] is Map) return source['stats'] as Map;
      if (source['result'] is Map) return source['result'] as Map;
      return source;
    }

    if (source is List) {
      final map = <dynamic, dynamic>{};
      for (final row in source) {
        if (row is Map) {
          final key = row['key'] ?? row['name'] ?? row['date'] ?? row['label'];
          final value = row['value'] ?? row['count'] ?? row['amount'] ?? row['total'];
          if (key != null && value != null) {
            map[key] = value;
          }
        }
      }
      return map;
    }

    return const {};
  }

  Map<String, dynamic> _calculateLocalStats() {
    final totalOrders = _orders.length;
    final totalQuotes = _quotes.length;
    final totalProducts = _products.length;
    final totalSuppliers = _suppliers.length;
    final totalPurchases = _purchases.length;
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
      'total_suppliers': totalSuppliers,
      'total_purchases': totalPurchases,
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
