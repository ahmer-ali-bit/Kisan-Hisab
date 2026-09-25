import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../utils/helpers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _storage = const FlutterSecureStorage();
  bool _isFingerprintEnabled = false;
  String _autoLockTime = '5 Minutes';

  final List<String> _autoLockOptions = [
    'Immediate',
    '1 Minute',
    '5 Minutes',
    '15 Minutes',
    'Never'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final fingerprint = await _storage.read(key: 'fingerprint_enabled');
    final autoLock = await _storage.read(key: 'auto_lock_time');

    setState(() {
      _isFingerprintEnabled = fingerprint == 'true';
      if (autoLock != null && _autoLockOptions.contains(autoLock)) {
        _autoLockTime = autoLock;
      }
    });
  }

  Future<void> _toggleFingerprint(bool value) async {
    setState(() => _isFingerprintEnabled = value);
    await _storage.write(key: 'fingerprint_enabled', value: value.toString());
    if (mounted) {
      AppHelpers.showSnackBar(
          context, value ? 'Fingerprint enabled' : 'Fingerprint disabled');
    }
  }

  Future<void> _changeAutoLock(String? value) async {
    if (value == null) return;
    setState(() => _autoLockTime = value);
    await _storage.write(key: 'auto_lock_time', value: value);
  }

  void _changePin() {
    // Navigate to PIN setup screen in 'change' mode
    // Module 2 me jo PIN Setup screen banai thi use call karein
    Navigator.pushNamed(context, '/pin-setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Security & PIN'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium, vertical: 8),
                    leading:
                        const Icon(Icons.password, color: AppColors.textDark),
                    title: const Text('Change PIN',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                    subtitle: const Text('Update your 4-digit security PIN',
                        style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.textLight),
                    onTap: _changePin,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium, vertical: 8),
                    secondary: const Icon(Icons.fingerprint,
                        color: AppColors.textDark),
                    title: const Text('Enable Fingerprint',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                    subtitle: const Text('Login using biometric authentication',
                        style: TextStyle(fontSize: 12)),
                    activeColor: AppColors.primary,
                    value: _isFingerprintEnabled,
                    onChanged: _toggleFingerprint,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium, vertical: 8),
                    leading: const Icon(Icons.timer_outlined,
                        color: AppColors.textDark),
                    title: const Text('Auto Lock',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                    subtitle: const Text(
                        'When should the app ask for PIN again?',
                        style: TextStyle(fontSize: 12)),
                    trailing: DropdownButton<String>(
                      value: _autoLockTime,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: AppColors.textLight),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      items: _autoLockOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: _changeAutoLock,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
