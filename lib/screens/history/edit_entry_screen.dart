import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/entry_model.dart';
import '../../models/person_model.dart';
import '../../providers/entry_provider.dart';
import '../../providers/people_provider.dart';
import '../../utils/calculations.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/entries/amount_display_card.dart';
import '../../widgets/entries/category_picker.dart';
import '../../widgets/entries/person_picker.dart';

class EditEntryScreen extends StatefulWidget {
  final EntryModel entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _qtyCtrl;
  late TextEditingController _rateCtrl;
  late TextEditingController _manualAmountCtrl;
  late TextEditingController _noteCtrl;

  PersonModel? _selectedPerson;
  String? _selectedCategory;
  String? _selectedCrop;
  String _selectedMethod = 'Cash';
  late DateTime _selectedDate;

  double _calculatedAmount = 0;
  bool _isSaving = false;

  bool get _isExpense => widget.entry.type == EntryTypes.expense;
  bool get _isPaymentReceive => widget.entry.type == EntryTypes.paymentReceive;
  bool get _isPaymentPay => widget.entry.type == EntryTypes.paymentPay;
  bool get _isPayment => _isPaymentReceive || _isPaymentPay;
  bool get _isProduction =>
      widget.entry.type == EntryTypes.kapas ||
      widget.entry.type == EntryTypes.paani ||
      widget.entry.type == EntryTypes.mazdoori;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _selectedDate = e.date;
    _noteCtrl = TextEditingController(text: e.note ?? '');
    _manualAmountCtrl =
        TextEditingController(text: e.amount.toStringAsFixed(0));

    // Load type data
    final data = e.typeData;
    if (e.type == EntryTypes.kapas) {
      _qtyCtrl = TextEditingController(text: '${data['weight'] ?? ''}');
      _rateCtrl = TextEditingController(text: '${data['rate'] ?? ''}');
    } else if (e.type == EntryTypes.paani) {
      _qtyCtrl = TextEditingController(text: '${data['hours'] ?? ''}');
      _rateCtrl = TextEditingController(text: '${data['rate'] ?? ''}');
    } else if (e.type == EntryTypes.mazdoori) {
      _qtyCtrl = TextEditingController(text: '${data['days'] ?? ''}');
      _rateCtrl = TextEditingController(text: '${data['rate'] ?? ''}');
      _selectedCategory = data['workType'];
    } else if (_isExpense) {
      _qtyCtrl = TextEditingController(text: '${data['quantity'] ?? ''}');
      _rateCtrl = TextEditingController();
      _selectedCategory = data['category'];
      _selectedCrop = data['crop'];
    } else {
      _qtyCtrl = TextEditingController();
      _rateCtrl = TextEditingController();
      if (_isPayment) _selectedMethod = data['method'] ?? 'Cash';
    }

    _calculatedAmount = e.amount;

    if (_isProduction) {
      _qtyCtrl.addListener(_calculateDynamicAmount);
      _rateCtrl.addListener(_calculateDynamicAmount);
    }

