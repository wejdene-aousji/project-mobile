import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';

class ClientBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const ClientBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) return;

        final route = _routeForIndex(index);
        Navigator.of(context).pushReplacementNamed(route);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront),
          label: 'Catalog',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Icon(Icons.request_quote_outlined),
          selectedIcon: Icon(Icons.request_quote),
          label: 'Quotes',
        ),
      ],
    );
  }

  String _routeForIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutes.clientProducts;
      case 1:
        return AppRoutes.clientCart;
      case 2:
        return AppRoutes.clientOrders;
      case 3:
        return AppRoutes.clientQuotes;
      default:
        return AppRoutes.clientProducts;
    }
  }
}
