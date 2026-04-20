import 'dart:convert';
import '../config/app_config.dart';
import '../../shared/models/user.dart';
import 'token_persistence.dart';

/// API Response wrapper (imported from AuthService pattern)
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message)';
  }
}

/// Mock Authentication Service - provides same interface as AuthService
class MockAuthService {
  final TokenPersistence tokenPersistence;
  User? _currentUser;

  MockAuthService({required this.tokenPersistence});

  // Mock users database
  static final Map<String, Map<String, String>> _mockUsers = {
    'admin@test.com': {'password': 'admin123', 'role': 'admin'},
    'user@test.com': {'password': 'user123', 'role': 'client'},
  };

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isClient => _currentUser?.isClient ?? false;

  Future<void> init() async {
    await _restoreUserFromStorage();
  }

  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    final user = _mockUsers[email];
    if (user != null && user['password'] == password) {
      _currentUser = User(
        id: 'USER_${email.hashCode}',
        email: email,
        name: email.split('@')[0].toUpperCase(),
        phone: '+1-555-0000',
        role: user['role']!,
        createdAt: DateTime.now(),
      );

      await tokenPersistence.saveToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await tokenPersistence.setString(
        AppConfig.userStorageKey,
        jsonEncode(_currentUser!.toJson()),
      );

      return ApiResponse(
        success: true,
        data: _currentUser,
        message: 'Mock login successful',
      );
    }

    return ApiResponse(
      success: false,
      error: 'Invalid credentials',
      message: 'Email or password incorrect',
    );
  }

  Future<ApiResponse<User>> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    // Mock signup - always succeeds
    _currentUser = User(
      id: 'USER_${email.hashCode}',
      email: email,
      name: name,
      phone: phone,
      role: 'client',
      createdAt: DateTime.now(),
    );

    await tokenPersistence.saveToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
    await tokenPersistence.setString(
      AppConfig.userStorageKey,
      jsonEncode(_currentUser!.toJson()),
    );

    return ApiResponse(
      success: true,
      data: _currentUser,
      message: 'Signup successful',
    );
  }

  Future<ApiResponse<User>> updateProfile({
    required String name,
    required String phone,
    String? address,
    String? city,
    String? country,
  }) async {
    await Future.delayed(Duration(milliseconds: 500));

    if (_currentUser == null) {
      return ApiResponse(
        success: false,
        error: 'Not authenticated',
        message: 'Please login first',
      );
    }

    _currentUser = User(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: name,
      phone: phone,
      address: address,
      city: city,
      country: country,
      role: _currentUser!.role,
      createdAt: _currentUser!.createdAt,
      updatedAt: DateTime.now(),
    );

    await tokenPersistence.setString(
      AppConfig.userStorageKey,
      jsonEncode(_currentUser!.toJson()),
    );

    return ApiResponse(
      success: true,
      data: _currentUser,
      message: 'Profile updated successfully',
    );
  }

  Future<void> logout() async {
    _currentUser = null;
    await tokenPersistence.clearTokens();
    await tokenPersistence.remove(AppConfig.userStorageKey);
  }

  Future<void> _restoreUserFromStorage() async {
    try {
      final userJson = await tokenPersistence.getString(AppConfig.userStorageKey);
      if (userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      }
    } catch (e) {
      _currentUser = null;
    }
  }

  Future<bool> refreshToken() async {
    await Future.delayed(Duration(milliseconds: 300));
    return true; // Mock always succeeds
  }
}
