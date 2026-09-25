import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/person_model.dart';
import '../../utils/formatters.dart';
import 'person_avatar.dart';

class PendingPersonTile extends StatelessWidget {
  final PersonModel person;
  final bool isToReceive; // true = To Receive tab, false = To Pay tab
  final VoidCallback? onTap;
  final VoidCallback? onAction; // Quick Receive or Pay

  const PendingPersonTile({
    super.key,
    required this.person,
    required this.isToReceive,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final amount = isToReceive ? person.totalToReceive : person.totalToPay;
    final amountColor = isToReceive ? AppColors.toReceive : AppColors.toPay;
    final actionLabel = isToReceive ? 'Receive' : 'Pay';
    final actionColor = isToReceive ? AppColors.toReceive : AppColors.toPay;

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
            PersonAvatar(
              name: person.name,
              photoBase64: person.photoBase64,
              radius: 22,
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      fontSize: 15,
                    ),
                  ),
                  if (person.phone != null && person.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      person.phone!,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: actionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      border: Border.all(
                        color: actionColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      actionLabel,
                      style: TextStyle(
                        color: actionColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
