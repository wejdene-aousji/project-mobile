import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/index.dart';
import '../../providers/quote_provider.dart';
import '../../widgets/client_bottom_nav_bar.dart';

class QuoteRequestScreen extends StatefulWidget {
  const QuoteRequestScreen({Key? key}) : super(key: key);

  @override
  State<QuoteRequestScreen> createState() => _QuoteRequestScreenState();
}

class _QuoteRequestScreenState extends State<QuoteRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late QuoteProvider _quoteProvider;
  
  List<Map<String, dynamic>> _items = [];
  bool _isSubmitting = false;

  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  final _itemSpecsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quoteProvider = context.read<QuoteProvider>();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _itemNameController.dispose();
    _itemQuantityController.dispose();
    _itemSpecsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Request a Quote',
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
      body: Consumer<QuoteProvider>(
        builder: (context, quoteProvider, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description section
                  Text('Quote Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 8),
                  CustomTextField(
                    label: 'Description',
                    hint: 'Describe what you need for this quote...',
                    controller: _descriptionController,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe what you need';
                      }
                      if (value.length < 10) {
                        return 'Description must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Items section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      CustomButton(
                        label: '+ Add Item',
                        onPressed: _showAddItemDialog,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  if (_items.isEmpty)
                    Center(
                      child: EmptyState(
                        icon: Icons.shopping_cart_outlined,
                        title: 'No Items Added',
                        message: 'Add items to your quote request',
                      ),
                    )
                  else
                    Column(
                      children: _items.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> item = entry.value;
                        return _buildItemCard(item, index);
                      }).toList(),
                    ),

                  SizedBox(height: 20),

                  // Delivery address
                  Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 8),
                  CustomTextField(
                    label: 'Address',
                    hint: 'Enter your delivery address...',
                    controller: _addressController,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your delivery address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: _isSubmitting ? 'Submitting...' : 'Submit Quote Request',
                      onPressed: _isSubmitting ? null : _submitQuote,
                    ),
                  ),

                  if (quoteProvider.error != null)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quoteProvider.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'Item ${index + 1}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Qty: ${item['quantity'] ?? 0}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _items.removeAt(index);
                  });
                },
                icon: Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          if (item['specs'] != null && (item['specs'] as String).isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Specs: ${item['specs']}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    _itemNameController.clear();
    _itemQuantityController.clear();
    _itemSpecsController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Item to Quote'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Item name',
                controller: _itemNameController,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              CustomTextField(
                label: 'Quantity',
                controller: _itemQuantityController,
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12),
              CustomTextField(
                label: 'Specifications',
                hint: '(optional)',
                controller: _itemSpecsController,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          CustomButton(
            label: 'Add',
            onPressed: () {
              if (_itemNameController.text.isEmpty || _itemQuantityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill in all required fields')),
                );
                return;
              }

              setState(() {
                _items.add({
                  'name': _itemNameController.text,
                  'quantity': int.tryParse(_itemQuantityController.text) ?? 1,
                  'specs': _itemSpecsController.text,
                });
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one item to your quote')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await _quoteProvider.submitQuoteRequest(
      description: _descriptionController.text,
      items: _items,
      deliveryAddress: _addressController.text,
    );

    setState(() => _isSubmitting = false);

    if (success) {
      showDialog(
        context: context,
        builder: (context) => SuccessDialog(
          title: 'Quote Submitted!',
          message: 'Your quote request has been sent to our admin team.',
          onDismiss: () {
            Navigator.pop(context);
            Navigator.of(context).pushReplacementNamed('/client/quotes');
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_quoteProvider.error ?? 'Failed to submit quote')),
      );
    }
  }
}
