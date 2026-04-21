import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_persistence.dart';

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, message: $message)';
  }
}

/// API Service
/// Handles all HTTP requests with JWT authentication
class ApiService {
  final TokenPersistence tokenPersistence;
  late http.Client _client;

  ApiService({required this.tokenPersistence}) {
    _client = http.Client();
  }

  /// Get common headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final token = await tokenPersistence.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Make a GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await _client
          .get(url, headers: headers)
          .timeout(Duration(seconds: AppConfig.apiTimeout));

      return _handleResponse(response, fromJson);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        error: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Make a POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    required dynamic body,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await _client
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: AppConfig.apiTimeout));

      return _handleResponse(response, fromJson);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        error: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Make a PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    required dynamic body,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await _client
          .put(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: AppConfig.apiTimeout));

      return _handleResponse(response, fromJson);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        error: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Make a PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    required dynamic body,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await _client
          .patch(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: AppConfig.apiTimeout));

      return _handleResponse(response, fromJson);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        error: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Make a DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      final response = await _client
          .delete(url, headers: headers)
          .timeout(Duration(seconds: AppConfig.apiTimeout));

      return _handleResponse(response, fromJson);
    } on TimeoutException {
      return ApiResponse(
        success: false,
        error: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
  ) {
    try {
      final rawBody = response.body.trim();
      dynamic decodedResponse = {};

      if (rawBody.isNotEmpty) {
        decodedResponse = jsonDecode(rawBody);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success response
        final data = decodedResponse is Map
            ? decodedResponse['data'] ?? decodedResponse
            : (rawBody.isEmpty ? {} : decodedResponse);

        return ApiResponse(
          success: true,
          data: fromJson(data),
          message: decodedResponse is Map
              ? decodedResponse['message'] ?? 'Success'
              : 'Success',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 401) {
        // Unauthorized - token may be expired
        return ApiResponse(
          success: false,
          error: 'Unauthorized',
          statusCode: response.statusCode,
          message: decodedResponse is Map
              ? decodedResponse['message'] ?? 'Session expired'
              : 'Session expired',
        );
      } else if (response.statusCode == 403) {
        // Forbidden
        return ApiResponse(
          success: false,
          error: 'Forbidden',
          statusCode: response.statusCode,
          message: decodedResponse is Map
              ? decodedResponse['message'] ?? 'Access denied'
              : 'Access denied',
        );
      } else if (response.statusCode == 404) {
        // Not found
        return ApiResponse(
          success: false,
          error: 'Not found',
          statusCode: response.statusCode,
          message: decodedResponse is Map
              ? decodedResponse['message'] ?? 'Resource not found'
              : 'Resource not found',
        );
      } else if (response.statusCode >= 500) {
        // Server error
        return ApiResponse(
          success: false,
          error: 'Server error',
          statusCode: response.statusCode,
          message: decodedResponse is Map
              ? decodedResponse['message'] ?? 'Server error'
              : 'Server error',
        );
      } else {
        // Other errors
        return ApiResponse(
          success: false,
          error: decodedResponse is Map
              ? decodedResponse['error'] ?? 'Unknown error'
              : 'Unknown error',
          statusCode: response.statusCode,
          message: decodedResponse is Map ? decodedResponse['message'] : null,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Failed to parse response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  /// Close HTTP client
  void dispose() {
    _client.close();
  }
}
