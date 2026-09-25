import 'package:flutter/material.dart';
import 'package:kisan_hisab/screens/history/edit_entry_screen.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/entry_model.dart';
import '../../providers/entry_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';

class TransactionDetailScreen extends StatelessWidget {
  final EntryModel entry;

  const TransactionDetailScreen({super.key, required this.entry});

  String _getTitle() {
    switch (entry.type) {
      case EntryTypes.kapas:
        return 'Kapas Entry';
      case EntryTypes.paani:
        return 'Paani Entry';
      case EntryTypes.mazdoori:
        return 'Mazdoori Entry';
      case EntryTypes.expense:
        return 'Agriculture Expense';
      case EntryTypes.paymentReceive:
        return 'Payment Received';
      case EntryTypes.paymentPay:
        return 'Payment Paid';
      default:
        return 'Transaction';
    }
  }

  IconData _getIcon() {
    switch (entry.type) {
      case EntryTypes.kapas:
        return Icons.grass;
      case EntryTypes.paani:
        return Icons.water_drop;
      case EntryTypes.mazdoori:
        return Icons.engineering;
      case EntryTypes.expense:
        return Icons.receipt_long;
      case EntryTypes.paymentReceive:
        return Icons.arrow_downward;
      case EntryTypes.paymentPay:
        return Icons.arrow_upward;
      default:
        return Icons.circle;
    }
  }

  List<MapEntry<String, String>> _getDetailFields() {
    final List<MapEntry<String, String>> fields = [];
    final data = entry.typeData;

    if (entry.personName != null) {
      fields.add(MapEntry('Person', entry.personName!));
    }
    fields.add(MapEntry('Date', AppFormatters.date(entry.date)));

    switch (entry.type) {
      case EntryTypes.kapas:
        fields.add(MapEntry('Weight', '${data['weight'] ?? 0} Mann'));
        fields.add(MapEntry('Rate', 'Rs. ${data['rate'] ?? 0} per Mann'));
        break;
      case EntryTypes.paani:
        fields.add(MapEntry('Hours', '${data['hours'] ?? 0}'));
        fields.add(MapEntry('Rate', 'Rs. ${data['rate'] ?? 0} per Hour'));
        break;
      case EntryTypes.mazdoori:
        fields.add(MapEntry('Work Type', '${data['workType'] ?? ''}'));
        fields.add(MapEntry('Days', '${data['days'] ?? 0}'));
        fields.add(MapEntry('Rate', 'Rs. ${data['rate'] ?? 0} per Day'));
        break;
      case EntryTypes.expense:
        fields.add(MapEntry('Category', '${data['category'] ?? ''}'));
        fields.add(MapEntry('Crop', '${data['crop'] ?? ''}'));
        if (data['quantity'] != null &&
            data['quantity'].toString().isNotEmpty) {
          fields.add(MapEntry('Quantity', '${data['quantity']}'));
        }
        break;
      case EntryTypes.paymentReceive:
      case EntryTypes.paymentPay:
        fields.add(MapEntry('Method', '${data['method'] ?? 'Cash'}'));
        break;
    }

    fields.add(MapEntry('Amount', AppFormatters.currency(entry.amount)));

    if (entry.note != null && entry.note!.isNotEmpty) {
      fields.add(MapEntry('Note', entry.note!));
    }

    fields.add(MapEntry('Created',
        '${AppFormatters.date(entry.createdAt)} at ${AppFormatters.time(entry.createdAt)}'));

    return fields;
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Entry?',
      message: 'This entry will be moved to Trash. You can restore it later.',
      confirmText: 'Delete',
    );
    if (!confirm) return;

    final success = await context.read<EntryProvider>().deleteEntry(entry);
    if (!context.mounted) return;

    if (success) {
      AppHelpers.showSnackBar(context, 'Entry moved to Trash');
      Navigator.pop(context);
    } else {
      AppHelpers.showSnackBar(context, 'Failed to delete', isError: true);
    }
  }

  void _edit(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EditEntryScreen(entry: entry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = _getDetailFields();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Transaction Detail'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIcon(), color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  Text(
                    _getTitle(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.currency(entry.amount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Details
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: fields.map((field) {
                  final isLast = field == fields.last;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                field.key,
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                field.value,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Actions
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: () => _edit(context),
                    isOutline: true,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: CustomButton(
                    text: 'Delete',
                    icon: Icons.delete_outline,
                    onPressed: () => _delete(context),
                    color: AppColors.toPay,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
