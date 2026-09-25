import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import 'monthly_report_screen.dart';
import 'crop_wise_report_screen.dart';
import 'person_wise_report_screen.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  void _onNavTapped(BuildContext context, int index) {
    if (index == 4) return; // Already on Reports
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }
    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/people');
      return;
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/select-entry-type');
      return;
    }
    if (index == 3) {
      Navigator.pushReplacementNamed(context, '/history');
      return;
    }
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Reports & Analytics'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          _buildReportCard(
            title: 'Monthly Summary',
            subtitle: 'Income vs Expense (Bar Chart)',
            icon: Icons.bar_chart,
            color: Colors.blue,
            onTap: () => _navigate(context, const MonthlyReportScreen()),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildReportCard(
            title: 'Crop-wise Analysis',
            subtitle: 'Production, Cost & Profit',
            icon: Icons.pie_chart,
            color: Colors.orange,
            onTap: () => _navigate(context, const CropWiseReportScreen()),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildReportCard(
            title: 'Person-wise Report',
            subtitle: 'Individual ledger summary',
            icon: Icons.people_alt,
            color: Colors.purple,
            onTap: () => _navigate(context, const PersonWiseReportScreen()),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 4,
        onTap: (index) => _onNavTapped(context, index),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
