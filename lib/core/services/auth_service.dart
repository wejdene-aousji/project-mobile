import 'dart:convert';
import '../config/app_config.dart';
import '../../shared/models/user.dart';
import 'api_service.dart';
import 'token_persistence.dart';

/// Authentication Service
/// Handles user authentication, login, signup, and token management
class AuthService {
  final ApiService apiService;
  final TokenPersistence tokenPersistence;

  User? _currentUser;

  AuthService({
    required this.apiService,
    required this.tokenPersistence,
  });

  /// Get current authenticated user
  User? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Check if user is admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Check if user is client
  bool get isClient => _currentUser?.isClient ?? false;

  /// Initialize auth service - restore user from storage
  Future<void> init() async {
    await _restoreUserFromStorage();
  }

  /// Login with email and password
  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    final body = {
      'email': email,
      'password': password,
    };

    final response = await apiService.post<Map<String, dynamic>>(
      '/auth/login',
      body: body,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final token = response.data!['token'] as String;
      final refreshToken = response.data!['refresh_token'] as String?;
      final userData = response.data!['user'] as Map<String, dynamic>;

      // Save tokens
      await tokenPersistence.saveToken(token);
      if (refreshToken != null) {
        await tokenPersistence.saveRefreshToken(refreshToken);
      }

      // Create user object
      _currentUser = User.fromJson(userData);

      // Save user data to storage
      await tokenPersistence.setString(
        AppConfig.userStorageKey,
        jsonEncode(_currentUser!.toJson()),
      );

      return ApiResponse(
        success: true,
        data: _currentUser,
        message: 'Login successful',
      );
    } else {
      return ApiResponse(
        success: false,
        error: response.error,
        message: response.message,
      );
    }
  }

  /// Sign up new user
  Future<ApiResponse<User>> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': 'client', // Default role is client
    };

    final response = await apiService.post<Map<String, dynamic>>(
      '/auth/signup',
      body: body,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final token = response.data!['token'] as String;
      final refreshToken = response.data!['refresh_token'] as String?;
      final userData = response.data!['user'] as Map<String, dynamic>;

      // Save tokens
      await tokenPersistence.saveToken(token);
      if (refreshToken != null) {
        await tokenPersistence.saveRefreshToken(refreshToken);
      }

      // Create user object
      _currentUser = User.fromJson(userData);

      // Save user data to storage
      await tokenPersistence.setString(
        AppConfig.userStorageKey,
        jsonEncode(_currentUser!.toJson()),
      );

      return ApiResponse(
        success: true,
        data: _currentUser,
        message: 'Signup successful',
      );
    } else {
      return ApiResponse(
        success: false,
        error: response.error,
        message: response.message,
      );
    }
  }

  /// Update user profile
  Future<ApiResponse<User>> updateProfile({
    required String name,
    required String phone,
    String? address,
    String? city,
    String? country,
  }) async {
    if (_currentUser == null) {
      return ApiResponse(
        success: false,
        error: 'Not authenticated',
        message: 'Please login first',
      );
    }

    final body = {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
    };

    final response = await apiService.put<Map<String, dynamic>>(
      '/auth/profile/${_currentUser!.id}',
      body: body,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      _currentUser = User.fromJson(response.data!['user'] as Map<String, dynamic>);

      // Update stored user data
      await tokenPersistence.setString(
        AppConfig.userStorageKey,
        jsonEncode(_currentUser!.toJson()),
      );

      return ApiResponse(
        success: true,
        data: _currentUser,
        message: 'Profile updated successfully',
      );
    } else {
      return ApiResponse(
        success: false,
        error: response.error,
        message: response.message,
      );
    }
  }

  /// Logout user
  Future<void> logout() async {
    // Optionally notify backend
    await apiService.post<Map<String, dynamic>>(
      '/auth/logout',
      body: {},
      fromJson: (json) => json as Map<String, dynamic>? ?? {},
    );

    // Clear local data
    _currentUser = null;
    await tokenPersistence.clearTokens();
    await tokenPersistence.remove(AppConfig.userStorageKey);
  }

  /// Restore user from local storage
  Future<void> _restoreUserFromStorage() async {
    try {
      final token = await tokenPersistence.getToken();
      final userJson = await tokenPersistence.getString(AppConfig.userStorageKey);

      if (token != null && userJson != null) {
        _currentUser = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      }
    } catch (e) {
      // Failed to restore user
      await tokenPersistence.clearTokens();
      _currentUser = null;
    }
  }

  /// Refresh access token using refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await tokenPersistence.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await apiService.post<Map<String, dynamic>>(
        '/auth/refresh',
        body: {'refresh_token': refreshToken},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final newToken = response.data!['token'] as String;
        await tokenPersistence.saveToken(newToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
