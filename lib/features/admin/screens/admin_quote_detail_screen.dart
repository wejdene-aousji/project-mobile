import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';

class AdminQuoteDetailScreen extends StatefulWidget {
  final String quoteId;

  const AdminQuoteDetailScreen({Key? key, required this.quoteId}) : super(key: key);

  @override
  State<AdminQuoteDetailScreen> createState() => _AdminQuoteDetailScreenState();
}

class _AdminQuoteDetailScreenState extends State<AdminQuoteDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminProvider>().fetchAllQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Quote Details',
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.quotes.isEmpty) {
            return Center(
              child: CustomLoadingIndicator(message: 'Loading quote details...'),
            );
          }

          final quote = adminProvider.quotes.firstWhere(
            (q) => q.id == widget.quoteId,
            orElse: () => adminProvider.quotes.first,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote Header
                CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quote #${quote.id.substring(0, quote.id.length > 8 ? 8 : quote.id.length).toUpperCase()}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Chip(label: Text(quote.status)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Requested: ${quote.requestDate}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Client Information
                Text('Client Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${quote.clientName}'),
                        SizedBox(height: 8),
                        Text('Email: ${quote.clientEmail}'),
                        SizedBox(height: 8),
                        Text('Phone: ${quote.clientPhone}'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Quote Description
                Text('Quote Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(quote.description),
                  ),
                ),
                SizedBox(height: 16),

                // Quote Items
                Text('Items Requested', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                ...quote.items.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: CustomCard(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.productName,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Qty: ${item.quantity}'),
                                ],
                              ),
                              if (item.specifications.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  'Specs: ${item.specifications}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )),
                SizedBox(height: 16),

                SizedBox(height: 12),

                // Approve/Reject section (if pending)
                if (quote.status.toLowerCase() == 'pending') ...[
                  Text('Quote Decision', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Approve Quote',
                          onPressed: () async {
                            final success = await adminProvider.approveQuote(widget.quoteId);
                            if (!context.mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Quote approved successfully')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(adminProvider.error ?? 'Failed to approve quote')),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: 'Reject Quote',
                          backgroundColor: Colors.red,
                          onPressed: () async {
                            final success = await adminProvider.rejectQuote(widget.quoteId);
                            if (!context.mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Quote rejected successfully')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(adminProvider.error ?? 'Failed to reject quote')),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
