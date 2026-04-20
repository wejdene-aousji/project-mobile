import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/index.dart';
import '../../providers/quote_provider.dart';

class QuoteDetailScreen extends StatefulWidget {
  final String quoteId;

  const QuoteDetailScreen({
    Key? key,
    required this.quoteId,
  }) : super(key: key);

  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> {
  late QuoteProvider _quoteProvider;

  @override
  void initState() {
    super.initState();
    _quoteProvider = context.read<QuoteProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quote Details',
        onBack: () => Navigator.pop(context),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.clientProfile),
          ),
        ],
      ),
      body: Consumer<QuoteProvider>(
        builder: (context, quoteProvider, _) {
          final quote = quoteProvider.selectedQuote ?? quoteProvider.getQuoteById(widget.quoteId);

          if (quoteProvider.isLoading) {
            return Center(child: CustomLoadingIndicator(message: 'Loading quote details...'));
          }

          if (quote == null) {
            return Center(
              child: EmptyState(
                icon: Icons.description_outlined,
                title: 'Quote Not Found',
                message: 'This quote could not be found.',
                action: CustomButton(
                  label: 'Go Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote header
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quote #${quote.id.substring(0, quote.id.length > 8 ? 8 : quote.id.length).toUpperCase()}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 4),
                              Text(
                                'Requested: ${quote.requestDate.day}/${quote.requestDate.month}/${quote.requestDate.year}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(quote.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              quote.status,
                              style: TextStyle(
                                color: _getStatusColor(quote.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Description
                Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 8),
                CustomCard(
                  child: Text(
                    quote.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
                SizedBox(height: 16),

                // Quoted Price (if available)
                if (quote.quotedPrice != 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quoted Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 8),
                      CustomCard(
                        child: Text(
                          '\$${quote.quotedPrice.toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),

                // Expiry Date
                if (quote.expiryDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 8),
                      CustomCard(
                        child: Text(
                          '${quote.expiryDate!.day}/${quote.expiryDate!.month}/${quote.expiryDate!.year}',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),

                // Quote Items
                Text('Items (${quote.items.length})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 8),
                Column(
                  children: quote.items.map((item) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.productName,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                'Qty: ${item.quantity}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          if (item.specifications.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Specs: ${item.specifications}',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),

                // Delivery Address
                Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 8),
                CustomCard(
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          quote.deliveryAddress,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Action buttons
                if (quote.status == 'Pending')
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: 'Accept Quote',
                          onPressed: () => _acceptQuote(quote.id),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedCustomButton(
                          label: 'Reject Quote',
                          onPressed: () => _rejectQuote(quote.id),
                        ),
                      ),
                    ],
                  )
                else if (quote.status == 'Accepted')
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'This quote has been accepted and sent to your inbox!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600),
                    ),
                  )
                else if (quote.status == 'Rejected')
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'This quote was rejected.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          );
        },
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
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => SuccessDialog(
              title: 'Quote Accepted!',
              message: 'Your quote has been accepted and an order has been created.',
              onDismiss: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          );
        }
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
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => SuccessDialog(
              title: 'Quote Rejected',
              message: 'This quote has been rejected.',
              onDismiss: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          );
        }
      }
    }
  }
}
