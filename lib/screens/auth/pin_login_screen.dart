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

  Future<void> _onForgotPin() async {
    if (_isLoading) return;

    final confirmed = await AppHelpers.showConfirmDialog(
      context,
      title: 'Forgot PIN?',
      message:
          'Your old PIN will be removed and you will be asked to create a new one. '
          'Your ledger data stays safe in the cloud and is not deleted.',
      confirmText: 'Reset PIN',
    );

    if (!confirmed || !mounted) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.resetApp();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil('/pin-setup', (route) => false);
    } else {
      AppHelpers.showSnackBar(
        context,
        auth.error ?? 'Failed to reset PIN. Please try again.',
        isError: true,
      );
    }
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
