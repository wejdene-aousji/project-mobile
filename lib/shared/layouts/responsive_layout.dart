import 'package:flutter/material.dart';

/// Responsive layout helpers
class ResponsiveBreakpoints {
  // Screen size breakpoints
  static const double mobile = 600;      // < 600: mobile
  static const double tablet = 900;      // 600-900: tablet
  static const double desktop = 1200;    // >= 1200: desktop

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }

  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 1400;
    if (isTablet(context)) return 800;
    return double.infinity;
  }

  static EdgeInsets getPadding(BuildContext context) {
    if (isDesktop(context)) return EdgeInsets.all(24);
    if (isTablet(context)) return EdgeInsets.all(16);
    return EdgeInsets.all(12);
  }
}

/// Responsive layout wrapper that displays content appropriately for screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobile) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Adaptive scaffold that shows navigation based on screen size
class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<BottomNavigationBarItem>? bottomNavItems;
  final int selectedBottomIndex;
  final Function(int)? onBottomNavChanged;
  final List<Widget>? sidebarItems;
  final VoidCallback? onMenuPressed;
  final FloatingActionButton? floatingActionButton;
  final PreferredSizeWidget? appBar;

  const AdaptiveScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.bottomNavItems,
    this.selectedBottomIndex = 0,
    this.onBottomNavChanged,
    this.sidebarItems,
    this.onMenuPressed,
    this.floatingActionButton,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileScaffold(context),
      tablet: _buildTabletScaffold(context),
      desktop: _buildDesktopScaffold(context),
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavItems != null
          ? BottomNavigationBar(
              items: bottomNavItems!,
              currentIndex: selectedBottomIndex,
              onTap: onBottomNavChanged,
              type: BottomNavigationBarType.fixed,
            )
          : null,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildTabletScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavItems != null
          ? BottomNavigationBar(
              items: bottomNavItems!,
              currentIndex: selectedBottomIndex,
              onTap: onBottomNavChanged,
              type: BottomNavigationBarType.fixed,
            )
          : null,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopScaffold(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          if (sidebarItems != null)
            Container(
              width: 250,
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo/Header
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'AutoParts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Divider(),
                  // Navigation items
                  Expanded(
                    child: ListView(
                      children: sidebarItems!,
                    ),
                  ),
                  Divider(),
                  // Logout button
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top app bar
                if (appBar != null) appBar!,
                // Body
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Sidebar navigation tile
class SidebarNavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarNavTile({
    Key? key,
    required this.label,
    required this.icon,
    required this.route,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
              SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
