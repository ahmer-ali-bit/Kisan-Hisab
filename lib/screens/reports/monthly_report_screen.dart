import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/constants.dart';
import '../../models/entry_model.dart';
import '../../providers/entry_provider.dart';
import '../../utils/formatters.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  Map<int, Map<String, double>> _calculateMonthlyData(
      List<EntryModel> entries) {
    // Key: Month (1-12), Value: {'income': x, 'expense': y}
    final Map<int, Map<String, double>> data = {};

    // Initialize current year's months
    for (int i = 1; i <= 12; i++) {
      data[i] = {'income': 0, 'expense': 0};
    }

    final currentYear = DateTime.now().year;

    for (var entry in entries) {
      if (entry.date.year != currentYear) continue; // Only this year

      final month = entry.date.month;

      // Income: Kapas, Paani
      if (entry.type == EntryTypes.kapas || entry.type == EntryTypes.paani) {
        data[month]!['income'] = data[month]!['income']! + entry.amount;
      }
      // Expense: Mazdoori, Expense
      else if (entry.type == EntryTypes.mazdoori ||
          entry.type == EntryTypes.expense) {
        data[month]!['expense'] = data[month]!['expense']! + entry.amount;
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<EntryProvider>().entries;
    final monthlyData = _calculateMonthlyData(entries);

    double totalIncome = 0;
    double totalExpense = 0;
    monthlyData.forEach((_, value) {
      totalIncome += value['income']!;
      totalExpense += value['expense']!;
    });

    final netProfit = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Monthly Report (${DateTime.now().year})'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            // SUMMARY CARDS
            Row(
              children: [
                Expanded(
                    child: _buildSummaryCard(
                        'Total Income', totalIncome, AppColors.toReceive)),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                    child: _buildSummaryCard(
                        'Total Expense', totalExpense, AppColors.toPay)),
              ],
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            _buildSummaryCard('Net Profit / Loss', netProfit.abs(),
                netProfit >= 0 ? AppColors.primary : AppColors.toPay,
                prefix: netProfit >= 0 ? '+' : '-', isFullWidth: true),
            const SizedBox(height: AppSizes.paddingLarge),

            // CHART
            Container(
              height: 350,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Income vs Expense',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(monthlyData),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'J',
                                  'F',
                                  'M',
                                  'A',
                                  'M',
                                  'J',
                                  'J',
                                  'A',
                                  'S',
                                  'O',
                                  'N',
                                  'D'
                                ];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(months[value.toInt() - 1],
                                      style: const TextStyle(fontSize: 10)),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: _buildBarGroups(monthlyData),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Income', AppColors.toReceive),
                      const SizedBox(width: 16),
                      _buildLegendItem('Expense', AppColors.toPay),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(Map<int, Map<String, double>> data) {
    double max = 0;
    data.forEach((_, value) {
      if (value['income']! > max) max = value['income']!;
      if (value['expense']! > max) max = value['expense']!;
    });
    return max == 0 ? 10000 : max * 1.2; // 20% padding top
  }

  List<BarChartGroupData> _buildBarGroups(Map<int, Map<String, double>> data) {
    List<BarChartGroupData> groups = [];
    data.forEach((month, values) {
      groups.add(
        BarChartGroupData(
          x: month,
          barRods: [
            BarChartRodData(
                toY: values['income']!,
                color: AppColors.toReceive,
                width: 8,
                borderRadius: BorderRadius.circular(2)),
            BarChartRodData(
                toY: values['expense']!,
                color: AppColors.toPay,
                width: 8,
                borderRadius: BorderRadius.circular(2)),
          ],
        ),
      );
    });
    return groups;
  }

  Widget _buildSummaryCard(String title, double amount, Color color,
      {bool isFullWidth = false, String prefix = ''}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            '$prefix${AppFormatters.currency(amount)}',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
      ],
    );
  }
}
