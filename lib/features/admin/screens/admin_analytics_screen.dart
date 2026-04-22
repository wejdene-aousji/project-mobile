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
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    final adminProvider = context.read<AdminProvider>();
    adminProvider.fetchStatistics();
    adminProvider.fetchAllProducts();
    adminProvider.fetchTopProductsStats();
    adminProvider.fetchLowProductsStats();
    adminProvider.fetchDailySalesStats();
    adminProvider.fetchDailyRevenueStats();
    adminProvider.fetchPeriodRevenue(start: _startDate, end: _endDate);
  }

  String _resolveProductLabel(String rawKey, AdminProvider adminProvider) {
    final match = adminProvider.products.where((p) => p.id == rawKey).toList();
    if (match.isNotEmpty) return match.first.name;

    final numeric = int.tryParse(rawKey);
    if (numeric != null) {
      final numericMatch = adminProvider.products
          .where((p) => int.tryParse(p.id) == numeric)
          .toList();
      if (numericMatch.isNotEmpty) return numericMatch.first.name;
    }

    return 'Product #$rawKey';
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: _endDate,
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      await context.read<AdminProvider>().fetchPeriodRevenue(
            start: _startDate,
            end: _endDate,
          );
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(Duration(days: 3650)),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      await context.read<AdminProvider>().fetchPeriodRevenue(
            start: _startDate,
            end: _endDate,
          );
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Analytics & Reports',
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          final stats = adminProvider.stats;
          final topProducts = adminProvider.topProductsStats.entries
              .map(
                (entry) => MapEntry(
                  _resolveProductLabel(entry.key, adminProvider),
                  entry.value,
                ),
              )
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final lowProducts = adminProvider.lowProductsStats.entries
              .map(
                (entry) => MapEntry(
                  _resolveProductLabel(entry.key, adminProvider),
                  entry.value,
                ),
              )
              .toList()
            ..sort((a, b) => a.value.compareTo(b.value));
          final dailySales = adminProvider.dailySalesStats.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
          final dailyRevenue = adminProvider.dailyRevenueStats.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

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
                          value: '\$${((stats['total_revenue'] ?? 0) as num).toStringAsFixed(2)}',
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
                          title: 'Period Revenue',
                          value: '\$${adminProvider.periodRevenue.toStringAsFixed(2)}',
                          icon: Icons.date_range,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _AnalyticsCard(
                          title: 'Total Products',
                          value: '${stats['total_products'] ?? 0}',
                          icon: Icons.inventory_2,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Period Revenue Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  CustomCard(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickStartDate,
                                  icon: Icon(Icons.calendar_today),
                                  label: Text('Start: ${_formatDate(_startDate)}'),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickEndDate,
                                  icon: Icon(Icons.event),
                                  label: Text('End: ${_formatDate(_endDate)}'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<AdminProvider>().fetchPeriodRevenue(
                                      start: _startDate,
                                      end: _endDate,
                                    );
                              },
                              icon: Icon(Icons.refresh),
                              label: Text('Refresh Period Revenue'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Top products
                  Text(
                    'Top Products',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _StatsMapCard(
                    emptyLabel: 'No top products data.',
                    entries: topProducts,
                  ),
                  SizedBox(height: 24),

                  // Low stock products
                  Text(
                    'Low Stock Products',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _StatsMapCard(
                    emptyLabel: 'No low stock products data.',
                    entries: lowProducts,
                  ),
                  SizedBox(height: 24),

                  // Daily sales
                  Text(
                    'Daily Sales',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _StatsMapCard(
                    emptyLabel: 'No daily sales data.',
                    entries: dailySales,
                  ),
                  SizedBox(height: 24),

                  // Daily revenue
                  Text(
                    'Daily Revenue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _StatsMapCard(
                    emptyLabel: 'No daily revenue data.',
                    entries: dailyRevenue,
                    valueBuilder: (value) => '\$${(value as double).toStringAsFixed(2)}',
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

class _StatsMapCard extends StatelessWidget {
  final List<MapEntry<String, dynamic>> entries;
  final String emptyLabel;
  final String Function(dynamic)? valueBuilder;

  const _StatsMapCard({
    required this.entries,
    required this.emptyLabel,
    this.valueBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: entries.isEmpty
            ? Text(
                emptyLabel,
                style: TextStyle(color: Colors.grey[600]),
              )
            : Column(
                children: List.generate(entries.length, (index) {
                  final entry = entries[index];
                  final valueText = valueBuilder != null
                      ? valueBuilder!(entry.value)
                      : entry.value.toString();

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(entry.key)),
                          Text(
                            valueText,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (index < entries.length - 1) Divider(),
                    ],
                  );
                }),
              ),
      ),
    );
  }
}
