import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/mock_api_service.dart';
import '../../../shared/models/product.dart';

/// Product Provider
class ProductProvider extends ChangeNotifier {
  final ApiService apiService;
  final MockApiService _mockApiService = MockApiService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  ProductProvider(this.apiService);

  // Getters
  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Get unique categories from products
  List<String> get categories {
    final cats = <String>{'All'};
    for (var product in _products) {
      cats.add(product.category);
    }
    return cats.toList();
  }

  /// Fetch all products
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        _products = await _mockApiService.fetchAllProducts();
        _applyFilters();
        return;
      }

      final response = await apiService.get<Map<String, dynamic>>(
        '/products',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data!['data'] as List? ?? response.data!['products'] as List? ?? [];
        _products = data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        _applyFilters();
      } else {
        _error = response.message ?? response.error ?? 'Failed to load products';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get product by ID
  Future<void> fetchProductById(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        _selectedProduct = await _mockApiService.fetchProductById(productId);
        if (_selectedProduct == null) {
          _error = 'Product not found';
        }
        return;
      }

      final response = await apiService.get<Map<String, dynamic>>(
        '/products/$productId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        _selectedProduct = Product.fromJson(response.data!);
      } else {
        _error = response.message ?? response.error ?? 'Failed to load product';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  /// Search products
  void searchProducts(String query) {
    _searchQuery = query.toLowerCase();
    _selectedCategory = 'All';
    _applyFilters();
    notifyListeners();
  }

  /// Apply filters and search
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery) ||
          product.description.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Clear filters
  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _filteredProducts = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
