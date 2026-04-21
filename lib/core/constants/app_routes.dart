/// Application Routes - centralized route definitions
class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String signup = '/signup';

  // Client routes
  static const String clientHome = '/client/home';
  static const String clientProducts = '/client/products';
  static const String clientProductDetail = '/client/product-detail';
  static const String clientCart = '/client/cart';
  static const String clientCheckout = '/client/checkout';
  static const String clientProfile = '/client/profile';

  // Order routes
  static const String clientOrders = '/client/orders';
  static const String clientOrderDetail = '/client/order-detail';

  // Quote routes
  static const String clientQuoteRequest = '/client/quote-request';
  static const String clientQuotes = '/client/quotes';
  static const String clientQuoteDetail = '/client/quote-detail';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminOrders = '/admin/orders';
  static const String adminOrderDetail = '/admin/order-detail';
  static const String adminQuotes = '/admin/quotes';
  static const String adminQuoteDetail = '/admin/quote-detail';
  static const String adminProducts = '/admin/products';
  static const String adminSuppliers = '/admin/suppliers';
  static const String adminPurchases = '/admin/purchases';
  static const String adminUsers = '/admin/users';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminSettings = '/admin/settings';
}
