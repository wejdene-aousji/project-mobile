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
      '/api/auth/login',
      body: body,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final token = data['token'] as String? ?? data['access_token'] as String?;
      final role = (data['role'] ?? data['user']?['role'])?.toString();
      final emailResp = (data['email'] ?? data['user']?['email'])?.toString();
      final fullName = (data['fullName'] ?? data['user']?['fullName'] ?? data['user']?['name'])?.toString();
      final phone = (data['phone'] ?? data['user']?['phone'])?.toString() ?? '';

      // Extract userId if provided by backend (top-level or nested)
      dynamic rawUserId = data['userId'] ?? data['user']?['userId'] ?? data['user']?['id'];
      final userIdStr = rawUserId != null ? rawUserId.toString() : null;

      if (token != null) {
        await tokenPersistence.saveToken(token);
      }

      // Build minimal user from response, prefer explicit userId when available
      _currentUser = User(
        id: userIdStr ?? emailResp ?? fullName ?? 'unknown',
        email: emailResp ?? '',
        name: fullName ?? emailResp ?? 'User',
        phone: phone,
        role: (role ?? 'client').toString().toLowerCase(),
        createdAt: DateTime.now(),
      );

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
      'fullName': name,
      'email': email,
      'password': password,
      'phone': phone,
    };

    final response = await apiService.post<Map<String, dynamic>>(
      '/api/auth/register',
      body: body,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final token = data['token'] as String?;
      final role = data['role']?.toString();
      final emailResp = data['email']?.toString();
      final fullName = data['fullName']?.toString();

      if (token != null) {
        await tokenPersistence.saveToken(token);
      }

      _currentUser = User(
        id: emailResp ?? fullName ?? 'unknown',
        email: emailResp ?? '',
        name: fullName ?? emailResp ?? 'User',
        phone: phone,
        role: (role ?? 'client').toString().toLowerCase(),
        createdAt: DateTime.now(),
      );

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

  /// Update client profile via new API endpoint '/api/client/profile'
  Future<ApiResponse<User>> updateClientProfile({
    required dynamic userId,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) async {
    final body = {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);

    final response = await apiService.put<Map<String, dynamic>>(
      '/api/client/profile',
      body: body,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      // Backend may return the updated user directly or wrapped; try common shapes
      Map<String, dynamic> userJson;
      final data = response.data!;
      if (data is Map<String, dynamic> && data.containsKey('user')) {
        userJson = data['user'] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        userJson = data['data'] as Map<String, dynamic>;
      } else {
        userJson = data as Map<String, dynamic>;
      }

      try {
        _currentUser = User.fromJson(userJson);

        // Update stored user data
        await tokenPersistence.setString(
          AppConfig.userStorageKey,
          jsonEncode(_currentUser!.toJson()),
        );

        return ApiResponse(success: true, data: _currentUser, message: 'Profile updated');
      } catch (e) {
        return ApiResponse(success: false, error: 'Invalid user response', message: 'Failed to parse user');
      }
    }

    return ApiResponse(success: false, error: response.error, message: response.message);
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
