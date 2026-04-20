import 'package:flutter/material.dart';
import '../widgets/admin_sidebar_layout.dart';
import '../../../../shared/widgets/index.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _maintenanceMode = false;

  @override
  Widget build(BuildContext context) {
    return AdminSidebarLayout(
      title: 'Settings',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CustomCard(
              child: Column(
                children: [
                  _SettingTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Enable order and quote notifications',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                  ),
                  Divider(),
                  _SettingTile(
                    icon: Icons.info,
                    title: 'Maintenance Mode',
                    subtitle: 'Temporarily disable the system',
                    trailing: Switch(
                      value: _maintenanceMode,
                      onChanged: (value) {
                        setState(() => _maintenanceMode = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            Text(
              'API Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CustomCard(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SettingItem(
                      label: 'API Endpoint',
                      value: 'api.autoparts.local',
                    ),
                    SizedBox(height: 16),
                    _SettingItem(
                      label: 'API Version',
                      value: 'v1.0.0',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            Text(
              'System Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CustomCard(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SettingItem(
                      label: 'App Version',
                      value: '1.0.0',
                    ),
                    SizedBox(height: 16),
                    _SettingItem(
                      label: 'Build Number',
                      value: '1',
                    ),
                    SizedBox(height: 16),
                    _SettingItem(
                      label: 'Last Updated',
                      value: DateTime.now().toString().split('.')[0],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            CustomButton(
              label: 'Save Settings',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings saved successfully')),
                );
              },
            ),
            SizedBox(height: 12),
            CustomButton(
              label: 'Reset to Defaults',
              onPressed: () {
                setState(() {
                  _notificationsEnabled = true;
                  _maintenanceMode = false;
                });
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String label;
  final String value;

  const _SettingItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
