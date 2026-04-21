import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/services/service_locator.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'features/client/providers/product_provider.dart';
import 'features/client/providers/cart_provider.dart';
import 'features/client/providers/order_provider.dart';
import 'features/client/providers/quote_provider.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/admin_orders_management_screen.dart';
import 'features/admin/screens/admin_quotes_management_screen.dart';
import 'features/admin/screens/admin_products_management_screen.dart';
import 'features/admin/screens/admin_suppliers_management_screen.dart';
import 'features/admin/screens/admin_purchases_management_screen.dart';
import 'features/admin/screens/admin_users_management_screen.dart';
import 'features/admin/screens/admin_analytics_screen.dart';
import 'features/admin/screens/admin_settings_screen.dart';
import 'features/admin/screens/admin_order_detail_screen.dart';
import 'features/admin/screens/admin_quote_detail_screen.dart';
import 'features/client/screens/auth/login_screen.dart';
import 'features/client/screens/auth/signup_screen.dart';
import 'features/client/screens/products/products_list_screen.dart';
import 'features/client/screens/products/product_detail_screen.dart';
import 'features/client/screens/products/cart_screen.dart';
import 'features/client/screens/products/checkout_screen.dart';
import 'features/client/screens/orders/order_history_screen.dart';
import 'features/client/screens/orders/order_detail_screen.dart';
import 'features/client/screens/quotes/quote_request_screen.dart';
import 'features/client/screens/quotes/quote_history_screen.dart';
import 'features/client/screens/quotes/quote_detail_screen.dart';
import 'features/client/screens/profile/client_profile_screen.dart';
import 'features/client/screens/client_home_screen.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(ServiceLocator.authService),
        ),
        // Navigation Provider
        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
        ),
        // Product Provider
        ChangeNotifierProvider(
          create: (_) => ProductProvider(ServiceLocator.apiService),
        ),
        // Cart Provider
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        // Order Provider
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
        // Quote Provider
        ChangeNotifierProvider(
          create: (_) => QuoteProvider(),
        ),
        // Admin Provider
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.light,
        initialRoute: _resolveInitialRoute(),
        onGenerateRoute: _generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  static String _resolveInitialRoute() {
    final authService = ServiceLocator.authService;
    if (authService.isAuthenticated == true) {
      return authService.isAdmin == true ? '/admin/dashboard' : '/client/home';
    }
    return '/login';
  }

  static Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case '/signup':
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );

      // Client Routes
      case '/client/home':
        return MaterialPageRoute(
          builder: (_) => const ClientHomeScreen(),
        );
      case '/client/products':
        return MaterialPageRoute(
          builder: (_) => const ProductsListScreen(),
        );
      case '/client/product-detail':
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId),
        );
      case '/client/cart':
        return MaterialPageRoute(
          builder: (_) => const CartScreen(),
        );
      case '/client/checkout':
        return MaterialPageRoute(
          builder: (_) => const CheckoutScreen(),
        );
      case '/client/profile':
        return MaterialPageRoute(
          builder: (_) => const ClientProfileScreen(),
        );

      // Order Routes
      case '/client/orders':
        return MaterialPageRoute(
          builder: (_) => const OrderHistoryScreen(),
        );
      case '/client/order-detail':
        final orderId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderId: orderId),
        );

      // Quote Routes
      case '/client/quote-request':
        return MaterialPageRoute(
          builder: (_) => const QuoteRequestScreen(),
        );
      case '/client/quotes':
        return MaterialPageRoute(
          builder: (_) => const QuoteHistoryScreen(),
        );
      case '/client/quote-detail':
        final quoteId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => QuoteDetailScreen(quoteId: quoteId),
        );

      // Admin Routes
      case '/admin/dashboard':
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        );
      case '/admin/orders':
        return MaterialPageRoute(
          builder: (_) => const AdminOrdersManagementScreen(),
        );
      case '/admin/order-detail':
        final orderId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AdminOrderDetailScreen(orderId: orderId),
        );
      case '/admin/quotes':
        return MaterialPageRoute(
          builder: (_) => const AdminQuotesManagementScreen(),
        );
      case '/admin/quote-detail':
        final quoteId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AdminQuoteDetailScreen(quoteId: quoteId),
        );
      case '/admin/products':
        return MaterialPageRoute(
          builder: (_) => const AdminProductsManagementScreen(),
        );
      case '/admin/suppliers':
        return MaterialPageRoute(
          builder: (_) => const AdminSuppliersManagementScreen(),
        );
      case '/admin/purchases':
        return MaterialPageRoute(
          builder: (_) => const AdminPurchasesManagementScreen(),
        );
      case '/admin/users':
        return MaterialPageRoute(
          builder: (_) => const AdminUsersManagementScreen(),
        );
      case '/admin/analytics':
        return MaterialPageRoute(
          builder: (_) => const AdminAnalyticsScreen(),
        );
      case '/admin/settings':
        return MaterialPageRoute(
          builder: (_) => const AdminSettingsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
