import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/rate_model.dart';
import '../../providers/rate_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddRateScreen extends StatefulWidget {
  final String rateType; // kapas, paani, mazdoori

  const AddRateScreen({super.key, required this.rateType});

  @override
  State<AddRateScreen> createState() => _AddRateScreenState();
}

class _AddRateScreenState extends State<AddRateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rateCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _rateCtrl.dispose();
    super.dispose();
  }

  String _getTitle() {
    switch (widget.rateType) {
      case 'kapas':
        return 'Add Kapas Rate';
      case 'paani':
        return 'Add Paani Rate';
      case 'mazdoori':
        return 'Add Mazdoori Rate';
      default:
        return 'Add Rate';
    }
  }

  String _getLabel() {
    switch (widget.rateType) {
      case 'kapas':
        return 'Rate (per Mann)';
      case 'paani':
        return 'Rate (per Hour)';
      case 'mazdoori':
        return 'Rate (per Day)';
      default:
        return 'Rate';
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final rate = RateModel(
      id: '',
      type: widget.rateType,
      ratePerUnit: double.parse(_rateCtrl.text.trim()),
      effectiveFrom: _selectedDate,
      createdAt: DateTime.now(),
    );

    final success = await context.read<RateProvider>().addRate(rate);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      AppHelpers.showSnackBar(context, 'Rate saved successfully');
      Navigator.pop(context);
    } else {
      AppHelpers.showSnackBar(
        context,
        context.read<RateProvider>().error ?? 'Failed to save rate',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(_getTitle()),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Date Picker Field
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  color: Colors.transparent,
                  child: IgnorePointer(
                    child: CustomTextField(
                      label: 'Effective From',
                      controller: TextEditingController(
                        text: AppFormatters.date(_selectedDate),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today,
                          color: AppColors.textLight, size: 20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.paddingMedium),

              // Rate Field
              CustomTextField(
                label: _getLabel(),
                hint: 'e.g., 300',
                controller: _rateCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                isRequired: true,
                validator: AppValidators.amount,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Rs.',
                      style:
                          TextStyle(color: AppColors.textLight, fontSize: 16)),
                ),
              ),

              const SizedBox(height: AppSizes.paddingXL),

              CustomButton(
                text: 'Save Rate',
                onPressed: _save,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
