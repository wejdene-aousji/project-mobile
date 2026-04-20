import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../core/constants/app_routes.dart';

class AdminOrdersManagementScreen extends StatefulWidget {
  const AdminOrdersManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrdersManagementScreen> createState() => _AdminOrdersManagementScreenState();
}

class _AdminOrdersManagementScreenState extends State<AdminOrdersManagementScreen> {
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    context.read<AdminProvider>().fetchAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Manage Orders',
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
