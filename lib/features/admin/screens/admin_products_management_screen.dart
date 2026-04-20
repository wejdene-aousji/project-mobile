import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';

class AdminProductsManagementScreen extends StatefulWidget {
  const AdminProductsManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsManagementScreen> createState() => _AdminProductsManagementScreenState();
}

class _AdminProductsManagementScreenState extends State<AdminProductsManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminProvider>().fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Manage Products',
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading) {
            return Center(child: CustomLoadingIndicator(message: 'Loading products...'));
          }

          return Column(
            children: [
              Expanded(
                child: adminProvider.products.isEmpty
                    ? EmptyState(
                        icon: Icons.inventory_outlined,
                        title: 'No Products',
                        message: 'No products found',
                        action: CustomButton(
                          label: 'Add Product',
                          onPressed: () => _showProductDialog(context, null),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(12),
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - 24,
                          ),
                          child: CustomCard(
                            padding: EdgeInsets.zero,
                            child: DataTable(
                              columnSpacing: 24,
                              headingRowHeight: 56,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 56,
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Category')),
                                DataColumn(label: Text('Price')),
                                DataColumn(label: Text('Stock')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: adminProvider.products.map((product) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width: 220,
                                        child: Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(product.category)),
                                    DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                                    DataCell(Text('${product.stock}')),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: 'Edit',
                                            icon: Icon(Icons.edit_outlined),
                                            onPressed: () => _showProductDialog(context, product),
                                          ),
                                          IconButton(
                                            tooltip: 'Delete',
                                            icon: Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () => _deleteProduct(context, product.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(context, null),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showProductDialog(BuildContext context, dynamic product) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Product Name',
                hint: 'Enter product name',
                controller: nameController,
              ),
              SizedBox(height: 12),
              CustomTextField(
                label: 'Price',
                hint: 'Enter price',
                controller: priceController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              CustomTextField(
                label: 'Stock Quantity',
                hint: 'Enter stock quantity',
                controller: stockController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              CustomTextField(
                label: 'Category',
                hint: 'Enter category',
                controller: categoryController,
              ),
              SizedBox(height: 12),
              CustomTextField(
                label: 'Description',
                hint: 'Enter description',
                controller: descriptionController,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminProvider = context.read<AdminProvider>();
              final success = product == null
                  ? await adminProvider.createProduct(
                      name: nameController.text,
                      description: descriptionController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      stock: int.tryParse(stockController.text) ?? 0,
                      category: categoryController.text,
                    )
                  : await adminProvider.updateProduct(
                      productId: product.id,
                      name: nameController.text,
                      description: descriptionController.text,
                      price: double.tryParse(priceController.text) ?? 0,
                      stock: int.tryParse(stockController.text) ?? 0,
                      category: categoryController.text,
                    );

              if (success) {
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product?'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminProvider = context.read<AdminProvider>();
              await adminProvider.deleteProduct(productId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
