import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../core/constants/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final adminProvider = context.read<AdminProvider>();
    adminProvider.fetchAllOrders();
    adminProvider.fetchAllQuotes();
    adminProvider.fetchAllProducts();
    adminProvider.fetchAllSuppliers();
    adminProvider.fetchAllPurchases();
    adminProvider.fetchAllUsers();
    adminProvider.fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Admin Dashboard',
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading) {
            return Center(child: CustomLoadingIndicator(message: 'Loading dashboard...'));
          }

          if (adminProvider.error != null) {
            return Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error',
                message: adminProvider.error!,
                action: CustomButton(
                  label: 'Retry',
                  onPressed: _loadData,
                ),
              ),
            );
          }

          final stats = adminProvider.stats;

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final statsColumns = width >= 1200
                          ? 4
                          : width >= 900
                              ? 2
                              : 1;

                      return GridView.count(
                        crossAxisCount: statsColumns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: width >= 900 ? 2.3 : 2.0,
                        children: [
                          _StatisticCard(
                            label: 'Total Orders',
                            value: '${stats['total_orders'] ?? 0}',
                            icon: Icons.shopping_bag,
                            color: Colors.blue,
                          ),
                          _StatisticCard(
                            label: 'Pending Orders',
                            value: '${stats['pending_orders'] ?? 0}',
                            icon: Icons.pending_actions,
                            color: Colors.orange,
                          ),
                          _StatisticCard(
                            label: 'Total Quotes',
                            value: '${stats['total_quotes'] ?? 0}',
                            icon: Icons.description,
                            color: Colors.green,
                          ),
                          _StatisticCard(
                            label: 'Revenue',
                            value: '\$${(stats['total_revenue'] ?? 0).toStringAsFixed(2)}',
                            icon: Icons.trending_up,
                            color: Colors.purple,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24),

                  // Management Sections
                  Text(
                    'Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  // Management Buttons Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final managementColumns = width >= 1200
                          ? 4
                          : width >= 900
                              ? 3
                              : width >= 600
                                  ? 2
                                  : 1;

                      return GridView.count(
                        crossAxisCount: managementColumns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: width >= 900 ? 1.6 : 1.25,
                        children: [
                          _ManagementTile(
                            icon: Icons.shopping_bag,
                            title: 'Orders',
                            subtitle: '${stats['total_orders'] ?? 0} orders',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adminOrders),
                          ),
                          _ManagementTile(
                            icon: Icons.description,
                            title: 'Quotes',
                            subtitle: '${stats['pending_quotes'] ?? 0} pending',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adminQuotes),
                          ),
                          _ManagementTile(
                            icon: Icons.inventory,
                            title: 'Products',
                            subtitle: '${stats['total_products'] ?? 0} products',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adminProducts),
                          ),
                          _ManagementTile(
                            icon: Icons.local_shipping,
                            title: 'Suppliers',
                            subtitle: '${adminProvider.suppliers.length} suppliers',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSuppliers),
                          ),
                          _ManagementTile(
                            icon: Icons.receipt_long,
                            title: 'Purchases',
                            subtitle: '${adminProvider.purchases.length} purchases',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adminPurchases),
                          ),
                          _ManagementTile(
                            icon: Icons.people,
                            title: 'Users',
                            subtitle: '${stats['total_users'] ?? 0} users',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
                          ),
                          _ManagementTile(
                            icon: Icons.bar_chart,
                            title: 'Analytics',
                            subtitle: 'View reports',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adminAnalytics),
                          ),
                          _ManagementTile(
                            icon: Icons.settings,
                            title: 'Settings',
                            subtitle: 'System settings',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adminSettings),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 24),

                  // Recent Orders Section
                  Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  if (adminProvider.orders.isEmpty)
                    EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: 'No Orders',
                      message: 'No orders found',
                      action: CustomButton(
                        label: 'Refresh',
                        onPressed: _loadData,
                      ),
                    )
                  else
                    ...adminProvider.orders.take(5).map((order) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: CustomCard(
                            child: ListTile(
                              title: Text('Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length).toUpperCase()}'),
                              subtitle: Text('${order.status} • ${order.totalAmount}\$'),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.adminOrderDetail,
                                  arguments: order.id,
                                );
                              },
                            ),
                          ),
                        )),
                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManagementTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
