import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/entry_model.dart';
import '../../models/person_model.dart';
import '../../providers/entry_provider.dart';
import '../../utils/calculations.dart';
import '../../utils/formatters.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/entries/amount_display_card.dart';
import '../../widgets/entries/category_picker.dart';
import '../../widgets/entries/person_picker.dart';

class DynamicEntryScreen extends StatefulWidget {
  final String entryType;

  const DynamicEntryScreen({super.key, required this.entryType});

  @override
  State<DynamicEntryScreen> createState() => _DynamicEntryScreenState();
}

class _DynamicEntryScreenState extends State<DynamicEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _qtyCtrl =
      TextEditingController(); // Weight, Hours, Days, or Qty(String)
  final _rateCtrl = TextEditingController(); // Rate
  final _manualAmountCtrl = TextEditingController(); // For Expense & Payments
  final _noteCtrl = TextEditingController();

  // State Variables
  PersonModel? _selectedPerson;
  String? _selectedCategory; // Used for WorkType & Expense Category
  String? _selectedCrop; // Used for Expense Crop
  String _selectedMethod = 'Cash'; // Used for Payments
  DateTime _selectedDate = DateTime.now();

  double _calculatedAmount = 0; // For Kapas, Paani, Mazdoori
  bool _isSaving = false;
  DateTime? _rateEffectiveFrom;

  // ========== GETTERS FOR DYNAMIC UI ==========

  bool get _isExpense => widget.entryType == EntryTypes.expense;
  bool get _isPaymentReceive => widget.entryType == EntryTypes.paymentReceive;
  bool get _isPaymentPay => widget.entryType == EntryTypes.paymentPay;
  bool get _isPayment => _isPaymentReceive || _isPaymentPay;
  bool get _isProduction =>
      widget.entryType == EntryTypes.kapas ||
      widget.entryType == EntryTypes.paani ||
      widget.entryType == EntryTypes.mazdoori;

  String get _title {
    switch (widget.entryType) {
      case EntryTypes.kapas:
        return 'Kapas Entry';
      case EntryTypes.paani:
        return 'Paani Entry';
      case EntryTypes.mazdoori:
        return 'Mazdoori Entry';
      case EntryTypes.expense:
        return 'Agriculture Expense';
      case EntryTypes.paymentReceive:
        return 'Receive Payment';
      case EntryTypes.paymentPay:
        return 'Make Payment';
      default:
        return 'Add Entry';
    }
  }

  String get _qtyLabel {
    switch (widget.entryType) {
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
    switch (widget.entryType) {
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

  Color get _btnColor {
    if (_isPaymentReceive) return AppColors.toReceive;
    if (_isPaymentPay) return AppColors.toPay;
    return AppColors.primary;
  }

  // ========== INIT & LOGIC ==========

  @override
  void initState() {
    super.initState();
    if (_isProduction) {
      _qtyCtrl.addListener(_calculateDynamicAmount);
      _rateCtrl.addListener(_calculateDynamicAmount);
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLatestRate());
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
      if (widget.entryType == EntryTypes.kapas) {
        _calculatedAmount = AppCalculations.kapasAmount(qty, rate);
      } else if (widget.entryType == EntryTypes.paani) {
        _calculatedAmount = AppCalculations.paaniAmount(qty, rate);
      } else if (widget.entryType == EntryTypes.mazdoori) {
        _calculatedAmount = AppCalculations.mazdoorAmount(qty, rate);
      }
    });
  }

  Future<void> _fetchLatestRate() async {
    final rate = await context
        .read<EntryProvider>()
        .getLatestRate(widget.entryType, _selectedDate);
    if (rate != null && mounted) {
      setState(() {
        _rateCtrl.text = rate.ratePerUnit.toStringAsFixed(0);
        _rateEffectiveFrom = rate.effectiveFrom;
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
      if (_isProduction) _fetchLatestRate();
    }
  }

  // ========== SAVE LOGIC ==========

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Custom Validations
    if (!_isExpense && _selectedPerson == null) {
      AppHelpers.showSnackBar(context, 'Please select person', isError: true);
      return;
    }
    if (widget.entryType == EntryTypes.mazdoori && _selectedCategory == null) {
      AppHelpers.showSnackBar(context, 'Please select work type',
          isError: true);
      return;
    }
    if (_isExpense) {
      if (_selectedCategory == null) {
        AppHelpers.showSnackBar(context, 'Please select category',
            isError: true);
        return;
      }
      if (_selectedCrop == null) {
        AppHelpers.showSnackBar(context, 'Please select crop', isError: true);
        return;
      }
    }

    setState(() => _isSaving = true);

    // Final Amount
    final finalAmount = _isProduction
        ? _calculatedAmount
        : double.parse(_manualAmountCtrl.text.trim());

    // Type Specific Data Map
    Map<String, dynamic> typeData = {};
    if (widget.entryType == EntryTypes.kapas) {
      typeData = {
        'weight': double.parse(_qtyCtrl.text),
        'rate': double.parse(_rateCtrl.text),
        'unit': 'Mann'
      };
    } else if (widget.entryType == EntryTypes.paani) {
      typeData = {
        'hours': double.parse(_qtyCtrl.text),
        'rate': double.parse(_rateCtrl.text),
        'unit': 'Hours'
      };
    } else if (widget.entryType == EntryTypes.mazdoori) {
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

    final entry = EntryModel(
      id: '',
      type: widget.entryType,
      personId: _selectedPerson?.id,
      personName: _selectedPerson?.name,
      date: _selectedDate,
      amount: finalAmount,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      typeData: typeData,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await context.read<EntryProvider>().addEntry(entry);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      AppHelpers.showSnackBar(context, '$_title saved successfully');
      Navigator.pop(context);
    } else {
      AppHelpers.showSnackBar(context, 'Failed to save entry', isError: true);
    }
  }

  // ========== UI BUILDER ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(_title),
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
              // 1. Person Picker (Hidden for Expense)
              if (!_isExpense) ...[
                PersonPicker(
                  label: _isPaymentReceive
                      ? 'From (Person)'
                      : _isPaymentPay
                          ? 'To (Person)'
                          : 'Person',
                  selectedPerson: _selectedPerson,
                  onSelected: (p) => setState(() => _selectedPerson = p),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
              ],

              // 2. Date Picker
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

              // 3. Category/WorkType Picker (For Mazdoori & Expense)
              if (widget.entryType == EntryTypes.mazdoori) ...[
                CategoryPicker(
                  label: 'Work Type',
                  selectedValue: _selectedCategory,
                  options: AppCategories.workTypes,
                  onSelected: (v) => setState(() => _selectedCategory = v),
                  isRequired: true,
                  hint: 'Select work type',
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
                  hint: 'Select expense category',
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                CategoryPicker(
                  label: 'Crop',
                  selectedValue: _selectedCrop,
                  options: AppCategories.crops,
                  onSelected: (v) => setState(() => _selectedCrop = v),
                  isRequired: true,
                  hint: 'Select crop',
                ),
                const SizedBox(height: AppSizes.paddingMedium),
              ],

              // 4. Quantity Field (Weight/Hours/Days/Qty) (Hidden for Payments)
              if (!_isPayment) ...[
                CustomTextField(
                  label: _qtyLabel,
                  hint: 'e.g., 5',
                  controller: _qtyCtrl,
                  isRequired:
                      !_isExpense, // Required for production, optional for expense
                  keyboardType: _isExpense
                      ? TextInputType.text
                      : const TextInputType.numberWithOptions(decimal: true),
                  validator: _isExpense ? null : AppValidators.amount,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
              ],

              // 5. Rate Field (Only for Production)
              if (_isProduction) ...[
                CustomTextField(
                  label: _rateLabel,
                  hint: 'e.g., 1000',
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
                if (_rateEffectiveFrom != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          'Current Rate from ${AppFormatters.date(_rateEffectiveFrom!)}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSizes.paddingMedium),
              ],

              // 6. Amount Section
              if (_isProduction) ...[
                AmountDisplayCard(amount: _calculatedAmount),
                const SizedBox(height: AppSizes.paddingMedium),
              ] else ...[
                CustomTextField(
                  label: 'Amount',
                  hint: 'e.g., 5000',
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

              // 7. Payment Method (Only for Payments)
              if (_isPayment) ...[
                _buildMethodSelector(),
                const SizedBox(height: AppSizes.paddingMedium),
              ],

              // 8. Note Field
              CustomTextField(
                label: 'Note',
                hint: 'Optional note',
                controller: _noteCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.paddingXL),

              // 9. Submit Button
              CustomButton(
                text: 'Save Entry',
                onPressed: _save,
                isLoading: _isSaving,
                color: _btnColor,
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
                        ? _btnColor.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                        color: isSelected ? _btnColor : AppColors.border,
                        width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: isSelected ? _btnColor : AppColors.textLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        method,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? _btnColor : AppColors.textDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
