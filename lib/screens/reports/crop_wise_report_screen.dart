import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/constants.dart';
import '../../providers/entry_provider.dart';
import '../../utils/formatters.dart';

class CropWiseReportScreen extends StatelessWidget {
  const CropWiseReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final entries = context.watch<EntryProvider>().entries;

    double kapasProduction = 0;
    double kapasIncome = 0;
    double kapasExpense = 0;

    for (var e in entries) {
      if (e.type == EntryTypes.kapas) {
        kapasProduction += (e.typeData['weight'] ?? 0).toDouble();
        kapasIncome += e.amount;
      }
      if (e.type == EntryTypes.expense &&
          e.typeData['crop'] == 'Kapas (Cotton)') {
        kapasExpense += e.amount;
      }
    }

    final profit = kapasIncome - kapasExpense;
    final pieRadius = size.width * 0.15; // Dynamic Pie Chart Radius

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Kapas (Cotton) Analysis'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        context,
                        'Total Production',
                        '${kapasProduction.toStringAsFixed(1)} Mann',
                        Icons.grass,
                        Colors.orange)),
                SizedBox(width: size.width * 0.03),
                Expanded(
                    child: _buildStatCard(
                        context,
                        'Total Income',
                        AppFormatters.currency(kapasIncome),
                        Icons.account_balance_wallet,
                        AppColors.toReceive)),
              ],
            ),
            SizedBox(height: size.height * 0.015),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        context,
                        'Total Expense',
                        AppFormatters.currency(kapasExpense),
                        Icons.money_off,
                        AppColors.toPay)),
                SizedBox(width: size.width * 0.03),
                Expanded(
                    child: _buildStatCard(
                        context,
                        'Net Profit',
                        AppFormatters.currency(profit),
                        Icons.trending_up,
                        profit >= 0 ? AppColors.primary : AppColors.toPay)),
              ],
            ),
            SizedBox(height: size.height * 0.03),
            if (kapasIncome > 0 || kapasExpense > 0)
              Container(
                height: size.height * 0.4, // 40% of screen height
                padding: EdgeInsets.all(size.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text('Income vs Cost Ratio',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius:
                              size.width * 0.12, // Dynamic center hole
                          sections: [
                            PieChartSectionData(
                              color: AppColors.toReceive,
                              value: kapasIncome,
                              title: 'Income',
                              radius: pieRadius,
                              titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: AppColors.toPay,
                              value: kapasExpense,
                              title: 'Cost',
                              radius: pieRadius,
                              titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: size.width * 0.06),
          SizedBox(height: size.height * 0.01),
          Text(title,
              style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
          SizedBox(height: size.height * 0.005),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
