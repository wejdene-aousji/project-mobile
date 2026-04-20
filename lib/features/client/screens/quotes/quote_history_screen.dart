import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/index.dart';
import '../../../../core/constants/app_routes.dart';
import '../../providers/quote_provider.dart';
import '../../widgets/client_bottom_nav_bar.dart';
import 'quote_detail_screen.dart';

class QuoteHistoryScreen extends StatefulWidget {
  const QuoteHistoryScreen({Key? key}) : super(key: key);

  @override
  State<QuoteHistoryScreen> createState() => _QuoteHistoryScreenState();
}

class _QuoteHistoryScreenState extends State<QuoteHistoryScreen> {
  late QuoteProvider _quoteProvider;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _quoteProvider = context.read<QuoteProvider>();
    _quoteProvider.fetchQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quote Requests',
        showBackButton: false,
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.clientProfile),
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNavBar(currentIndex: 3),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.clientQuoteRequest),
        child: Icon(Icons.add),
        tooltip: 'Request New Quote',
      ),
      body: Consumer<QuoteProvider>(
        builder: (context, quoteProvider, _) {
          if (quoteProvider.isLoading) {
            return Center(
              child: CustomLoadingIndicator(message: 'Loading quotes...'),
            );
          }

          if (quoteProvider.error != null) {
            return Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error',
                message: quoteProvider.error!,
                action: CustomButton(
                  label: 'Retry',
                  onPressed: () => quoteProvider.fetchQuotes(),
                ),
              ),
            );
          }

          if (quoteProvider.quoteCount == 0) {
            return Center(
              child: EmptyState(
                icon: Icons.description_outlined,
                title: 'No Quotes Yet',
                message: 'You haven\'t requested any quotes yet.',
                action: CustomButton(
                  label: 'Request a Quote',
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.clientQuoteRequest),
                ),
              ),
            );
          }

          final filteredQuotes = quoteProvider.filteredQuotes;

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
                    _buildStatusFilter('Accepted'),
                    _buildStatusFilter('Rejected'),
                    _buildStatusFilter('Expired'),
                  ],
                ),
              ),
              // Quote stats
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: _buildStatsRow(quoteProvider.getQuoteStats()),
              ),
              // Quotes list
              Expanded(
                child: filteredQuotes.isEmpty
                    ? Center(
                        child: EmptyState(
                          icon: Icons.filter_list_off,
                          title: 'No Quotes Found',
                          message: 'No quotes match the selected filter.',
                          action: CustomButton(
                            label: 'Clear Filters',
                            onPressed: () {
                              _selectedStatus = 'All';
                              quoteProvider.filterByStatus('All');
                            },
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredQuotes.length,
                        itemBuilder: (context, index) {
                          final quote = filteredQuotes[index];
                          return _buildQuoteCard(context, quote);
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
          _quoteProvider.filterByStatus(status);
        },
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
        textColor: isSelected ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomCard(
            child: Column(
              children: [
                Text('${stats['total']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(width: 8),
          CustomCard(
            child: Column(
              children: [
                Text('${stats['pending']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                Text('Pending', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(width: 8),
          CustomCard(
            child: Column(
              children: [
                Text('${stats['accepted']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Accepted', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(width: 8),
          CustomCard(
            child: Column(
              children: [
                Text('${stats['rejected']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                Text('Rejected', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context, dynamic quote) {
    final statusColor = _getStatusColor(quote.status);
    final formattedDate = quote.requestDate != null
        ? '${quote.requestDate!.day}/${quote.requestDate!.month}/${quote.requestDate!.year}'
        : 'Unknown';

    return CustomCard(
      onTap: () {
        _quoteProvider.fetchQuoteById(quote.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuoteDetailScreen(quoteId: quote.id),
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
                      'Quote #${quote.id.substring(0, quote.id.length > 8 ? 8 : quote.id.length).toUpperCase()}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Requested: $formattedDate',
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
                  quote.status ?? 'Unknown',
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
          Text(
            quote.description ?? 'No description',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    '${quote.items?.length ?? 0} items',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (quote.expiryDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Expires', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      '${quote.expiryDate!.day}/${quote.expiryDate!.month}/${quote.expiryDate!.year}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
          // Action buttons for pending quotes
          if (quote.status == 'Pending')
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedCustomButton(
                      label: 'Accept',
                      onPressed: () => _acceptQuote(quote.id),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      label: 'Reject',
                      onPressed: () => _rejectQuote(quote.id),
                    ),
                  ),
                ],
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
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Expired':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Future<void> _acceptQuote(String quoteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Accept Quote?',
        message: 'Are you sure you want to accept this quote?',
        confirmLabel: 'Accept',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirmed == true) {
      final success = await _quoteProvider.acceptQuote(quoteId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quote accepted successfully!')),
        );
      }
    }
  }

  Future<void> _rejectQuote(String quoteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Reject Quote?',
        message: 'Are you sure you want to reject this quote?',
        confirmLabel: 'Reject',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );

    if (confirmed == true) {
      final success = await _quoteProvider.rejectQuote(quoteId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quote rejected successfully!')),
        );
      }
    }
  }
}
