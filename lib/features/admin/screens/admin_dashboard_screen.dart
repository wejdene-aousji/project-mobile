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
  DateTime _periodStart = DateTime.now().subtract(Duration(days: 30));
  DateTime _periodEnd = DateTime.now();
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
    // Load analytics snippets directly into dashboard
    adminProvider.fetchTopProductsStats();
    adminProvider.fetchLowProductsStats();
    adminProvider.fetchDailySalesStats();
    adminProvider.fetchDailyRevenueStats();
    adminProvider.fetchPeriodRevenue(start: _periodStart, end: _periodEnd);
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodStart,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _periodStart = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodEnd,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _periodEnd = picked);
    }
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
                  SizedBox(height: 24),

                  // Period & Daily statistics (moved from analytics page)
                  Text(
                    'Revenue (Last 30 days)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Period selectors
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async => _pickStartDate(),
                          child: Text('Start: ${_periodStart.toIso8601String().split('T').first}'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async => _pickEndDate(),
                          child: Text('End: ${_periodEnd.toIso8601String().split('T').first}'),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await adminProvider.fetchPeriodRevenue(start: _periodStart, end: _periodEnd);
                        },
                        child: Text('Apply'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  CustomCard(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Period Revenue (30d)', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${adminProvider.periodRevenue.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Daily Sales & Daily Revenue
                  Row(
                    children: [
                      Expanded(
                        child: CustomCard(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily Sales', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                if (adminProvider.dailySalesStats.isEmpty)
                                  Text('No daily sales data')
                                else
                                  ...adminProvider.dailySalesStats.entries.take(10).map((e) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [Text(e.key), Text(e.value.toString(), style: TextStyle(fontWeight: FontWeight.bold))],
                                        ),
                                      )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: CustomCard(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                if (adminProvider.dailyRevenueStats.isEmpty)
                                  Text('No daily revenue data')
                                else
                                  ...adminProvider.dailyRevenueStats.entries.take(10).map((e) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [Text(e.key), Text('\$${e.value.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold))],
                                        ),
                                      )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Analytics snippets (Top / Low products)
                  Text(
                    'Analytics',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomCard(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Top Products', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                ...adminProvider.topProductsStats.entries.map((e) {
                                  final matches = adminProvider.products.where((p) => p.id == e.key).toList();
                                  final numericMatch = matches.isEmpty && int.tryParse(e.key) != null
                                      ? adminProvider.products.where((p) => int.tryParse(p.id) == int.tryParse(e.key)).toList()
                                      : [];
                                  final productObj = matches.isNotEmpty
                                      ? matches.first
                                      : (numericMatch.isNotEmpty ? numericMatch.first : null);
                                  final label = productObj != null ? productObj.name : 'Product #${e.key}';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [Text(label), Text(e.value.toString(), style: TextStyle(fontWeight: FontWeight.bold))],
                                    ),
                                  );
                                }).take(5).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: CustomCard(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Low Stock', style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                ...adminProvider.lowProductsStats.entries.map((e) {
                                  final matches = adminProvider.products.where((p) => p.id == e.key).toList();
                                  final numericMatch = matches.isEmpty && int.tryParse(e.key) != null
                                      ? adminProvider.products.where((p) => int.tryParse(p.id) == int.tryParse(e.key)).toList()
                                      : [];
                                  final productObj = matches.isNotEmpty
                                      ? matches.first
                                      : (numericMatch.isNotEmpty ? numericMatch.first : null);
                                  final label = productObj != null ? productObj.name : 'Product #${e.key}';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [Text(label), Text(e.value.toString(), style: TextStyle(fontWeight: FontWeight.bold))],
                                    ),
                                  );
                                }).take(5).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Management Sections (moved to bottom)
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
                          // Analytics and Settings removed; analytics shown on this dashboard
                        ],
                      );
                    },
                  ),
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
