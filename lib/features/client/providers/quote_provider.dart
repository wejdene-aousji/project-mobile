import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/mock_api_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../shared/models/quote.dart';

class QuoteProvider extends ChangeNotifier {
  late ApiService _apiService;
  final MockApiService _mockApiService = MockApiService();

  List<Quote> _quotes = [];
  Quote? _selectedQuote;
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'All'; // 'All', 'Pending', 'Accepted', 'Rejected', 'Expired'

  QuoteProvider() {
    _apiService = ServiceLocator.apiService;
  }

  // Getters
  List<Quote> get quotes => _quotes;
  List<Quote> get filteredQuotes {
    if (_filterStatus == 'All') {
      return _quotes;
    }
    return _quotes.where((quote) => quote.status == _filterStatus).toList();
  }

  Quote? get selectedQuote => _selectedQuote;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;
  int get quoteCount => _quotes.length;

  // Fetch all quotes for current user
  Future<void> fetchQuotes() async {
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
        '/quotes',
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

  // Fetch single quote by ID
  Future<void> fetchQuoteById(String quoteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        _selectedQuote = await _mockApiService.fetchQuoteById(quoteId);
        if (_selectedQuote == null) {
          _error = 'Failed to fetch quote details';
        }
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.get(
        '/quotes/$quoteId',
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        _selectedQuote = Quote.fromJson(response.data is Map
            ? response.data
            : response.data['quote'] ?? response.data['data']);
        _error = null;
      } else {
        _error = response.error ?? 'Failed to fetch quote details';
      }
    } catch (e) {
      _error = 'Error fetching quote: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Submit a new quote request
  Future<bool> submitQuoteRequest({
    required String description,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        final newQuote = Quote(
          id: 'QT${DateTime.now().millisecondsSinceEpoch}',
          clientId: 'CLI_LOCAL',
          clientName: 'Mock Client',
          clientEmail: 'mock@local.dev',
          clientPhone: '+1-000-0000',
          description: description,
          deliveryAddress: deliveryAddress,
          items: items
              .map(
                (item) => QuoteItem(
                  productId: 'PROD_LOCAL',
                  productName: (item['name'] ?? 'Custom Item').toString(),
                  quantity: (item['quantity'] as int?) ?? 1,
                  specifications: (item['specs'] ?? '').toString(),
                ),
              )
              .toList(),
          totalAmount: 0,
          status: 'pending',
          createdAt: DateTime.now(),
        );
        _quotes.insert(0, newQuote);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      final response = await _apiService.post(
        '/quotes',
        body: {
          'description': description,
          'items': items,
          'deliveryAddress': deliveryAddress,
          'requestDate': DateTime.now().toIso8601String(),
        },
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final newQuote = Quote.fromJson(response.data is Map
            ? response.data
            : response.data['quote'] ?? response.data['data']);
        _quotes.add(newQuote);
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to submit quote';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error submitting quote: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Accept a quote and convert to order
  Future<bool> acceptQuote(String quoteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        final index = _quotes.indexWhere((q) => q.id == quoteId);
        if (index == -1) {
          _error = 'Quote not found';
          return false;
        }
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
          totalAmount: quote.totalAmount,
          status: 'accepted',
          rejectReason: null,
          createdAt: quote.createdAt,
          respondedAt: DateTime.now(),
          expiresAt: quote.expiresAt,
        );
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/quotes/$quoteId/accept',
        body: {'status': 'accepted'},
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final index = _quotes.indexWhere((q) => q.id == quoteId);
        if (index != -1) {
          _quotes[index] = Quote.fromJson(response.data is Map
              ? response.data
              : response.data['quote'] ?? response.data['data']);
        }
        _error = null;
        return true;
      } else {
        _error = response.error ?? 'Failed to accept quote';
        return false;
      }
    } catch (e) {
      _error = 'Error accepting quote: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reject a quote
  Future<bool> rejectQuote(String quoteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.useMockApi) {
        final index = _quotes.indexWhere((q) => q.id == quoteId);
        if (index == -1) {
          _error = 'Quote not found';
          return false;
        }
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
          totalAmount: quote.totalAmount,
          status: 'rejected',
          rejectReason: 'Rejected by client',
          createdAt: quote.createdAt,
          respondedAt: DateTime.now(),
          expiresAt: quote.expiresAt,
        );
        _error = null;
        return true;
      }

      final response = await _apiService.put(
        '/quotes/$quoteId/reject',
        body: {'status': 'rejected'},
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final index = _quotes.indexWhere((q) => q.id == quoteId);
        if (index != -1) {
          _quotes[index] = Quote.fromJson(response.data is Map
              ? response.data
              : response.data['quote'] ?? response.data['data']);
        }
        _error = null;
        return true;
      } else {
        _error = response.error ?? 'Failed to reject quote';
        return false;
      }
    } catch (e) {
      _error = 'Error rejecting quote: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter quotes by status
  void filterByStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Get quote by ID
  Quote? getQuoteById(String quoteId) {
    try {
      return _quotes.firstWhere((quote) => quote.id == quoteId);
    } catch (e) {
      return null;
    }
  }

  // Get quote statistics
  Map<String, int> getQuoteStats() {
    return {
      'total': _quotes.length,
      'pending': _quotes.where((q) => q.status == 'Pending').length,
      'accepted': _quotes.where((q) => q.status == 'Accepted').length,
      'rejected': _quotes.where((q) => q.status == 'Rejected').length,
      'expired': _quotes.where((q) => q.status == 'Expired').length,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
