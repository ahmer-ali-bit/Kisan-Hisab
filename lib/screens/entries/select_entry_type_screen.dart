import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../utils/responsive.dart';
import 'dynamic_entry_screen.dart';

class SelectEntryTypeScreen extends StatelessWidget {
  const SelectEntryTypeScreen({super.key});

  void _navigate(BuildContext context, String type) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DynamicEntryScreen(entryType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entryTypes = [
      _EntryTypeItem(
        title: 'Kapas (Cotton)',
        icon: Icons.grass,
        color: AppColors.kapasColor,
        iconColor: Colors.orange.shade800,
        onTap: () => _navigate(context, EntryTypes.kapas),
      ),
      _EntryTypeItem(
        title: 'Paani / Tubewell',
        icon: Icons.water_drop,
        color: AppColors.paaniColor,
        iconColor: Colors.blue.shade800,
        onTap: () => _navigate(context, EntryTypes.paani),
      ),
      _EntryTypeItem(
        title: 'Mazdoori',
        icon: Icons.engineering,
        color: AppColors.mazdoorColor,
        iconColor: Colors.amber.shade800,
        onTap: () => _navigate(context, EntryTypes.mazdoori),
      ),
      _EntryTypeItem(
        title: 'Agriculture Expense',
        icon: Icons.local_florist,
        color: AppColors.expenseColor,
        iconColor: Colors.purple.shade800,
        onTap: () => _navigate(context, EntryTypes.expense),
      ),
      _EntryTypeItem(
        title: 'Payment (Receive)',
        icon: Icons.arrow_downward,
        color: AppColors.toReceiveLight,
        iconColor: AppColors.toReceive,
        onTap: () => _navigate(context, EntryTypes.paymentReceive),
      ),
      _EntryTypeItem(
        title: 'Payment (Pay)',
        icon: Icons.arrow_upward,
        color: AppColors.toPayLight,
        iconColor: AppColors.toPay,
        onTap: () => _navigate(context, EntryTypes.paymentPay),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Add Entry'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(AppSizes.paddingMedium),
          context.h(AppSizes.paddingMedium),
          context.w(AppSizes.paddingMedium),
          context.h(32),
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: context.h(AppSizes.paddingSmall)),
            child: Text(
              'Select Type of Entry',
              style: TextStyle(
                fontSize: context.sp(14),
                fontWeight: FontWeight.w500,
                color: AppColors.textLight,
              ),
            ),
          ),
          SizedBox(height: context.h(AppSizes.paddingSmall)),
          ...entryTypes.map((item) => Padding(
                padding: EdgeInsets.only(bottom: context.h(10)),
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  child: Container(
                    padding: EdgeInsets.all(context.w(AppSizes.paddingMedium)),
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(context.w(10)),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon,
                              color: item.iconColor, size: context.sp(24)),
                        ),
                        SizedBox(width: context.w(AppSizes.paddingMedium)),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: context.sp(15),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: context.sp(14), color: AppColors.textLight),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _EntryTypeItem {
  final String title;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  _EntryTypeItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });
}
