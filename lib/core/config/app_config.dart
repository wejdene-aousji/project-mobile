/// Application Configuration
/// Manage environment-specific settings like API URLs
class AppConfig {
  static const String appName = 'AutoParts Manager';
  static const String appVersion = '1.0.0';

  // Mock API - Set to true to use mock API service instead of real backend
  static const bool useMockApi = false;
  static const bool useRealProductsApi = true;
  static const bool useRealUsersApi = true;
  static const bool useRealSuppliersApi = true;
  static const bool useRealPurchasesApi = true;
  static const bool useRealSalesApi = true;
  static const bool useRealStatsApi = true;
  static const bool useRealQuotesApi = true;

  // Cloudinary (frontend-safe values only)
  // Do not put ApiSecret in Flutter client code.
  static const String cloudinaryCloudName = 'diflwnbtb';
  static const String cloudinaryUploadPreset = 'flutter';

  // API Configuration - Can be changed at runtime
  static String _apiBaseUrl = 'http://localhost:8080';
  static const String _apiTimeoutSeconds = '30';

  /// Get the current API base URL
  static String get apiBaseUrl => _apiBaseUrl;

  /// Set the API base URL (useful for switching environments)
  static void setApiBaseUrl(String url) {
    _apiBaseUrl = url;
  }

  /// Get the API timeout in seconds
  static int get apiTimeout => int.parse(_apiTimeoutSeconds);

  // API Endpoints
  static String get authEndpoint => '$_apiBaseUrl/auth';
  static String get productsEndpoint => '$_apiBaseUrl/products';
  static String get ordersEndpoint => '$_apiBaseUrl/orders';
  static String get clientsEndpoint => '$_apiBaseUrl/clients';
  static String get suppliersEndpoint => '$_apiBaseUrl/suppliers';
  static String get quotesEndpoint => '$_apiBaseUrl/quotes';
  static String get statsEndpoint => '$_apiBaseUrl/statistics';
  static String get purchasesEndpoint => '$_apiBaseUrl/purchases';

  // Storage Keys
  static const String tokenStorageKey = 'auth_token';
  static const String userStorageKey = 'user_data';
  static const String refreshTokenStorageKey = 'refresh_token';

  // App Defaults
  static const int pageSize = 20;
  static const int cartMaxQuantity = 100;
  static const String defaultCurrency = 'USD';
}
