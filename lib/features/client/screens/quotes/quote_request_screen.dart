import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/index.dart';
import '../../providers/quote_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/client_bottom_nav_bar.dart';

class QuoteRequestScreen extends StatefulWidget {
  const QuoteRequestScreen({Key? key}) : super(key: key);

  @override
  State<QuoteRequestScreen> createState() => _QuoteRequestScreenState();
}

class _QuoteRequestScreenState extends State<QuoteRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late QuoteProvider _quoteProvider;
  late ProductProvider _productProvider;
  
  List<Map<String, dynamic>> _items = [];
  bool _isSubmitting = false;

  final _descriptionController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemQuantityController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    _quoteProvider = context.read<QuoteProvider>();
    _productProvider = context.read<ProductProvider>();
    // Fetch products if not already loaded
    if (_productProvider.products.isEmpty) {
      _productProvider.fetchProducts();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _itemNameController.dispose();
    _itemQuantityController.dispose();
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
          
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    _itemNameController.clear();
    _itemQuantityController.clear();
    // Show a dialog with a product picker populated from ProductProvider
    // Show dialog and await the added item; update parent state after dialog closes
    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String? selectedProductId;
        int qty = 1;

        return StatefulBuilder(
          builder: (context, setState) {
            final products = _productProvider.products;
            if (products.isEmpty) {
              return AlertDialog(
                title: const Text('Add Item to Quote'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No products available. Please try again.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _productProvider.fetchProducts(),
                      child: const Text('Reload Products'),
                    ),
                  ],
                ),
                actions: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: const Text('Add Item to Quote'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedProductId,
                      items: products.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text('${p.name} (${p.code ?? ''})'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => selectedProductId = v),
                      decoration: const InputDecoration(labelText: 'Select product'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Quantity',
                      controller: _itemQuantityController,
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                CustomButton(
                  label: 'Add',
                  onPressed: () {
                    if (selectedProductId == null || selectedProductId!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a product')),
                      );
                      return;
                    }

                    final selected = products.firstWhere((p) => p.id == selectedProductId);
                    final item = {
                      'productId': selected.id,
                      'name': selected.name,
                      'quantity': int.tryParse(_itemQuantityController.text) ?? 1,
                    };

                    Navigator.pop(context, item);
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((added) {
      if (added != null) {
        setState(() => _items.add(added));
      }
    });
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one item to your quote')),
      );
      return;
    }
    // Ensure every item has a productId (selected from inventory)
    final missingId = _items.indexWhere((it) => it['productId'] == null || (it['productId'] as String).isEmpty);
    if (missingId != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a product for item ${missingId + 1}')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

      final success = await _quoteProvider.submitQuoteRequest(
        description: _descriptionController.text,
        items: _items,
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