    // Load selected person
    if (e.personId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final person = context.read<PeopleProvider>().getById(e.personId!);
        if (person != null) setState(() => _selectedPerson = person);
      });
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _manualAmountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _calculateDynamicAmount() {
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    setState(() {
      if (widget.entry.type == EntryTypes.kapas) {
        _calculatedAmount = AppCalculations.kapasAmount(qty, rate);
      } else if (widget.entry.type == EntryTypes.paani) {
        _calculatedAmount = AppCalculations.paaniAmount(qty, rate);
      } else if (widget.entry.type == EntryTypes.mazdoori) {
        _calculatedAmount = AppCalculations.mazdoorAmount(qty, rate);
      }
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isExpense && _selectedPerson == null) {
      AppHelpers.showSnackBar(context, 'Please select person', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final finalAmount = _isProduction
        ? _calculatedAmount
        : double.parse(_manualAmountCtrl.text.trim());

    Map<String, dynamic> typeData = {};
    if (widget.entry.type == EntryTypes.kapas) {
      typeData = {
        'weight': double.parse(_qtyCtrl.text),
        'rate': double.parse(_rateCtrl.text),
        'unit': 'Mann'
      };
    } else if (widget.entry.type == EntryTypes.paani) {
      typeData = {
        'hours': double.parse(_qtyCtrl.text),
        'rate': double.parse(_rateCtrl.text),
        'unit': 'Hours'
      };
    } else if (widget.entry.type == EntryTypes.mazdoori) {
      typeData = {
        'workType': _selectedCategory,
        'days': double.parse(_qtyCtrl.text),
        'rate': double.parse(_rateCtrl.text),
        'unit': 'Days'
      };
    } else if (_isExpense) {
      typeData = {
        'category': _selectedCategory,
        'crop': _selectedCrop,
        'quantity': _qtyCtrl.text
      };
    } else if (_isPayment) {
      typeData = {'method': _selectedMethod};
    }

    final updated = widget.entry.copyWith(
      personId: _selectedPerson?.id,
      personName: _selectedPerson?.name,
      date: _selectedDate,
      amount: finalAmount,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      typeData: typeData,
    );

    final success =
        await context.read<EntryProvider>().updateEntry(widget.entry, updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      AppHelpers.showSnackBar(context, 'Entry updated successfully');
      Navigator.pop(context);
    } else {
      AppHelpers.showSnackBar(context, 'Failed to update', isError: true);
    }
  }

  String get _qtyLabel {
    switch (widget.entry.type) {
      case EntryTypes.kapas:
        return 'Weight (Mann)';
      case EntryTypes.paani:
        return 'Hours';
      case EntryTypes.mazdoori:
        return 'Days';
      case EntryTypes.expense:
        return 'Quantity (Optional)';
      default:
        return 'Quantity';
    }
  }

  String get _rateLabel {
    switch (widget.entry.type) {
      case EntryTypes.kapas:
        return 'Rate (per Mann)';
      case EntryTypes.paani:
        return 'Rate (per Hour)';
      case EntryTypes.mazdoori:
        return 'Rate (per Day)';
      default:
        return 'Rate';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Edit Entry'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isExpense) ...[
                PersonPicker(
                  label: 'Person',
                  selectedPerson: _selectedPerson,
                  onSelected: (p) => setState(() => _selectedPerson = p),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
              ],
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: 'Date',
                    isRequired: true,
                    controller: TextEditingController(
                        text: AppFormatters.date(_selectedDate)),
                    suffixIcon: const Icon(Icons.calendar_today,
                        color: AppColors.textLight, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              if (widget.entry.type == EntryTypes.mazdoori) ...[
                CategoryPicker(
                  label: 'Work Type',
                  selectedValue: _selectedCategory,
                  options: AppCategories.workTypes,
                  onSelected: (v) => setState(() => _selectedCategory = v),
                  isRequired: true,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
              ],
              if (_isExpense) ...[
                CategoryPicker(
                  label: 'Category',
                  selectedValue: _selectedCategory,
                  options: AppCategories.expenseCategories,
                  onSelected: (v) => setState(() => _selectedCategory = v),
                  isRequired: true,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                CategoryPicker(
                  label: 'Crop',
                  selectedValue: _selectedCrop,
                  options: AppCategories.crops,
                  onSelected: (v) => setState(() => _selectedCrop = v),
                  isRequired: true,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
              ],
              if (!_isPayment) ...[
                CustomTextField(
                  label: _qtyLabel,
                  controller: _qtyCtrl,
                  isRequired: !_isExpense,
                  keyboardType: _isExpense
                      ? TextInputType.text
                      : const TextInputType.numberWithOptions(decimal: true),
                  validator: _isExpense ? null : AppValidators.amount,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
              ],
              if (_isProduction) ...[
                CustomTextField(
                  label: _rateLabel,
                  controller: _rateCtrl,
                  isRequired: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: AppValidators.amount,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Rs.',
                        style: TextStyle(
                            color: AppColors.textLight, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                AmountDisplayCard(amount: _calculatedAmount),
                const SizedBox(height: AppSizes.paddingMedium),
              ] else ...[
                CustomTextField(
                  label: 'Amount',
                  controller: _manualAmountCtrl,
                  isRequired: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: AppValidators.amount,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Rs.',
                        style: TextStyle(
                            color: AppColors.textLight, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
              ],
              if (_isPayment) ...[
                _buildMethodSelector(),
                const SizedBox(height: AppSizes.paddingMedium),
              ],
              CustomTextField(
                label: 'Note',
                hint: 'Optional note',
                controller: _noteCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.paddingXL),
              CustomButton(
                text: 'Update Entry',
                onPressed: _save,
                isLoading: _isSaving,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Method',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: AppSizes.paddingSmall),
        Row(
          children: AppCategories.paymentMethods.map((method) {
            final isSelected = _selectedMethod == method;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedMethod = method),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1),
                  ),
                  child: Center(
                    child: Text(
                      method,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? AppColors.primary : AppColors.textDark,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
