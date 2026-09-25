import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/constants.dart';
import '../../models/entry_model.dart';
import '../../providers/entry_provider.dart';
import '../../utils/formatters.dart';

class CropWiseReportScreen extends StatelessWidget {
  const CropWiseReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<EntryProvider>().entries;

    // Filter Kapas data specifically
    double kapasProduction = 0;
    double kapasIncome = 0;
    double kapasExpense = 0;

    for (var e in entries) {
      if (e.type == EntryTypes.kapas) {
        kapasProduction += (e.typeData['weight'] ?? 0).toDouble();
        kapasIncome += e.amount;
      }
      // Expense linked to Kapas (Cotton)
      if (e.type == EntryTypes.expense &&
          e.typeData['crop'] == 'Kapas (Cotton)') {
        kapasExpense += e.amount;
      }
    }

    final profit = kapasIncome - kapasExpense;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Kapas (Cotton) Analysis'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        'Total Production',
                        '${kapasProduction.toStringAsFixed(1)} Mann',
                        Icons.grass,
                        Colors.orange)),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                    child: _buildStatCard(
                        'Total Income',
                        AppFormatters.currency(kapasIncome),
                        Icons.account_balance_wallet,
                        AppColors.toReceive)),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        'Total Expense',
                        AppFormatters.currency(kapasExpense),
                        Icons.money_off,
                        AppColors.toPay)),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                    child: _buildStatCard(
                        'Net Profit',
                        AppFormatters.currency(profit),
                        Icons.trending_up,
                        profit >= 0 ? AppColors.primary : AppColors.toPay)),
              ],
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // PIE CHART
            if (kapasIncome > 0 || kapasExpense > 0)
              Container(
                height: 300,
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
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
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: AppColors.toReceive,
                              value: kapasIncome,
                              title: 'Income',
                              radius: 50,
                              titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: AppColors.toPay,
                              value: kapasExpense,
                              title: 'Cost',
                              radius: 50,
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
