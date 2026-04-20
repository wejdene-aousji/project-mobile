/// Application Constants
class AppConstants {
  // Routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String clientMainRoute = '/client';
  static const String adminMainRoute = '/admin';
  static const String dashboardRoute = '/admin/dashboard';
  static const String productsRoute = '/products';
  static const String cartRoute = '/cart';
  static const String checkoutRoute = '/checkout';
  static const String orderHistoryRoute = '/orders';
  static const String quoteRoute = '/quote';

  // Error Messages
  static const String networkError = 'Network error. Please try again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String tokenExpired = 'Session expired. Please login again.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'You are not authorized to access this.';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String logoutSuccess = 'Logged out successfully!';
  static const String orderPlaced = 'Order placed successfully!';
  static const String productAdded = 'Product added to cart!';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Cache Duration (in minutes)
  static const int productsCacheDuration = 30;
  static const int userCacheDuration = 60;
}
