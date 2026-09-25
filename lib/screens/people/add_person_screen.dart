import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../models/person_model.dart';
import '../../providers/people_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/people/person_avatar.dart';

class AddPersonScreen extends StatefulWidget {
  final PersonModel? person; // null = Add, non-null = Edit

  const AddPersonScreen({super.key, this.person});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String? _photoBase64;
  bool _isSaving = false;
  bool get _isEdit => widget.person != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.person!;
      _nameCtrl.text = p.name;
      _phoneCtrl.text = p.phone ?? '';
      _addressCtrl.text = p.address ?? '';
      _noteCtrl.text = p.note ?? '';
      _photoBase64 = p.photoBase64;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMedium)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 50,
      );

      if (picked == null) return; // User cancelled selection

      // Use XFile readAsBytes() directly (Works on iOS, Android, Web & Desktop)
      final bytes = await picked.readAsBytes();

      if (bytes.length > 300 * 1024) {
        if (!mounted) return;
        AppHelpers.showSnackBar(
          context,
          'Image size too large. Select a smaller photo.',
          isError: true,
        );
        return;
      }

      setState(() {
        _photoBase64 = base64Encode(bytes);
      });
    } on PlatformException catch (e) {
      debugPrint('ImagePicker PlatformException: ${e.code} - ${e.message}');
      if (!mounted) return;
      if (source == ImageSource.camera && e.code.contains('camera')) {
        AppHelpers.showSnackBar(
          context,
          'Camera is not available on iOS Simulator. Please choose from Gallery.',
          isError: true,
        );
      } else {
        AppHelpers.showSnackBar(
          context,
          'Permission denied. Please allow access in Settings.',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('ImagePicker Error: $e');
      if (!mounted) return;
      AppHelpers.showSnackBar(
        context,
        'Could not load image. Try another photo.',
        isError: true,
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<PeopleProvider>();
    final now = DateTime.now();

    final person = PersonModel(
      id: _isEdit ? widget.person!.id : '',
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      address:
          _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      photoBase64: _photoBase64,
      totalToReceive: _isEdit ? widget.person!.totalToReceive : 0,
      totalToPay: _isEdit ? widget.person!.totalToPay : 0,
      createdAt: _isEdit ? widget.person!.createdAt : now,
      updatedAt: now,
    );

    bool success;
    if (_isEdit) {
      success = await provider.updatePerson(person);
    } else {
      success = await provider.addPerson(person);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      AppHelpers.showSnackBar(
        context,
        _isEdit ? 'Person updated' : 'Person added',
      );
      Navigator.pop(context, true);
    } else {
      AppHelpers.showSnackBar(
        context,
        provider.error ?? 'Failed to save',
        isError: true,
      );
    }
  }

  Future<void> _delete() async {
    final confirm = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Person?',
      message: 'This will permanently delete ${widget.person!.name}.',
      confirmText: 'Delete',
    );
    if (!confirm || !mounted) return;

    setState(() => _isSaving = true);
    final success =
        await context.read<PeopleProvider>().deletePerson(widget.person!.id);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      AppHelpers.showSnackBar(context, 'Person deleted');
      Navigator.pop(context, true);
    } else {
      AppHelpers.showSnackBar(context, 'Delete failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(_isEdit ? 'Edit Person' : 'Add Person'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _isSaving ? null : _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Photo
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    PersonAvatar(
                      name: _nameCtrl.text.isEmpty ? '?' : _nameCtrl.text,
                      photoBase64: _photoBase64,
                      radius: 48,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap to add photo (optional)',
                style: TextStyle(fontSize: 12, color: AppColors.textLight),
              ),

              const SizedBox(height: AppSizes.paddingLarge),

              CustomTextField(
                label: 'Full Name',
                hint: 'Enter full name',
                controller: _nameCtrl,
                isRequired: true,
                validator: (v) => AppValidators.required(v, 'Name'),
                onChanged: (_) => setState(() {}), // avatar initials update
              ),
              const SizedBox(height: AppSizes.paddingMedium),

              CustomTextField(
                label: 'Phone',
                hint: 'Enter phone number',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: AppValidators.phone,
              ),
              const SizedBox(height: AppSizes.paddingMedium),

              CustomTextField(
                label: 'Address',
                hint: 'Enter address (optional)',
                controller: _addressCtrl,
              ),
              const SizedBox(height: AppSizes.paddingMedium),

              CustomTextField(
                label: 'Note',
                hint: 'Any note (optional)',
                controller: _noteCtrl,
                maxLines: 3,
              ),

              const SizedBox(height: AppSizes.paddingXL),

              CustomButton(
                text: _isEdit ? 'Update Person' : 'Save Person',
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
}
