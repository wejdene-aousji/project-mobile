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
  late TextEditingController _priceController;
  DateTime? _selectedExpiry;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    context.read<AdminProvider>().fetchAllQuotes();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Quote Details',
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          final quote = adminProvider.quotes.firstWhere(
            (q) => q.id == widget.quoteId,
            orElse: () => throw Exception('Quote not found'),
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

                // Delivery Address
                Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(quote.deliveryAddress),
                  ),
                ),
                SizedBox(height: 16),

                // Add Price Section (if pending)
                if (quote.status == 'pending') ...[
                  Text('Add Quotation Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  CustomTextField(
                    label: 'Quoted Price',
                    hint: 'Enter the quoted price',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12),
                  CustomButton(
                    label: 'Select Expiry Date',
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (selected != null) {
                        setState(() => _selectedExpiry = selected);
                      }
                    },
                  ),
                  if (_selectedExpiry != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'Selected: ${_selectedExpiry.toString().split(' ')[0]}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                  SizedBox(height: 16),
                  CustomButton(
                    label: 'Send Quotation',
                    onPressed: () async {
                      final price = double.tryParse(_priceController.text);
                      if (price == null || price <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a valid price')),
                        );
                        return;
                      }

                      final success = await adminProvider.addQuotePrice(
                        widget.quoteId,
                        price,
                        _selectedExpiry,
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Quotation sent successfully')),
                        );
                        _priceController.clear();
                        setState(() => _selectedExpiry = null);
                      }
                    },
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
