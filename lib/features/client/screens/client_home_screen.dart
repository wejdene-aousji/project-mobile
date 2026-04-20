import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import 'auth/login_screen.dart';
import 'products/products_list_screen.dart';

/// Client Home Screen - Entry point for authenticated clients
class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }
        if (authProvider.isAdmin) {
          return const AdminDashboardScreen();
        }
        return const ProductsListScreen();
      },
    );
  }
}
