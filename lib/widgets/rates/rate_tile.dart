import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/rate_model.dart';
import '../../utils/formatters.dart';

class RateTile extends StatelessWidget {
  final RateModel rate;
  final VoidCallback onDelete;

  const RateTile({
    super.key,
    required this.rate,
    required this.onDelete,
  });

  String _getUnit() {
    switch (rate.type) {
      case 'kapas':
        return 'per Mann';
      case 'paani':
        return 'per Hour';
      case 'mazdoori':
        return 'per Day';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppFormatters.date(rate.effectiveFrom),
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.currency(rate.ratePerUnit),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getUnit(),
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.toPay),
            onPressed: onDelete,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
