import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<AdminProvider>().fetchAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Order Details',
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          final order = adminProvider.orders.firstWhere(
            (o) => o.id == widget.orderId,
            orElse: () => throw Exception('Order not found'),
          );

          _selectedStatus ??= order.status;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Chip(label: Text(order.status)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Created: ${order.createdAt}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Client Information
                Text('Client Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${order.clientName}'),
                        SizedBox(height: 8),
                        Text('Phone: ${order.clientPhone}'),
                        SizedBox(height: 8),
                        Text('Address: ${order.deliveryAddress}'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Order Items
                Text('Order Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                ...order.items.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: CustomCard(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName, style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Qty: ${item.quantity}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              Text(
                                '\$${(item.unitPrice * item.quantity).toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                SizedBox(height: 16),

                // Order Summary
                CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal:'),
                            Text('\$${(order.totalAmount - order.taxAmount - order.shippingAmount).toStringAsFixed(2)}'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tax:'),
                            Text('\$${order.taxAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Shipping:'),
                            Text('\$${order.shippingAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                              '\$${order.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Update Status
                Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value);
                    },
                  ),
                ),
                SizedBox(height: 16),
                CustomButton(
                  label: 'Save Status',
                  onPressed: () async {
                    if (_selectedStatus != null && _selectedStatus != order.status) {
                      final success = _selectedStatus == 'cancelled'
                          ? await adminProvider.cancelOrder(widget.orderId)
                          : await adminProvider.updateOrderStatus(widget.orderId, _selectedStatus!);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order status updated')),
                        );
                      }
                    }
                  },
                ),
                SizedBox(height: 12),
                CustomButton(
                  label: 'Delete Order',
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Order?'),
                        content: Text('This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final success = await adminProvider.deleteOrder(widget.orderId);
                    if (!context.mounted) return;
                    if (success) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(adminProvider.error ?? 'Failed to delete order')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
