import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/models/product.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';

class AdminPurchasesManagementScreen extends StatefulWidget {
  const AdminPurchasesManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminPurchasesManagementScreen> createState() => _AdminPurchasesManagementScreenState();
}

class _AdminPurchasesManagementScreenState extends State<AdminPurchasesManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminProvider>();
      provider.fetchAllPurchases();
      provider.fetchAllSuppliers();
      provider.fetchAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Manage Purchases',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePurchaseDialog(context),
        child: Icon(Icons.add),
      ),
      child: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CustomLoadingIndicator(message: 'Loading purchases...'));
          }

          if (provider.purchases.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No Purchases',
              message: 'No purchases found',
              action: CustomButton(
                label: 'Create Purchase',
                onPressed: () => _showCreatePurchaseDialog(context),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: provider.purchases.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final purchase = provider.purchases[index];
              return CustomCard(
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text('Purchase #${purchase.id}'),
                  subtitle: Text(
                    '${purchase.supplier.name} • ${purchase.purchaseDate.toIso8601String().split('T').first}',
                  ),
                  trailing: Text(
                    '\$${purchase.totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        children: purchase.lines.map((line) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${line.product.name} (x${line.quantity})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text('\$${line.subtotal.toStringAsFixed(2)}'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showEditPurchaseDialog(context, purchase),
                            icon: Icon(Icons.edit_outlined),
                            label: Text('Edit'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _confirmDeletePurchase(context, purchase.id),
                            icon: Icon(Icons.delete_outline, color: Colors.red),
                            label: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreatePurchaseDialog(BuildContext context) {
    final provider = context.read<AdminProvider>();
    if (provider.suppliers.isEmpty || provider.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Load suppliers/products before creating a purchase.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    AdminSupplier selectedSupplier = provider.suppliers.first;

    final qtyController = TextEditingController();
    final unitCostController = TextEditingController();
    Product selectedProduct = provider.products.first;

    final List<AdminPurchaseLine> lines = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Create Purchase'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AdminSupplier>(
                    value: selectedSupplier,
                    decoration: InputDecoration(
                      labelText: 'Supplier',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.suppliers
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => selectedSupplier = value);
                    },
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Date: ${selectedDate.toIso8601String().split('T').first}'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            initialDate: selectedDate,
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Text('Change'),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  DropdownButtonFormField<Product>(
                    value: selectedProduct,
                    decoration: InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.products
                        .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => selectedProduct = value);
                    },
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    label: 'Quantity',
                    hint: 'Enter quantity',
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = int.tryParse((value ?? '').trim());
                      if (parsed == null) return 'Quantity must be numeric';
                      if (parsed <= 0) return 'Quantity must be greater than 0';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    label: 'Unit Cost',
                    hint: 'Enter unit cost',
                    controller: unitCostController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = double.tryParse((value ?? '').trim());
                      if (parsed == null) return 'Unit cost must be numeric';
                      if (parsed < 0) return 'Unit cost cannot be negative';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final qty = int.parse(qtyController.text.trim());
                        final unitCost = double.parse(unitCostController.text.trim());
                        lines.add(
                          AdminPurchaseLine(
                            id: DateTime.now().microsecondsSinceEpoch.toString(),
                            quantity: qty,
                            unitCost: unitCost,
                            subtotal: qty * unitCost,
                            product: selectedProduct,
                          ),
                        );
                        qtyController.clear();
                        unitCostController.clear();
                        setModalState(() {});
                      },
                      child: Text('Add Line'),
                    ),
                  ),
                  if (lines.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...lines.map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('${l.product.name} x${l.quantity}', overflow: TextOverflow.ellipsis)),
                              Text('\$${l.subtotal.toStringAsFixed(2)}'),
                            ],
                          ),
                        )),
                  ],
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
                if (lines.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Add at least one purchase line.')),
                  );
                  return;
                }

                final success = await provider.createPurchase(
                  purchaseDate: selectedDate,
                  supplier: selectedSupplier,
                  lines: lines,
                );
                if (!context.mounted) return;
                if (success) {
                  Navigator.pop(context);
                }
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPurchaseDialog(BuildContext context, AdminPurchase purchase) {
    final provider = context.read<AdminProvider>();
    if (provider.suppliers.isEmpty || provider.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Load suppliers/products before editing a purchase.')),
      );
      return;
    }

    DateTime selectedDate = purchase.purchaseDate;
    AdminSupplier selectedSupplier = provider.suppliers.firstWhere(
      (s) => s.id == purchase.supplier.id,
      orElse: () => provider.suppliers.first,
    );

    final lines = purchase.lines
        .map(
          (line) => AdminPurchaseLine(
            id: line.id,
            quantity: line.quantity,
            unitCost: line.unitCost,
            subtotal: line.subtotal,
            product: line.product,
          ),
        )
        .toList();

    final qtyController = TextEditingController();
    final unitCostController = TextEditingController();
    Product selectedProduct = provider.products.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Edit Purchase #${purchase.id}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AdminSupplier>(
                  value: selectedSupplier,
                  decoration: InputDecoration(
                    labelText: 'Supplier',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.suppliers
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setModalState(() => selectedSupplier = value);
                  },
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text('Date: ${selectedDate.toIso8601String().split('T').first}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: selectedDate,
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      child: Text('Change'),
                    ),
                  ],
                ),
                const Divider(height: 24),
                DropdownButtonFormField<Product>(
                  value: selectedProduct,
                  decoration: InputDecoration(
                    labelText: 'Product',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.products
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setModalState(() => selectedProduct = value);
                  },
                ),
                SizedBox(height: 12),
                CustomTextField(
                  label: 'Quantity',
                  hint: 'Enter quantity',
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                CustomTextField(
                  label: 'Unit Cost',
                  hint: 'Enter unit cost',
                  controller: unitCostController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: () {
                      final qty = int.tryParse(qtyController.text.trim());
                      final unitCost = double.tryParse(unitCostController.text.trim());
                      if (qty == null || qty <= 0 || unitCost == null || unitCost < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Enter valid quantity and unit cost.')),
                        );
                        return;
                      }
                      lines.add(
                        AdminPurchaseLine(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          quantity: qty,
                          unitCost: unitCost,
                          subtotal: qty * unitCost,
                          product: selectedProduct,
                        ),
                      );
                      qtyController.clear();
                      unitCostController.clear();
                      setModalState(() {});
                    },
                    child: Text('Add Line'),
                  ),
                ),
                if (lines.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...lines.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${entry.value.product.name} x${entry.value.quantity}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('\$${entry.value.subtotal.toStringAsFixed(2)}'),
                          IconButton(
                            onPressed: () {
                              lines.removeAt(entry.key);
                              setModalState(() {});
                            },
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                if (lines.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Add at least one purchase line.')),
                  );
                  return;
                }
                final success = await provider.updatePurchase(
                  purchaseId: purchase.id,
                  purchaseDate: selectedDate,
                  supplier: selectedSupplier,
                  lines: lines,
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
      ),
    );
  }

  void _confirmDeletePurchase(BuildContext context, String purchaseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Purchase?'),
        content: Text('Are you sure you want to delete this purchase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<AdminProvider>();
              final success = await provider.deletePurchase(purchaseId);
              if (!context.mounted) return;
              if (success) {
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? 'Failed to delete purchase.')),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
