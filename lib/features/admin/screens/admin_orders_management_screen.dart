import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/models/order.dart';
import '../../../../shared/models/product.dart';

class AdminOrdersManagementScreen extends StatefulWidget {
  const AdminOrdersManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersManagementScreen> createState() => _AdminOrdersManagementScreenState();
}

class _AdminOrdersManagementScreenState extends State<AdminOrdersManagementScreen> {
  String _filterStatus = 'All';
  final RegExp _moneyRegex = RegExp(r'^\d+(\.\d{1,2})?$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.fetchAllOrders();
      provider.fetchAllUsers();
      provider.fetchAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Manage Orders',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSaleDialog(context),
        child: Icon(Icons.add_shopping_cart),
      ),
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading) {
            return Center(child: CustomLoadingIndicator(message: 'Loading orders...'));
          }

          final filteredOrders = _filterStatus == 'All'
              ? adminProvider.orders
              : adminProvider.orders.where((o) => o.status == _filterStatus).toList();

          return Column(
            children: [
              // Filter buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(12),
                child: Row(
                  children: ['All', 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled']
                      .map((status) => Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: _FilterButton(
                              label: status,
                              isActive: _filterStatus == status,
                              onPressed: () => setState(() => _filterStatus = status),
                            ),
                          ))
                      .toList(),
                ),
              ),
              // Orders list
              Expanded(
                child: filteredOrders.isEmpty
                    ? EmptyState(
                        icon: Icons.shopping_bag_outlined,
                        title: 'No Orders',
                        message: 'No orders match the selected filter',
                        action: CustomButton(
                          label: 'Clear Filters',
                          onPressed: () => setState(() => _filterStatus = 'All'),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: CustomCard(
                              child: ListTile(
                                title: Text('Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}'),
                                subtitle: Text(
                                  '${order.clientName} • \$${order.totalAmount.toStringAsFixed(2)}',
                                ),
                                trailing: Chip(
                                  label: Text(order.status),
                                  backgroundColor: _getStatusColor(order.status),
                                ),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.adminOrderDetail,
                                  arguments: order.id,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateSaleDialog(BuildContext context) {
    final adminProvider = context.read<AdminProvider>();
    if (adminProvider.users.isEmpty || adminProvider.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Users and products must be loaded before creating a sale.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController();
    final unitPriceController = TextEditingController();
    final List<OrderItem> lines = [];

    AdminUser selectedUser = adminProvider.users.first;
    Product selectedProduct = adminProvider.products.first;
    String saleType = 'standard';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Create Sale'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AdminUser>(
                    value: selectedUser,
                    decoration: InputDecoration(
                      labelText: 'Customer',
                      border: OutlineInputBorder(),
                    ),
                    items: adminProvider.users
                        .map((u) => DropdownMenuItem(value: u, child: Text(u.name)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => selectedUser = value);
                    },
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: saleType,
                    decoration: InputDecoration(
                      labelText: 'Sale Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'standard', child: Text('Standard')),
                      DropdownMenuItem(value: 'store', child: Text('In-Store (CASH)')),
                      DropdownMenuItem(value: 'online', child: Text('Online (ONLINE)')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => saleType = value);
                    },
                  ),
                  const Divider(height: 24),
                  DropdownButtonFormField<Product>(
                    value: selectedProduct,
                    decoration: InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(),
                    ),
                    items: adminProvider.products
                        .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => selectedProduct = value);
                    },
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    label: 'Quantity',
                    hint: 'Enter quantity',
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = int.tryParse((value ?? '').trim());
                      if (parsed == null) return 'Quantity must be numeric';
                      if (parsed <= 0) return 'Quantity must be greater than 0';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    label: 'Unit Price',
                    hint: 'Enter unit price',
                    controller: unitPriceController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (!_moneyRegex.hasMatch(text)) return 'Enter a valid amount';
                      final parsed = double.tryParse(text) ?? -1;
                      if (parsed < 0) return 'Unit price cannot be negative';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        lines.add(
                          OrderItem(
                            productId: selectedProduct.id,
                            productName: selectedProduct.name,
                            unitPrice: double.parse(unitPriceController.text.trim()),
                            quantity: int.parse(quantityController.text.trim()),
                          ),
                        );
                        quantityController.clear();
                        unitPriceController.clear();
                        setModalState(() {});
                      },
                      child: Text('Add Line'),
                    ),
                  ),
                  if (lines.isNotEmpty) ...[
                    SizedBox(height: 8),
                    ...lines.map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${line.productName} x${line.quantity}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('\$${line.itemTotal.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (lines.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Add at least one order line.')),
                  );
                  return;
                }

                final success = saleType == 'online'
                    ? await adminProvider.createOnlineSale(
                        userId: selectedUser.id,
                        lines: lines,
                      )
                    : saleType == 'store'
                        ? await adminProvider.createInStoreSale(
                            userId: selectedUser.id,
                            lines: lines,
                          )
                        : await adminProvider.createSale(
                            userId: selectedUser.id,
                            lines: lines,
                          );

                if (!context.mounted) return;
                if (success) {
                  Navigator.pop(context);
                }
              },
              child: Text('Create Sale'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade100;
      case 'confirmed':
        return Colors.blue.shade100;
      case 'shipped':
        return Colors.purple.shade100;
      case 'delivered':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _FilterButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
        foregroundColor: isActive ? Colors.white : Theme.of(context).colorScheme.primary,
      ),
      child: Text(label),
    );
  }
}
