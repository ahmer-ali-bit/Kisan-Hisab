import 'package:flutter/material.dart';
import '../../config/constants.dart';
import 'monthly_report_screen.dart';
import 'crop_wise_report_screen.dart';
import 'person_wise_report_screen.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => _ReportsContent(
            onNavigate: _navigate,
          ),
        );
      },
    );
  }
}

class _ReportsContent extends StatelessWidget {
  final void Function(BuildContext, Widget) onNavigate;

  const _ReportsContent({
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Reports & Analytics'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(
            size.width * (isDesktop ? 0.02 : 0.04)),
        children: [
          _buildReportCard(
            context: context,
            title: 'Monthly Summary',
            subtitle: 'Income vs Expense (Bar Chart)',
            icon: Icons.bar_chart,
            color: Colors.blue,
            onTap: () => onNavigate(context, const MonthlyReportScreen()),
          ),
          SizedBox(height: size.height * 0.02),
          _buildReportCard(
            context: context,
            title: 'Crop-wise Analysis',
            subtitle: 'Production, Cost & Profit',
            icon: Icons.pie_chart,
            color: Colors.orange,
            onTap: () => onNavigate(context, const CropWiseReportScreen()),
          ),
          SizedBox(height: size.height * 0.02),
          _buildReportCard(
            context: context,
            title: 'Person-wise Report',
            subtitle: 'Individual ledger summary',
            icon: Icons.people_alt,
            color: Colors.purple,
            onTap: () => onNavigate(context, const PersonWiseReportScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.sizeOf(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding:
            EdgeInsets.all(size.width * 0.04),
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
              padding: EdgeInsets.all(size.width * 0.03),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: color, size: size.width * 0.07),
            ),
            SizedBox(width: size.width * 0.04),
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
                  SizedBox(height: size.height * 0.005),
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