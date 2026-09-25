import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/pin_dots.dart';
import '../../widgets/auth/pin_keypad.dart';
import '../../utils/helpers.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _pin = '';
  bool _hasError = false;
  bool _isLoading = false;

  void _onDigit(String digit) {
    if (_isLoading) return;
    setState(() {
      _hasError = false;
      if (_pin.length < 4) {
        _pin += digit;
      }
      if (_pin.length == 4) {
        _submitPin();
      }
    });
  }

  void _onBackspace() {
    if (_isLoading) return;
    setState(() {
      _hasError = false;
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _submitPin() async {
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithPin(_pin);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      setState(() {
        _hasError = true;
        _pin = '';
        _isLoading = false;
      });
      AppHelpers.showSnackBar(
        context,
        auth.error ?? 'Incorrect PIN',
        isError: true,
      );
    }
  }

  Future<void> _onFingerprint() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithFingerprint();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      setState(() => _isLoading = false);
      AppHelpers.showSnackBar(
        context,
        auth.error ?? 'Fingerprint failed',
        isError: true,
      );
    }
  }

  void _onForgotPin() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        title: const Text('Forgot PIN?'),
        content: const Text(
          'For security, you will need to reset the app. All local PIN data will be cleared. Your cloud data (if any) will remain safe.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Extreme reset
              context.read<AuthProvider>();
              // We will add reset later in settings
              AppHelpers.showSnackBar(
                context,
                'Please reinstall or clear app data to reset PIN',
                isError: true,
              );
            },
            child:
                const Text('Reset', style: TextStyle(color: AppColors.toPay)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final showFingerprint =
        auth.fingerprintAvailable && auth.fingerprintEnabled;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
          child: Column(
            children: [
              const SizedBox(height: 50),

              // Leaf / Icon top right style (from design)
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.eco,
                  color: AppColors.primary.withValues(alpha: 0.3),
                  size: 28,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Enter your PIN',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Please enter 4 digit PIN to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),

              const SizedBox(height: 40),

              // PIN Dots
              PinDots(
                filledCount: _pin.length,
                hasError: _hasError,
              ),

              if (_isLoading) ...[
                const SizedBox(height: 24),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ],

              const Spacer(),

              // Keypad
              PinKeypad(
                onDigitPressed: _onDigit,
                onBackspace: _onBackspace,
                onFingerprint: showFingerprint ? _onFingerprint : null,
                showFingerprint: showFingerprint,
              ),

              const SizedBox(height: 24),

              // Fingerprint text button (if available but maybe not shown in keypad)
              if (auth.fingerprintAvailable)
                TextButton.icon(
                  onPressed: _isLoading ? null : _onFingerprint,
                  icon: const Icon(Icons.fingerprint, color: AppColors.primary),
                  label: const Text(
                    'Login with Fingerprint',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // Forgot PIN
              TextButton(
                onPressed: _onForgotPin,
                child: const Text(
                  'Forgot PIN?',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
