import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/index.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderProvider _orderProvider;

  @override
  void initState() {
    super.initState();
    _orderProvider = context.read<OrderProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order Details',
        onBack: () => Navigator.pop(context),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.clientProfile),
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          final order = orderProvider.selectedOrder ?? orderProvider.getOrderById(widget.orderId);

          if (orderProvider.isLoading) {
            return Center(child: CustomLoadingIndicator(message: 'Loading order details...'));
          }

          if (order == null) {
            return Center(
              child: EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'Order Not Found',
                message: 'This order could not be found.',
                action: CustomButton(
                  label: 'Go Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order header
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 4),
                              Text(
                                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Delivery Information
                Text('Delivery Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 8),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.deliveryAddress,
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Order Items
                Text('Items (${order.items.length})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 8),
                Column(
                  children: order.items.map((item) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${item.unitPrice.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total: \$${((item.quantity) * (item.unitPrice)).toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),

                // Order Summary
                Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 8),
                CustomCard(
                  child: Column(
                    children: [
                      _buildSummaryRow('Subtotal', '\$${order.totalPrice.toStringAsFixed(2)}'),
                      Divider(),
                      _buildSummaryRow('Tax (10%)', '\$${(order.totalPrice * 0.1).toStringAsFixed(2)}', isBold: true),
                      Divider(),
                      _buildSummaryRow('Shipping', '\$5.00', isBold: true),
                      Divider(),
                      _buildSummaryRow(
                        'Total',
                        '\$${(order.totalPrice + (order.totalPrice * 0.1) + 5).toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Action button
                if (order.status == 'Pending')
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'Cancel Order',
                      onPressed: () => _cancelOrder(order.id),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 16 : 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold || isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 13,
              color: isTotal ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Cancel Order?',
        message: 'Are you sure you want to cancel this order?',
        confirmLabel: 'Cancel Order',
        cancelLabel: 'Keep Order',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirmed == true) {
      final success = await _orderProvider.cancelOrder(orderId);
      if (success) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => SuccessDialog(
              title: 'Order Cancelled',
              message: 'Your order has been cancelled successfully.',
              onDismiss: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          );
        }
      }
    }
  }
}
