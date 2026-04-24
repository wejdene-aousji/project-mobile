import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/mock_api_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../shared/models/order.dart';

class OrderProvider extends ChangeNotifier {
  late ApiService _apiService;
  final MockApiService _mockApiService = MockApiService();

  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'All'; // 'All', 'Pending', 'Completed', 'Cancelled'

  OrderProvider() {
    _apiService = ServiceLocator.apiService;
  }

  // Getters
  List<Order> get orders => _orders;
  List<Order> get filteredOrders {
    if (_filterStatus == 'All') {
      return _orders;
    }
    final fs = _filterStatus.toLowerCase();
    return _orders.where((order) => (order.status ?? '').toLowerCase() == fs).toList();
  }

  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;
  int get orderCount => _orders.length;

  // Fetch all orders for current user
  Future<void> fetchOrders() async {
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
        '/api/client/orders',
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

  // Fetch single order by ID
  Future<void> fetchOrderById(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        _selectedOrder = await _mockApiService.fetchOrderById(orderId);
        if (_selectedOrder == null) {
          _error = 'Failed to fetch order details';
        }
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/orders/$orderId',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        _selectedOrder = Order.fromJson(response.data is Map
            ? response.data
            : response.data['order'] ?? response.data['data']);
        _error = null;
      } else {
        _error = response.error ?? 'Failed to fetch order details';
      }
    } catch (e) {
      _error = 'Error fetching order: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filter orders by status (client-side)
  void filterByStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Filter orders by date range
  List<Order> filterByDate(DateTime startDate, DateTime endDate) {
    return _orders.where((order) {
      return order.createdAt.isAfter(startDate) &&
          order.createdAt.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  // Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        final success = await _mockApiService.updateOrderStatus(orderId, 'cancelled');
        if (success) {
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
              status: 'cancelled',
              paymentStatus: order.paymentStatus,
              paymentMethod: order.paymentMethod,
              notes: order.notes,
              createdAt: order.createdAt,
              deliveredAt: order.deliveredAt,
            );
          }
          _error = null;
          return true;
        }
        _error = 'Failed to cancel order';
        return false;
      }

      final response = await _apiService.put(
        '/orders/$orderId/cancel',
        body: {'status': 'cancelled'},
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        // Update local order
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = Order.fromJson(response.data is Map
              ? response.data
              : response.data['order'] ?? response.data['data']);
        }
        _error = null;
        return true;
      } else {
        _error = response.error ?? 'Failed to cancel order';
        return false;
      }
    } catch (e) {
      _error = 'Error cancelling order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create/place a new order from client cart
  Future<bool> createOrder({
    required List<dynamic> orderLines,
    required double totalPrice,
    String paymentMethod = 'cod',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        // Construct a fake order and insert locally
        final now = DateTime.now();
        final order = Order(
          id: now.millisecondsSinceEpoch.toString(),
          clientId: 'me',
          clientName: 'You',
          clientPhone: '',
          deliveryAddress: '',
          deliveryCity: '',
          deliveryCountry: null,
          items: orderLines
              .map((l) => OrderItem(
                    productId: (l['product'] is Map && l['product']['productId'] != null)
                        ? l['product']['productId'].toString()
                        : l['productId'].toString(),
                    productName: l['product'] is Map ? (l['product']['name'] ?? 'Product').toString() : 'Product',
                    unitPrice: (l['unitPrice'] ?? l['unit_price'] ?? 0) is num
                        ? (l['unitPrice'] ?? l['unit_price'] ?? 0).toDouble()
                        : 0.0,
                    quantity: (l['quantity'] ?? 1) is int ? (l['quantity'] ?? 1) as int : int.tryParse((l['quantity'] ?? '1').toString()) ?? 1,
                  ))
              .toList(),
          totalAmount: totalPrice,
          taxAmount: 0,
          shippingAmount: 0,
          status: 'pending',
          paymentStatus: 'pending',
          paymentMethod: paymentMethod,
          notes: null,
          createdAt: now,
          deliveredAt: null,
        );
        _orders.insert(0, order);
        _isLoading = false;
        notifyListeners();
        return true;
      }


      // Normalize order lines to match backend expected schema
      final normalizedLines = orderLines.map((l) {
        final prod = l['product'];
        String pid;
        if (prod is Map && (prod['productId'] != null || prod['id'] != null)) {
          pid = (prod['productId'] ?? prod['id']).toString();
        } else {
          pid = (l['productId'] ?? l['productId'] ?? '').toString();
        }

        final unitPrice = (l['unitPrice'] ?? l['unit_price'] ?? l['subtotal'] ?? 0);
        final quantity = (l['quantity'] ?? 1);

        final productObj = {
          'productId': int.tryParse(pid) ?? pid,
          'code': prod is Map ? (prod['code'] ?? '') : '',
          'name': prod is Map ? (prod['name'] ?? l['productName'] ?? '') : (l['productName'] ?? ''),
          'stockQuantity': prod is Map ? (prod['stockQuantity'] ?? 0) : 0,
          'purchasePrice': unitPrice,
          'priceHT': unitPrice,
          'priceTTC': unitPrice,
          'url': prod is Map ? (prod['url'] ?? prod['image'] ?? '') : (l['productImage'] ?? ''),
        };

        return {
          'product': productObj,
          'quantity': quantity,
          'unitPrice': unitPrice,
          'subtotal': (l['subtotal'] ?? (unitPrice is num && quantity is num ? unitPrice * quantity : 0)),
        };
      }).toList();

      // Build orderLines in simplified admin/client create shape
      final payloadOrderLines = normalizedLines.map((ln) {
        final prod = ln['product'] as Map<String, dynamic>;
        return {
          'product': {'productId': prod['productId']},
          'quantity': ln['quantity'],
          'unitPrice': ln['unitPrice'],
        };
      }).toList();

      // Determine current user id from auth service
      final auth = ServiceLocator.authService;
      String? currentUserId;
      try {
        currentUserId = auth?.currentUser?.id?.toString();
      } catch (_) {
        currentUserId = null;
      }

      final body = {
        'user': {
          'userId': currentUserId != null ? (int.tryParse(currentUserId) ?? currentUserId) : null,
        },
        'orderLines': payloadOrderLines,
      };

      // Debug log request body (JSON encoded)
      // ignore: avoid_print
      print('POST /api/client/orders -> body: ' + const JsonEncoder.withIndent('  ').convert(body));

      final response = await _apiService.post(
        '/api/client/orders',
        body: body,
        fromJson: (json) => json,
      );

      // Debug log response
      // ignore: avoid_print
      print('Create order response: success=${response.success} status=${response.statusCode} message=${response.message} error=${response.error} data=${response.data}');

      if (response.success && response.data != null) {
        final raw = response.data is Map ? response.data : response.data['order'] ?? response.data['data'];
        final created = Order.fromJson(raw as Map<String, dynamic>);
        _orders.insert(0, created);
        _error = null;
        return true;
      }

      // Provide a clearer error message for auth / forbidden responses
      if (response.statusCode == 401 || response.statusCode == 403) {
        _error = response.message ?? response.error ?? 'Unauthorized. Please login.';
      } else {
        _error = response.message ?? response.error ?? 'Failed to create order';
      }
      return false;
    } catch (e) {
      _error = 'Error creating order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get order by ID without fetching from API
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Get order statistics
  Map<String, int> getOrderStats() {
    return {
      'total': _orders.length,
      'pending': _orders.where((o) => (o.status ?? '').toLowerCase() == 'pending').length,
      'completed': _orders.where((o) => (o.status ?? '').toLowerCase() == 'completed').length,
      'cancelled': _orders.where((o) => (o.status ?? '').toLowerCase() == 'cancelled').length,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
