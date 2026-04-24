import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';

class AdminProductsManagementScreen extends StatefulWidget {
  const AdminProductsManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsManagementScreen> createState() => _AdminProductsManagementScreenState();
}

class _AdminProductsManagementScreenState extends State<AdminProductsManagementScreen> {
  final RegExp _urlRegex = RegExp(r'^(https?:\/\/).+');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllProducts();
    });
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
                        child: Column(
                          children: adminProvider.products.map((product) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CustomCard(
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            product.imageUrl!,
                                            width: 64,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stack) => Container(
                                              color: Colors.grey[200],
                                              width: 64,
                                              height: 56,
                                              child: Icon(Icons.broken_image, size: 28, color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            width: 64,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(Icons.image, color: Colors.grey[400]),
                                          ),
                                  ),
                                  title: Text(product.name),
                                  subtitle: Text(product.code ?? '-'),
                                  trailing: SizedBox(
                                    width: 140,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('\$${(product.priceTTC ?? product.price).toStringAsFixed(2)}'),
                                        SizedBox(width: 12),
                                        Text('${product.stock}'),
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
                                ),
                              ),
                            );
                          }).toList(),
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
    final formKey = GlobalKey<FormState>();
    final cloudinaryService = CloudinaryService();
    final productIdController = TextEditingController(text: product?.id ?? '');
    final codeController = TextEditingController(text: product?.code ?? '');
    final nameController = TextEditingController(text: product?.name ?? '');
    final stockQuantityController = TextEditingController(text: product?.stock.toString() ?? '');
    final purchasePriceController = TextEditingController(
      text: (product?.purchasePrice ?? product?.price ?? '').toString(),
    );
    final priceHTController = TextEditingController();
    final priceTTCController = TextEditingController();
    final urlController = TextEditingController(text: product?.imageUrl ?? '');
    bool isUploading = false;
    String? uploadError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (product != null)
                    CustomTextField(
                      label: 'Product ID',
                      hint: 'Numeric id',
                      controller: productIdController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (product == null) return null;
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return 'Product ID is required in update mode';
                        if (int.tryParse(text) == null) return 'Product ID must be numeric';
                        return null;
                      },
                    ),
                  SizedBox(height: 12),
                  CustomTextField(
                    label: 'Code',
                    hint: 'Enter product code',
                    controller: codeController,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Code is required';
                      if (text.length < 2) return 'Code is too short';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    label: 'Product Name',
                    hint: 'Enter product name',
                    controller: nameController,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Product name is required';
                      if (text.length < 2) return 'Product name is too short';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    label: 'Stock Quantity',
                    hint: 'Enter stock quantity',
                    controller: stockQuantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = int.tryParse((value ?? '').trim());
                      if (parsed == null) return 'Quantity must be a number';
                      if (parsed < 0) return 'Quantity cannot be negative';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    label: 'Purchase Price',
                    hint: 'Enter purchase price',
                    controller: purchasePriceController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = double.tryParse((value ?? '').trim());
                      if (parsed == null) return 'Purchase price must be numeric';
                      if (parsed < 0) return 'Purchase price cannot be negative';
                      return null;
                    },
                  ),
                  // Price HT and Price TTC are calculated in backend; inputs removed.
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Image URL',
                          hint: 'Enter image URL or upload',
                          controller: urlController,
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) return null;
                            if (!_urlRegex.hasMatch(text)) return 'Enter a valid URL starting with http:// or https://';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: isUploading
                        ? null
                        : () async {
                            setModalState(() {
                              isUploading = true;
                              uploadError = null;
                            });
                            try {
                              final picked = await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                withData: true,
                              );

                              if (picked == null || picked.files.isEmpty) {
                                return;
                              }

                              final imageUrl = await cloudinaryService.uploadImage(
                                picked.files.single,
                              );
                              urlController.text = imageUrl;
                            } catch (e) {
                              uploadError = e.toString();
                            } finally {
                              setModalState(() {
                                isUploading = false;
                              });
                            }
                          },
                    icon: isUploading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.cloud_upload_outlined),
                    label: Text(isUploading ? 'Uploading...' : 'Upload to Cloudinary'),
                  ),
                ),
                if (uploadError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      uploadError!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                    if (!formKey.currentState!.validate()) return;
                      final adminProvider = context.read<AdminProvider>();
                      final success = product == null
                          ? await adminProvider.createProduct(
                              code: codeController.text,
                              name: nameController.text,
                              stockQuantity: int.tryParse(stockQuantityController.text) ?? 0,
                              purchasePrice: double.tryParse(purchasePriceController.text) ?? 0,
                              url: urlController.text,
                            )
                          : await adminProvider.updateProduct(
                              productId: product.id,
                              code: codeController.text,
                              name: nameController.text,
                              stockQuantity: int.tryParse(stockQuantityController.text) ?? 0,
                              purchasePrice: double.tryParse(purchasePriceController.text) ?? 0,
                              // priceHT/priceTTC omitted (calculated by backend)
                              url: urlController.text,
                            );

                      if (success) {
                        Navigator.pop(context);
                      }
                    },
              child: Text('Save'),
            ),
          ],
        ),
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
