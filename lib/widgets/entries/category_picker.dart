import 'package:flutter/material.dart';
import '../../config/constants.dart';

class CategoryPicker extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final List<String> options;
  final Function(String) onSelected;
  final bool isRequired;
  final String hint;

  const CategoryPicker({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
    this.isRequired = false,
    this.hint = 'Select',
  });

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select $label',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              ...options.map((option) {
                final isSelected = selectedValue == option;
                return ListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    onSelected(option);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.toPay),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedValue ?? hint,
                    style: TextStyle(
                      fontSize: 15,
                      color: selectedValue != null
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
