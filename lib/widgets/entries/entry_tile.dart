import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/entry_model.dart';
import '../../utils/formatters.dart';

class EntryTile extends StatelessWidget {
  final EntryModel entry;
  final VoidCallback? onTap;

  const EntryTile({
    super.key,
    required this.entry,
    this.onTap,
  });

  // Get icon based on entry type
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

  // Get background color based on entry type
  Color _getBgColor() {
    switch (entry.type) {
      case EntryTypes.kapas:
        return AppColors.kapasColor;
      case EntryTypes.paani:
        return AppColors.paaniColor;
      case EntryTypes.mazdoori:
        return AppColors.mazdoorColor;
      case EntryTypes.expense:
        return AppColors.expenseColor;
      case EntryTypes.paymentReceive:
        return AppColors.toReceiveLight;
      case EntryTypes.paymentPay:
        return AppColors.toPayLight;
      default:
        return AppColors.divider;
    }
  }

  // Get icon color
  Color _getIconColor() {
    switch (entry.type) {
      case EntryTypes.kapas:
        return Colors.orange.shade800;
      case EntryTypes.paani:
        return Colors.blue.shade800;
      case EntryTypes.mazdoori:
        return Colors.amber.shade800;
      case EntryTypes.expense:
        return Colors.purple.shade800;
      case EntryTypes.paymentReceive:
        return AppColors.toReceive;
      case EntryTypes.paymentPay:
        return AppColors.toPay;
      default:
        return AppColors.textDark;
    }
  }

  // Get amount color (positive/negative context)
  Color _getAmountColor() {
    if (entry.type == EntryTypes.paymentReceive ||
        entry.type == EntryTypes.kapas ||
        entry.type == EntryTypes.paani) {
      return AppColors.toReceive;
    }
    return AppColors.toPay;
  }

  // Get title
  String _getTitle() {
    switch (entry.type) {
      case EntryTypes.kapas:
        return 'Kapas Entry';
      case EntryTypes.paani:
        return 'Paani Entry';
      case EntryTypes.mazdoori:
        return 'Mazdoori';
      case EntryTypes.expense:
        return 'Expense';
      case EntryTypes.paymentReceive:
        return 'Payment Received';
      case EntryTypes.paymentPay:
        return 'Payment Paid';
      default:
        return 'Entry';
    }
  }

  // Get subtitle
  String _getSubtitle() {
    final data = entry.typeData;
    switch (entry.type) {
      case EntryTypes.kapas:
        return '${data['weight'] ?? 0} Mann • Rs. ${data['rate'] ?? 0}';
      case EntryTypes.paani:
        return '${data['hours'] ?? 0} Hours • Rs. ${data['rate'] ?? 0}';
      case EntryTypes.mazdoori:
        return '${data['days'] ?? 0} Days • ${data['workType'] ?? ''}';
      case EntryTypes.expense:
        return '${data['category'] ?? ''} • ${data['crop'] ?? ''}';
      case EntryTypes.paymentReceive:
      case EntryTypes.paymentPay:
        return data['method'] ?? 'Cash';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getBgColor(),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(), color: _getIconColor(), size: 20),
            ),
            const SizedBox(width: AppSizes.paddingMedium),

            // Title + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getSubtitle(),
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                  if (entry.personName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.personName!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Amount + Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(entry.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getAmountColor(),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.date(entry.date),
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
