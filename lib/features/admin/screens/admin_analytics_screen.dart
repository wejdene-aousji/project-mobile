import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    final adminProvider = context.read<AdminProvider>();
    adminProvider.fetchStatistics();
    adminProvider.fetchAllOrders();
    adminProvider.fetchAllQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Analytics & Reports',
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          final stats = adminProvider.stats;

          return RefreshIndicator(
            onRefresh: () async {
              _loadAnalytics();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Metrics
                  Text(
                    'Key Metrics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _AnalyticsCard(
                          title: 'Total Revenue',
                          value: '\$${(stats['total_revenue'] ?? 0).toStringAsFixed(2)}',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _AnalyticsCard(
                          title: 'Total Orders',
                          value: '${stats['total_orders'] ?? 0}',
                          icon: Icons.shopping_bag,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _AnalyticsCard(
                          title: 'Pending Orders',
                          value: '${stats['pending_orders'] ?? 0}',
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _AnalyticsCard(
                          title: 'Total Quotes',
                          value: '${stats['total_quotes'] ?? 0}',
                          icon: Icons.description,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Order Status Distribution
                  Text(
                    'Order Status Distribution',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  CustomCard(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _StatusRow(
                            status: 'Pending',
                            count: adminProvider.orders.where((o) => o.status == 'pending').length,
                            color: Colors.orange,
                          ),
                          Divider(),
                          _StatusRow(
                            status: 'Confirmed',
                            count: adminProvider.orders.where((o) => o.status == 'confirmed').length,
                            color: Colors.blue,
                          ),
                          Divider(),
                          _StatusRow(
                            status: 'Shipped',
                            count: adminProvider.orders.where((o) => o.status == 'shipped').length,
                            color: Colors.purple,
                          ),
                          Divider(),
                          _StatusRow(
                            status: 'Delivered',
                            count: adminProvider.orders.where((o) => o.status == 'delivered').length,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Quote Status Distribution
                  Text(
                    'Quote Status Distribution',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  CustomCard(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _StatusRow(
                            status: 'Pending',
                            count: adminProvider.quotes.where((q) => q.status == 'pending').length,
                            color: Colors.orange,
                          ),
                          Divider(),
                          _StatusRow(
                            status: 'Accepted',
                            count: adminProvider.quotes.where((q) => q.status == 'accepted').length,
                            color: Colors.green,
                          ),
                          Divider(),
                          _StatusRow(
                            status: 'Rejected',
                            count: adminProvider.quotes.where((q) => q.status == 'rejected').length,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // System Stats
                  Text(
                    'System Statistics',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  CustomCard(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _StatRow(
                            label: 'Total Products',
                            value: '${stats['total_products'] ?? 0}',
                          ),
                          Divider(),
                          _StatRow(
                            label: 'Total Users',
                            value: '${stats['total_users'] ?? 0}',
                          ),
                          Divider(),
                          _StatRow(
                            label: 'Average Order Value',
                            value: adminProvider.orders.isEmpty
                                ? '\$0.00'
                                : '\$${(adminProvider.orders.fold<double>(0, (sum, o) => sum + o.totalAmount) / adminProvider.orders.length).toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  ),
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

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String status;
  final int count;
  final Color color;

  const _StatusRow({
    required this.status,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 12),
            Text(status),
          ],
        ),
        Text(
          count.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
