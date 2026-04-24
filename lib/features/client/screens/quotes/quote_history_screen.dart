import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/index.dart';
import '../../../../shared/models/quote.dart';
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
    // Refresh quotes when the screen is first shown
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
        child: const Icon(Icons.add),
        tooltip: 'Request New Quote',
      ),
      body: Consumer<QuoteProvider>(
        builder: (context, quoteProvider, _) {
          if (quoteProvider.isLoading) {
            return const Center(child: CustomLoadingIndicator(message: 'Loading quotes...'));
          }

          // If there is an error but we still have cached quotes, clear the transient error
          if (quoteProvider.error != null && quoteProvider.quotes.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) => quoteProvider.clearError());
          }

          if (quoteProvider.error != null && quoteProvider.quotes.isEmpty) {
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

          if (quoteProvider.quotes.isEmpty && quoteProvider.filterStatus == 'All') {
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

          final List<Quote> filteredQuotes = quoteProvider.filteredQuotes;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    DropdownButton<String>(
                      value: _selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'Accepted', child: Text('Accepted')),
                        DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedStatus = v);
                        quoteProvider.filterByStatus(v);
                      },
                    ),
                  ],
                ),
              ),

              // Quotes list with pull-to-refresh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => quoteProvider.fetchQuotes(),
                  child: filteredQuotes.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 80.0),
                                child: EmptyState(
                                  icon: Icons.filter_list_off,
                                  title: 'No Quotes Found',
                                  message: 'No quotes match the selected filter.',
                                  action: CustomButton(
                                    label: 'Clear Filters',
                                    onPressed: () {
                                      setState(() => _selectedStatus = 'All');
                                      quoteProvider.filterByStatus('All');
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: filteredQuotes.length,
                          itemBuilder: (context, index) {
                            final Quote quote = filteredQuotes[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              child: _buildQuoteCard(context, quote),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context, Quote quote) {
    final statusColor = _getStatusColor(quote.status);
    final formattedDate = '${quote.requestDate.day}/${quote.requestDate.month}/${quote.requestDate.year}';

    return CustomCard(
      onTap: () {
        _quoteProvider.fetchQuoteById(quote.id);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuoteDetailScreen(quoteId: quote.id)),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requested: $formattedDate',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  (quote.status ?? 'Unknown').isNotEmpty
                      ? (quote.status![0].toUpperCase() + quote.status!.substring(1))
                      : 'Unknown',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quote.description.isNotEmpty ? quote.description : 'No description',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Items', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    '${quote.items.length} items',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (quote.expiryDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Expires', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      '${quote.expiryDate!.day}/${quote.expiryDate!.month}/${quote.expiryDate!.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
          // Action buttons for pending quotes
          if ((quote.status ?? '').toLowerCase() == 'pending')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedCustomButton(
                      label: 'Accept',
                      onPressed: () => _acceptQuote(quote.id),
                    ),
                  ),
                  const SizedBox(width: 8),
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
    final s = (status ?? '').toLowerCase();
    switch (s) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'expired':
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
          const SnackBar(content: Text('Quote accepted successfully!')),
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
          const SnackBar(content: Text('Quote rejected successfully!')),
        );
      }
    }
  }
}
