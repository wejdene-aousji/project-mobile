import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';

class AdminUsersManagementScreen extends StatefulWidget {
  const AdminUsersManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersManagementScreen> createState() => _AdminUsersManagementScreenState();
}

class _AdminUsersManagementScreenState extends State<AdminUsersManagementScreen> {
  String _filterRole = 'All';
  final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Manage Users',
      child: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading) {
            return Center(child: CustomLoadingIndicator(message: 'Loading users...'));
          }

          final filteredUsers = _filterRole == 'All'
              ? adminProvider.users
              : adminProvider.users.where((u) => u.role == _filterRole).toList();

          return Column(
            children: [
              // Filter buttons
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: ['All', 'ADMIN', 'CLIENT']
                      .map((role) => Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: _FilterButton(
                              label: role,
                              isActive: _filterRole == role,
                              onPressed: () => setState(() => _filterRole = role),
                            ),
                          ))
                      .toList(),
                ),
              ),
              // Users list
              Expanded(
                child: filteredUsers.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline,
                        title: 'No Users',
                        message: 'No users match the selected filter',
                        action: CustomButton(
                          label: 'Clear Filters',
                          onPressed: () => setState(() => _filterRole = 'All'),
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
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('Role')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: filteredUsers.map((user) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          user.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 220,
                                        child: Text(
                                          user.email,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(user.phone)),
                                    DataCell(Text(user.role)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: 'Edit user',
                                            icon: Icon(Icons.edit_outlined),
                                            onPressed: () => _showEditUserDialog(context, user),
                                          ),
                                          IconButton(
                                            tooltip: 'Delete user',
                                            icon: Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () => _deleteUser(context, user.id),
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
        onPressed: () => _showCreateUserDialog(context),
        child: Icon(Icons.person_add),
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'CLIENT';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Create User'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter full name',
                    controller: fullNameController,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Full name is required';
                      if (text.length < 2) return 'Full name is too short';
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
                    label: 'Phone',
                    hint: 'Enter phone',
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
                    label: 'Password',
                    hint: 'Enter password',
                    controller: passwordController,
                    obscureText: true,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Password is required';
                      if (text.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  // Role is not editable from the edit dialog by design.
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
                final adminProvider = context.read<AdminProvider>();
                final success = await adminProvider.createUser(
                  fullName: fullNameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  role: selectedRole,
                  password: passwordController.text.trim(),
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

  Future<void> _showEditUserDialog(BuildContext context, AdminUser user) async {
    final adminProvider = context.read<AdminProvider>();
    final fetched = await adminProvider.fetchUserById(user.id);
    final current = fetched ?? user;
    final formKey = GlobalKey<FormState>();

    final fullNameController = TextEditingController(text: current.name);
    final emailController = TextEditingController(text: current.email);
    final phoneController = TextEditingController(text: current.phone);
    final passwordController = TextEditingController(text: '');
    String selectedRole = current.role.toUpperCase() == 'ADMIN' ? 'ADMIN' : 'CLIENT';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter full name',
                    controller: fullNameController,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return 'Full name is required';
                      if (text.length < 2) return 'Full name is too short';
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
                    label: 'Phone',
                    hint: 'Enter phone',
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
                    label: 'Password',
                    hint: 'Leave empty to keep unchanged',
                    controller: passwordController,
                    obscureText: true,
                    validator: (value) {
                      final text = (value ?? '').trim();
                      if (text.isEmpty) return null;
                      if (text.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'CLIENT', child: Text('CLIENT')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => selectedRole = value);
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
                final success = await adminProvider.updateUser(
                  userId: user.id,
                  fullName: fullNameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  role: selectedRole,
                  password: passwordController.text.trim().isEmpty
                      ? current.password
                      : passwordController.text.trim(),
                  createdAt: current.createdAt,
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

  void _deleteUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User?'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final adminProvider = context.read<AdminProvider>();
              await adminProvider.deleteUser(userId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _FilterButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
        foregroundColor: isActive ? Colors.white : Theme.of(context).colorScheme.primary,
      ),
      child: Text(label),
    );
  }
}
