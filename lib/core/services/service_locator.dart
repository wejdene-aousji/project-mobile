import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/mock_auth_service.dart';
import '../services/token_persistence.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';

/// Service initialization and dependency injection
class ServiceLocator {
  static late TokenPersistence _tokenPersistence;
  static late ApiService _apiService;
  static late dynamic _authService; // Can be AuthService or MockAuthService

  /// Initialize all services
  static Future<void> init() async {
    // Initialize token persistence
    _tokenPersistence = TokenPersistence();
    await _tokenPersistence.init();

    // Initialize API service
    _apiService = ApiService(tokenPersistence: _tokenPersistence);

    // Initialize auth service based on config
    if (AppConfig.useMockApi) {
      _authService = MockAuthService(tokenPersistence: _tokenPersistence);
    } else {
      _authService = AuthService(
        apiService: _apiService,
        tokenPersistence: _tokenPersistence,
      );
    }
    await _authService.init();
  }

  /// Get token persistence instance
  static TokenPersistence get tokenPersistence => _tokenPersistence;

  /// Get API service instance
  static ApiService get apiService => _apiService;

  /// Get auth service instance
  static dynamic get authService => _authService;

  /// Create providers for MultiProvider
  static List<ChangeNotifierProvider> createProviders() {
    return [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(_authService),
      ),
    ];
  }

  /// Dispose all services
  static void dispose() {
    _apiService.dispose();
  }
}

