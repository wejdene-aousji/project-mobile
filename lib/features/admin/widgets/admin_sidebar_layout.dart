import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class AdminSidebarLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;

  const AdminSidebarLayout({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        showBackButton: false,
      ),
      floatingActionButton: floatingActionButton,
      drawer: isDesktop
          ? null
          : Drawer(
              child: SafeArea(
                child: _AdminSidebarContent(onNavigate: (route) {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, route);
                }),
              ),
            ),
      body: isDesktop
          ? Row(
              children: [
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: SafeArea(
                    child: _AdminSidebarContent(onNavigate: (route) {
                      Navigator.pushNamed(context, route);
                    }),
                  ),
                ),
                Expanded(child: child),
              ],
            )
          : child,
    );
  }
}

class _AdminSidebarContent extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const _AdminSidebarContent({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Admin Panel',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        _SidebarTile(
          icon: Icons.dashboard,
          label: 'Dashboard',
          onTap: () => onNavigate(AppRoutes.adminDashboard),
        ),
        _SidebarTile(
          icon: Icons.shopping_bag,
          label: 'Orders',
          onTap: () => onNavigate(AppRoutes.adminOrders),
        ),
        _SidebarTile(
          icon: Icons.description,
          label: 'Quotes',
          onTap: () => onNavigate(AppRoutes.adminQuotes),
        ),
        _SidebarTile(
          icon: Icons.inventory,
          label: 'Products',
          onTap: () => onNavigate(AppRoutes.adminProducts),
        ),
        _SidebarTile(
          icon: Icons.local_shipping,
          label: 'Suppliers',
          onTap: () => onNavigate(AppRoutes.adminSuppliers),
        ),
        _SidebarTile(
          icon: Icons.receipt_long,
          label: 'Purchases',
          onTap: () => onNavigate(AppRoutes.adminPurchases),
        ),
        _SidebarTile(
          icon: Icons.people,
          label: 'Users',
          onTap: () => onNavigate(AppRoutes.adminUsers),
        ),
        _SidebarTile(
          icon: Icons.bar_chart,
          label: 'Analytics',
          onTap: () => onNavigate(AppRoutes.adminAnalytics),
        ),
        _SidebarTile(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () => onNavigate(AppRoutes.adminSettings),
        ),
        const Divider(height: 24),
        _SidebarTile(
          icon: Icons.logout,
          label: 'Logout',
          onTap: () async {
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold?.isDrawerOpen ?? false) {
              Navigator.of(context).pop();
            }

            await context.read<AuthProvider>().logout();
            if (!context.mounted) return;

            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
