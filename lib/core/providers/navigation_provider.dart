import 'package:flutter/material.dart';

/// Navigation provider for managing navigation state across app
class NavigationProvider extends ChangeNotifier {
  String _currentRoute = '/login';
  int _selectedIndex = 0;
  bool _showSidebar = true;

  String get currentRoute => _currentRoute;
  int get selectedIndex => _selectedIndex;
  bool get showSidebar => _showSidebar;

  void setRoute(String route, {int? index}) {
    _currentRoute = route;
    if (index != null) {
      _selectedIndex = index;
    }
    notifyListeners();
  }

  void setSidebarVisible(bool visible) {
    _showSidebar = visible;
    notifyListeners();
  }

  void selectNavItem(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void reset() {
    _currentRoute = '/login';
    _selectedIndex = 0;
  }
}

/// Navigation items model
class NavItem {
  final String label;
  final String route;
  final IconData icon;
  final int index;

  NavItem({
    required this.label,
    required this.route,
    required this.icon,
    required this.index,
  });
}

/// Client navigation items
class ClientNavigation {
  static final items = [
    NavItem(label: 'Home', route: '/client/home', icon: Icons.home, index: 0),
    NavItem(label: 'Products', route: '/client/products', icon: Icons.shopping_bag, index: 1),
    NavItem(label: 'Cart', route: '/client/cart', icon: Icons.shopping_cart, index: 2),
    NavItem(label: 'Orders', route: '/client/orders', icon: Icons.receipt, index: 3),
    NavItem(label: 'Quotes', route: '/client/quotes', icon: Icons.description, index: 4),
  ];
}

/// Admin navigation items
class AdminNavigation {
  static final items = [
    NavItem(label: 'Dashboard', route: '/admin/dashboard', icon: Icons.dashboard, index: 0),
    NavItem(label: 'Orders', route: '/admin/orders', icon: Icons.shopping_bag, index: 1),
    NavItem(label: 'Quotes', route: '/admin/quotes', icon: Icons.description, index: 2),
    NavItem(label: 'Products', route: '/admin/products', icon: Icons.inventory, index: 3),
    NavItem(label: 'Users', route: '/admin/users', icon: Icons.people, index: 4),
    NavItem(label: 'Analytics', route: '/admin/analytics', icon: Icons.bar_chart, index: 5),
    NavItem(label: 'Settings', route: '/admin/settings', icon: Icons.settings, index: 6),
  ];
}
