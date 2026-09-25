import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/person_model.dart';
import '../../utils/formatters.dart';
import 'person_avatar.dart';

class PersonTile extends StatelessWidget {
  final PersonModel person;
  final VoidCallback? onTap;

  const PersonTile({
    super.key,
    required this.person,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isReceive = person.isToReceive;
    final balance = person.netBalance.abs();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: 12,
        ),
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
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (person.phone != null && person.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      person.phone!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
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
                  AppFormatters.currency(balance),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isReceive ? AppColors.toReceive : AppColors.toPay,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isReceive ? 'To Receive' : 'To Pay',
                  style: TextStyle(
                    fontSize: 11,
                    color: isReceive ? AppColors.toReceive : AppColors.toPay,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }
}
