import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../core/constants/app_routes.dart';

class AdminQuotesManagementScreen extends StatefulWidget {
  const AdminQuotesManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminQuotesManagementScreen> createState() => _AdminQuotesManagementScreenState();
}

class _AdminQuotesManagementScreenState extends State<AdminQuotesManagementScreen> {
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    context.read<AdminProvider>().fetchAllQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Manage Quotes',
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading) {
            return Center(child: CustomLoadingIndicator(message: 'Loading quotes...'));
          }

          final filteredQuotes = _filterStatus == 'All'
              ? adminProvider.quotes
              : adminProvider.quotes.where((q) => q.status == _filterStatus).toList();

          return Column(
            children: [
              // Filter buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(12),
                child: Row(
                  children: ['All', 'pending', 'accepted', 'rejected', 'expired']
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
              // Quotes list
              Expanded(
                child: filteredQuotes.isEmpty
                    ? EmptyState(
                        icon: Icons.description_outlined,
                        title: 'No Quotes',
                        message: 'No quotes match the selected filter',
                        action: CustomButton(
                          label: 'Clear Filters',
                          onPressed: () => setState(() => _filterStatus = 'All'),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: filteredQuotes.length,
                        itemBuilder: (context, index) {
                          final quote = filteredQuotes[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: CustomCard(
                              child: ListTile(
                                title: Text('Quote #${quote.id.substring(0, quote.id.length > 8 ? 8 : quote.id.length).toUpperCase()}'),
                                subtitle: Text(
                                  '${quote.clientName} • \$${quote.totalAmount.toStringAsFixed(2)}',
                                ),
                                trailing: Chip(
                                  label: Text(quote.status),
                                  backgroundColor: _getStatusColor(quote.status),
                                ),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.adminQuoteDetail,
                                  arguments: quote.id,
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
      case 'accepted':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      case 'expired':
        return Colors.grey.shade100;
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
