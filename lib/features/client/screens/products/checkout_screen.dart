import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/index.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/client_bottom_nav_bar.dart';

/// Checkout Screen
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    super.dispose();
  }

  void _placeOrder() async {
    setState(() => _isPlacingOrder = true);

    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    // Build order lines
    final orderLines = cart.items.map((item) {
      return {
        'product': {'productId': int.tryParse(item.productId) ?? item.productId},
        'quantity': item.quantity,
        'unitPrice': item.productPrice,
        'subtotal': item.totalPrice,
      };
    }).toList();

    final summary = cart.getCartSummary();

    final success = await orderProvider.createOrder(
      orderLines: orderLines,
      totalPrice: summary['total'] as double,
      paymentMethod: 'cod',
    );

    if (mounted) {
      setState(() => _isPlacingOrder = false);

      if (success) {
        // Clear cart
        cart.clearCart();

        SuccessDialog.show(
          context,
          title: 'Order Placed',
          message: 'Your order has been placed successfully!',
          onDismiss: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.clientOrders);
          },
        );
      } else {
        // Show error
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text(orderProvider.error ?? 'Failed to place order'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Checkout',
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
          final summary = cartProvider.getCartSummary();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                // Order Summary Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _OrderSummaryItem(
                        label: 'Subtotal',
                        value:
                            '\$${(summary['subtotal'] as double).toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _OrderSummaryItem(
                        label: 'Tax (10%)',
                        value: '\$${(summary['tax'] as double).toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _OrderSummaryItem(
                        label: 'Shipping',
                        value:
                            '\$${(summary['shipping'] as double).toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      _OrderSummaryItem(
                        label: 'Total',
                        value:
                            '\$${(summary['total'] as double).toStringAsFixed(2)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Payment Method Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Method',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      CustomCard(
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Payment at Delivery',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pay when your order arrives',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Place Order Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    label: 'Place Order',
                    onPressed: _placeOrder,
                    isLoading: _isPlacingOrder,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderSummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _OrderSummaryItem({
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
