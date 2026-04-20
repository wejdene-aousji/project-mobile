import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/index.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Profile',
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return Center(
              child: EmptyState(
                icon: Icons.person_off_outlined,
                title: 'No Profile Data',
                message: 'Please login again to load your profile.',
                action: CustomButton(
                  label: 'Go to Login',
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomCard(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        child: Icon(Icons.person, size: 34),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.role.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal Information', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      _ProfileField(label: 'Name', value: user.name),
                      const SizedBox(height: 10),
                      _ProfileField(label: 'Email', value: user.email),
                      const SizedBox(height: 10),
                      _ProfileField(label: 'Phone', value: user.phone),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Consumer<AuthProvider>(
                  builder: (context, provider, _) {
                    return CustomButton(
                      label: 'Logout',
                      isLoading: provider.isLoading,
                      backgroundColor: Colors.red,
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
