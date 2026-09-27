import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../utils/responsive.dart';
import 'monthly_report_screen.dart';
import 'crop_wise_report_screen.dart';
import 'person_wise_report_screen.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

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
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(AppSizes.paddingMedium),
          context.h(AppSizes.paddingMedium),
          context.w(AppSizes.paddingMedium),
          context.h(32),
        ),
        children: [
          _buildReportCard(
            context,
            title: 'Monthly Summary',
            subtitle: 'Income vs Expense (Bar Chart)',
            icon: Icons.bar_chart,
            color: Colors.blue,
            onTap: () => _navigate(context, const MonthlyReportScreen()),
          ),
          SizedBox(height: context.h(AppSizes.paddingMedium)),
          _buildReportCard(
            context,
            title: 'Crop-wise Analysis',
            subtitle: 'Production, Cost & Profit',
            icon: Icons.pie_chart,
            color: Colors.orange,
            onTap: () => _navigate(context, const CropWiseReportScreen()),
          ),
          SizedBox(height: context.h(AppSizes.paddingMedium)),
          _buildReportCard(
            context,
            title: 'Person-wise Report',
            subtitle: 'Individual ledger summary',
            icon: Icons.people_alt,
            color: Colors.purple,
            onTap: () => _navigate(context, const PersonWiseReportScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
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
        padding: EdgeInsets.all(context.w(AppSizes.paddingLarge)),
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
              padding: EdgeInsets.all(context.w(12)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: context.sp(28)),
            ),
            SizedBox(width: context.w(AppSizes.paddingMedium)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.sp(13),
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: context.sp(16), color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
