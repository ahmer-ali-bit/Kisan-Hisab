import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/entry_model.dart';
import '../../models/person_model.dart';
import '../../providers/entry_provider.dart';
import '../../providers/people_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../entries/dynamic_entry_screen.dart';
import '../entries/select_entry_type_screen.dart';
import 'add_person_screen.dart';

class PersonAccountScreen extends StatelessWidget {
  final String personId;

  const PersonAccountScreen({super.key, required this.personId});

  // Calculate breakdown from entries
  Map<String, double> _calculateBreakdown(List<EntryModel> entries) {
    double kapas = 0, paani = 0, mazdoori = 0, expenses = 0, payments = 0;

    for (var e in entries) {
      if (e.type == EntryTypes.kapas) kapas += e.amount;
      if (e.type == EntryTypes.paani) paani += e.amount;
      if (e.type == EntryTypes.mazdoori) mazdoori += e.amount;
      if (e.type == EntryTypes.expense) expenses += e.amount;
      // Payments received reduces balance, payments paid reduces balance (we just show absolute total flow or ignore in category)
      // We can group receive & pay to show total cash flow, but let's stick to categories.
    }

    return {
      'Kapas (Cotton)': kapas,
      'Paani (Tubewell)': paani,
      'Mazdoori': mazdoori,
      'Expenses': expenses,
    };
  }

  void _openEdit(BuildContext context, PersonModel person) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddPersonScreen(person: person)),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers for real-time updates
    final person = context.watch<PeopleProvider>().getById(personId);
    final allEntries = context.watch<EntryProvider>().entries;

    // Filter entries for this specific person
    final personEntries =
        allEntries.where((e) => e.personId == personId).toList();
    final breakdown = _calculateBreakdown(personEntries);

    if (person == null) {
      return const Scaffold(
        body: Center(child: Text('Person not found or deleted')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(person.name),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _openEdit(context, person),
            child: const Text('Edit',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== 1. TOTAL HISAB CARD ==========
            _buildTotalHisabCard(person),
            const SizedBox(height: AppSizes.paddingLarge),

            // ========== 2. ACTION BUTTONS ==========
            _buildActionButtons(context),
            const SizedBox(height: AppSizes.paddingLarge),

            // ========== 3. CATEGORIES BREAKDOWN ==========
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildCategoryRow('Kapas (Cotton)', Icons.grass,
                      AppColors.kapasColor, breakdown['Kapas (Cotton)']!),
                  const Divider(height: 1),
                  _buildCategoryRow('Paani (Tubewell)', Icons.water_drop,
                      AppColors.paaniColor, breakdown['Paani (Tubewell)']!),
                  const Divider(height: 1),
                  _buildCategoryRow('Mazdoori', Icons.engineering,
                      AppColors.mazdoorColor, breakdown['Mazdoori']!),
                  const Divider(height: 1),
                  _buildCategoryRow('Other / Expenses', Icons.receipt_long,
                      AppColors.expenseColor, breakdown['Expenses']!),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  // ========== WIDGET BUILDERS ==========

  Widget _buildTotalHisabCard(PersonModel person) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Hisab',
            style: TextStyle(color: AppColors.textLight, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            AppFormatters.currency(person.netBalance.abs()),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: person.netBalance == 0
                  ? AppColors.textDark
                  : person.isToReceive
                      ? AppColors.toReceive
                      : AppColors.toPay,
            ),
          ),
          Text(
            person.netBalance == 0
                ? 'Clear'
                : person.isToReceive
                    ? 'You will receive'
                    : 'You will pay',
            style: TextStyle(
              color: person.netBalance == 0
                  ? AppColors.textLight
                  : person.isToReceive
                      ? AppColors.toReceive
                      : AppColors.toPay,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.toReceiveLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Column(
                    children: [
                      const Text('To Receive',
                          style: TextStyle(
                              color: AppColors.textLight, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.currency(person.totalToReceive),
                        style: const TextStyle(
                            color: AppColors.toReceive,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.toPayLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Column(
                    children: [
                      const Text('To Pay',
                          style: TextStyle(
                              color: AppColors.textLight, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.currency(person.totalToPay),
                        style: const TextStyle(
                            color: AppColors.toPay,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(
          label: 'Add Entry',
          icon: Icons.add,
          color: AppColors.primary,
          onTap: () => _navigate(context, const SelectEntryTypeScreen()),
        ),
        _ActionButton(
          label: 'Receive',
          icon: Icons.arrow_downward,
          color: AppColors.toReceive,
          onTap: () => _navigate(context,
              const DynamicEntryScreen(entryType: EntryTypes.paymentReceive)),
        ),
        _ActionButton(
          label: 'Pay',
          icon: Icons.arrow_upward,
          color: AppColors.toPay,
          onTap: () => _navigate(context,
              const DynamicEntryScreen(entryType: EntryTypes.paymentPay)),
        ),
        _ActionButton(
          label: 'History',
          icon: Icons.history,
          color: AppColors.textDark,
          onTap: () {
            // Module 8 mein proper filter ke sath history dikhayenge
            AppHelpers.showSnackBar(
                context, 'History module next step mein aayega!');
          },
        ),
      ],
    );
  }

  Widget _buildCategoryRow(
      String title, IconData icon, Color bgColor, double amount) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: AppColors.textDark),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: AppColors.textDark)),
          ),
          Text(
            AppFormatters.currency(amount),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
