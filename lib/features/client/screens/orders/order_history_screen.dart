import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../core/constants/app_routes.dart';
import '../../providers/order_provider.dart';
import '../../widgets/client_bottom_nav_bar.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late OrderProvider _orderProvider;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _orderProvider = context.read<OrderProvider>();
    _orderProvider.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order History',
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.clientProfile),
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNavBar(currentIndex: 2),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return Center(
              child: CustomLoadingIndicator(message: 'Loading orders...'),
            );
          }

          // Clear transient errors if we still have cached orders
          if (orderProvider.error != null && orderProvider.orders.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) => orderProvider.clearError());
          }

          if (orderProvider.error != null && orderProvider.orders.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error',
                message: orderProvider.error!,
                action: CustomButton(
                  label: 'Retry',
                  onPressed: () => orderProvider.fetchOrders(),
                ),
              ),
            );
          }

          if (orderProvider.orderCount == 0) {
            return Center(
              child: EmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'No Orders Yet',
                message: 'Your order history is empty. Start shopping to place your first order!',
                action: CustomButton(
                  label: 'Start Shopping',
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.clientProducts),
                ),
              ),
            );
          }

          final filteredOrders = orderProvider.filteredOrders;

          return Column(
            children: [
              // Filter buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildStatusFilter('All'),
                    _buildStatusFilter('Pending'),
                    _buildStatusFilter('Completed'),
                    _buildStatusFilter('Cancelled'),
                  ],
                ),
              ),
              // Order stats
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: _buildStatsRow(orderProvider.getOrderStats()),
              ),
              // Orders list
              Expanded(
                child: filteredOrders.isEmpty
                    ? Center(
                        child: EmptyState(
                          icon: Icons.filter_list_off,
                          title: 'No Orders Found',
                          message: 'No orders match the selected filter.',
                          action: CustomButton(
                            label: 'Clear Filters',
                            onPressed: () {
                                  _selectedStatus = 'All';
                                  orderProvider.filterByStatus('All');
                            },
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return _buildOrderCard(context, order);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusFilter(String status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: CustomButton(
        label: status,
        onPressed: () {
          setState(() => _selectedStatus = status);
          _orderProvider.filterByStatus(status);
        },
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
        textColor: isSelected ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomCard(
          child: Column(
            children: [
              Text('${stats['total']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
              Text('Total Orders', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        CustomCard(
          child: Column(
            children: [
              Text('${stats['pending']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
              Text('Pending', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        CustomCard(
          child: Column(
            children: [
              Text('${stats['completed']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              Text('Completed', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    final statusColor = _getStatusColor(order.status);
    final formattedDate = order.createdAt != null
        ? '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}'
        : 'Unknown';

    return CustomCard(
      onTap: () {
        _orderProvider.fetchOrderById(order.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: order.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  order.status ?? 'Unknown',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Amount', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    '\$${order.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    '${order.items?.length ?? 0} items',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    switch (s) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
