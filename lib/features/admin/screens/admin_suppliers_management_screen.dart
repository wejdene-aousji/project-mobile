import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';

class AdminSuppliersManagementScreen extends StatefulWidget {
  const AdminSuppliersManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminSuppliersManagementScreen> createState() => _AdminSuppliersManagementScreenState();
}

class _AdminSuppliersManagementScreenState extends State<AdminSuppliersManagementScreen> {
  final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Manage Suppliers',
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading) {
            return Center(child: CustomLoadingIndicator(message: 'Loading suppliers...'));
          }

          final suppliers = adminProvider.suppliers;

          return Column(
            children: [
              Expanded(
                child: suppliers.isEmpty
                    ? EmptyState(
                        icon: Icons.local_shipping_outlined,
                        title: 'No Suppliers',
                        message: 'No suppliers found',
                        action: CustomButton(
                          label: 'Add Supplier',
                          onPressed: () => _showSupplierDialog(context),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(12),
                        child: CustomCard(
                          padding: EdgeInsets.zero,
                          child: DataTable(
                              columnSpacing: 24,
                              headingRowHeight: 56,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 56,
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Address')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: suppliers.map((supplier) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(supplier.name)),
                                    DataCell(Text(supplier.phone)),
                                    DataCell(Text(supplier.email)),
                                    DataCell(Text(supplier.address)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: 'Edit supplier',
                                            icon: Icon(Icons.edit_outlined),
                                            onPressed: () => _showSupplierDialog(context, supplier: supplier),
                                          ),
                                          IconButton(
                                            tooltip: 'Delete supplier',
                                            icon: Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () => _deleteSupplier(context, supplier.id),
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
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSupplierDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showSupplierDialog(BuildContext context, {AdminSupplier? supplier}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final phoneController = TextEditingController(text: supplier?.phone ?? '');
    final emailController = TextEditingController(text: supplier?.email ?? '');
    final addressController = TextEditingController(text: supplier?.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(supplier == null ? 'Add Supplier' : 'Edit Supplier'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Name',
                  hint: 'Enter supplier name',
                  controller: nameController,
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Name is required';
                    if (text.length < 2) return 'Name is too short';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                CustomTextField(
                  label: 'Phone',
                  hint: 'Enter phone number',
                  controller: phoneController,
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Phone is required';
                    if (text.length < 8) return 'Phone is too short';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter email',
                  controller: emailController,
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Email is required';
                    if (!_emailRegex.hasMatch(text)) return 'Enter a valid email';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                CustomTextField(
                  label: 'Address',
                  hint: 'Enter address',
                  controller: addressController,
                  maxLines: 2,
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Address is required';
                    if (text.length < 5) return 'Address is too short';
                    return null;
                  },
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
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final provider = context.read<AdminProvider>();
              final success = supplier == null
                  ? await provider.createSupplier(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                    )
                  : await provider.updateSupplier(
                      supplierId: supplier.id,
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      address: addressController.text.trim(),
                    );

              if (!context.mounted) return;
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

  void _deleteSupplier(BuildContext context, String supplierId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Supplier?'),
        content: Text('Are you sure you want to delete this supplier?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<AdminProvider>();
              await provider.deleteSupplier(supplierId);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
