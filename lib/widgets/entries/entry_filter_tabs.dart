import 'package:flutter/material.dart';
import '../../config/constants.dart';

class EntryFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const EntryFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const List<Map<String, String>> filters = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Kapas', 'value': EntryTypes.kapas},
    {'label': 'Paani', 'value': EntryTypes.paani},
    {'label': 'Mazdoori', 'value': EntryTypes.mazdoori},
    {'label': 'Expense', 'value': EntryTypes.expense},
    {'label': 'Payment', 'value': 'payment'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['value'];
          return GestureDetector(
            onTap: () => onFilterChanged(filter['value']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  filter['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
