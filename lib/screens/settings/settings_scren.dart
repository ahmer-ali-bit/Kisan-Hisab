import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../utils/helpers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Logout?',
      message: 'Are you sure you want to lock the app?',
      confirmText: 'Lock App',
    );
    if (confirm && context.mounted) {
      // Navigate back to PIN Login Screen and clear stack
      Navigator.pushNamedAndRemoveUntil(
          context, '/pin-login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            // Account / Profile Section (Placeholder)
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                  SizedBox(width: AppSizes.paddingMedium),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kisan Sahib',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark)),
                      SizedBox(height: 4),
                      Text('Farmer Account',
                          style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Settings List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.currency_rupee,
                    title: 'Rate Management',
                    subtitle: 'Manage Kapas, Paani, Mazdoori rates',
                    onTap: () => _navigate(context, '/rate-management'),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.security,
                    title: 'Security & PIN',
                    subtitle: 'Fingerprint, Auto-lock, Change PIN',
                    onTap: () => _navigate(context, '/security'),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Backup & Restore',
                    subtitle: 'Save and recover your data',
                    onTap: () => _navigate(context, '/backup-restore'),
                  ),
                  const Divider(height: 1),
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: 'About App',
                    subtitle: 'Version and developer info',
                    onTap: () => _navigate(context, '/about'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.lock_outline, color: AppColors.toPay),
                label: const Text('Lock App / Logout',
                    style: TextStyle(
                        color: AppColors.toPay,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.toPayLight,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    side: BorderSide(
                        color: AppColors.toPay.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: AppColors.scaffoldBackground, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.textDark, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textDark)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}
