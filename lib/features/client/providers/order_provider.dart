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
    return _orders.where((order) => order.status == _filterStatus).toList();
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
        '/orders/history',
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

  // Filter orders by status
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
      'pending': _orders.where((o) => o.status == 'Pending').length,
      'completed': _orders.where((o) => o.status == 'Completed').length,
      'cancelled': _orders.where((o) => o.status == 'Cancelled').length,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
