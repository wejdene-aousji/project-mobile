import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/token_persistence.dart';
import '../../shared/models/user.dart';

/// Authentication State Provider
class AuthProvider extends ChangeNotifier {
  final dynamic _authService; // Can be AuthService or MockAuthService

  AuthProvider(this._authService);

  /// Get current user
  User? get currentUser => _authService.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  /// Check if user is admin
  bool get isAdmin => _authService.isAdmin;

  /// Check if user is client
  bool get isClient => _authService.isClient;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Initialize auth provider - restore user from storage
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.init();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? response.error ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up user
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? response.error ?? 'Signup failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? address,
    String? city,
    String? country,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfile(
        name: name,
        phone: phone,
        address: address,
        city: city,
        country: country,
      );

      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? response.error ?? 'Update failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update client profile using new client endpoint
  Future<bool> updateClientProfile({
    required dynamic userId,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.updateClientProfile(
        userId: userId,
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
        createdAt: createdAt,
      );

      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? response.error ?? 'Update failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Provider setup helper
class ProviderSetup {
  /// Create all providers
  static List<ChangeNotifierProvider> createProviders({
    required TokenPersistence tokenPersistence,
    required ApiService apiService,
  }) {
    final authService = AuthService(
      apiService: apiService,
      tokenPersistence: tokenPersistence,
    );

    return [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authService),
      ),
    ];
  }
}
