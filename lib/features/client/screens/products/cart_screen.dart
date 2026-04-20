import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/index.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/client_bottom_nav_bar.dart';

/// Cart Screen
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Shopping Cart',
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.clientProfile),
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNavBar(currentIndex: 1),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Cart is Empty',
              message: 'Add some products to your cart',
              action: CustomButton(
                label: 'Continue Shopping',
                  onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.clientProducts),
              ),
            );
          }

          final summary = cartProvider.getCartSummary();

          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return _CartItemCard(item: item);
                  },
                ),
              ),
              // Order Summary
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Subtotal',
                      value:
                          '\$${(summary['subtotal'] as double).toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Tax (10%)',
                      value: '\$${(summary['tax'] as double).toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Shipping',
                      value:
                          '\$${(summary['shipping'] as double).toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Total',
                      value: '\$${(summary['total'] as double).toStringAsFixed(2)}',
                      isBold: true,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Proceed to Checkout',
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.clientCheckout);
                      },
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Cart Item Card
class _CartItemCard extends StatelessWidget {
  final dynamic item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Product Image Placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.productImage != null
                ? Image.network(item.productImage!, fit: BoxFit.cover)
                : Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                  ),
          ),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.productPrice.toStringAsFixed(2)} each',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Subtotal: \$${item.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Quantity & Remove
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton<int>(
                child: Text(
                  'Qty: ${item.quantity}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                itemBuilder: (context) => List.generate(
                  10,
                  (i) => PopupMenuItem(
                    value: i + 1,
                    child: Text('${i + 1}'),
                  ),
                ),
                onSelected: (quantity) {
                  context.read<CartProvider>().updateQuantity(item.productId, quantity);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  context.read<CartProvider>().removeItem(item.productId);
                },
                color: Theme.of(context).colorScheme.error,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Summary Row Widget
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
