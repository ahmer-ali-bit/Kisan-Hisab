import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/person_model.dart';
import '../../providers/people_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/entries/person_picker.dart';

class PersonWiseReportScreen extends StatefulWidget {
  const PersonWiseReportScreen({super.key});

  @override
  State<PersonWiseReportScreen> createState() => _PersonWiseReportScreenState();
}

class _PersonWiseReportScreenState extends State<PersonWiseReportScreen> {
  PersonModel? _selectedPerson;

  @override
  Widget build(BuildContext context) {
    final people = context.watch<PeopleProvider>().allPeople;

    // Refresh selected person data if updated
    if (_selectedPerson != null) {
      _selectedPerson = people.firstWhere((p) => p.id == _selectedPerson!.id,
          orElse: () => _selectedPerson!);
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Person-wise Report'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PersonPicker(
              label: 'Select Person',
              selectedPerson: _selectedPerson,
              isRequired: false,
              onSelected: (p) => setState(() => _selectedPerson = p),
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            if (_selectedPerson == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('Select a person to view their ledger report.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textLight)),
                ),
              )
            else ...[
              // Report Details for Person
              _buildDetailRow(
                  'Total To Receive',
                  AppFormatters.currency(_selectedPerson!.totalToReceive),
                  AppColors.toReceive),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Total To Pay',
                  AppFormatters.currency(_selectedPerson!.totalToPay),
                  AppColors.toPay),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'Net Balance',
                  AppFormatters.currency(_selectedPerson!.netBalance.abs()),
                  _selectedPerson!.netBalance == 0
                      ? AppColors.textDark
                      : (_selectedPerson!.isToReceive
                          ? AppColors.toReceive
                          : AppColors.toPay),
                  isBold: true),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _selectedPerson!.netBalance == 0
                      ? 'Account Clear'
                      : (_selectedPerson!.isToReceive
                          ? '(You will receive)'
                          : '(You will pay)'),
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color,
      {bool isBold = false}) {
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
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.textDark)),
          Text(value,
              style: TextStyle(
                  fontSize: isBold ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}
