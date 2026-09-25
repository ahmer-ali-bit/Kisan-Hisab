import 'package:flutter/material.dart';
import '../../config/constants.dart';

class RateTypeTabs extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const RateTypeTabs({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  Widget _buildTab(String title, String type, BuildContext context) {
    final isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textLight,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildTab('Kapas', 'kapas', context),
          _buildTab('Paani', 'paani', context),
          _buildTab('Mazdoori', 'mazdoori', context),
        ],
      ),
    );
  }
}
