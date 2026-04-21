import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';

/// Custom App Bar with consistent styling
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showBackButton;
  final Color? backgroundColor;
  final double elevation;
  final bool showAdminMenu;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
    this.showBackButton = true,
    this.backgroundColor,
    this.elevation = 0,
    this.showAdminMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    final mergedActions = <Widget>[
      if (actions != null) ...actions!,
      if (showAdminMenu)
        PopupMenuButton<String>(
          icon: const Icon(Icons.dashboard_customize),
          onSelected: (value) {
            Navigator.of(context).pushNamed(value);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: AppRoutes.adminDashboard,
              child: Text('Dashboard'),
            ),
            PopupMenuItem(
              value: AppRoutes.adminOrders,
              child: Text('Orders'),
            ),
            PopupMenuItem(
              value: AppRoutes.adminQuotes,
              child: Text('Quotes'),
            ),
            PopupMenuItem(
              value: AppRoutes.adminProducts,
              child: Text('Products'),
            ),
            PopupMenuItem(
              value: AppRoutes.adminSuppliers,
              child: Text('Suppliers'),
            ),
            PopupMenuItem(
              value: AppRoutes.adminPurchases,
              child: Text('Purchases'),
            ),
            PopupMenuItem(
              value: AppRoutes.adminUsers,
              child: Text('Users'),
            ),
            PopupMenuItem(
              value: AppRoutes.adminAnalytics,
              child: Text('Analytics'),
            ),
            PopupMenuItem(
              value: AppRoutes.adminSettings,
              child: Text('Settings'),
            ),
          ],
        ),
    ];

    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: mergedActions.isEmpty ? null : mergedActions,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
