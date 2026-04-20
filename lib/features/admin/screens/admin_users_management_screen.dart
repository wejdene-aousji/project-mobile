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

  @override
  void initState() {
    super.initState();
    context.read<AdminProvider>().fetchAllUsers();
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
                  children: ['All', 'admin', 'user']
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
                                      IconButton(
                                        tooltip: 'Delete user',
                                        icon: Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () => _deleteUser(context, user.id),
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
