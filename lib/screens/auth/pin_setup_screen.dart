import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/pin_dots.dart';
import '../../widgets/auth/pin_keypad.dart';
import '../../utils/helpers.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  bool _hasError = false;
  String _errorText = '';

  void _onDigit(String digit) {
    setState(() {
      _hasError = false;
      _errorText = '';
      if (_isConfirmStep) {
        if (_confirmPin.length < 4) _confirmPin += digit;
        if (_confirmPin.length == 4) _submitConfirm();
      } else {
        if (_pin.length < 4) _pin += digit;
        if (_pin.length == 4) {
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() => _isConfirmStep = true);
          });
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _hasError = false;
      if (_isConfirmStep) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirmStep = false;
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      }
    });
  }

  Future<void> _submitConfirm() async {
    if (_pin != _confirmPin) {
      setState(() {
        _hasError = true;
        _errorText = 'PINs do not match. Try again.';
        _confirmPin = '';
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.setupPin(_pin);

    if (!mounted) return;

    if (success) {
      AppHelpers.showSnackBar(context, 'PIN set successfully!');
      // Dashboard pe jayenge (abhi temporary)
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      setState(() {
        _hasError = true;
        _errorText = auth.error ?? 'Failed to setup PIN';
        _confirmPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _isConfirmStep ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo / Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.toReceiveLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                _isConfirmStep ? 'Confirm your PIN' : 'Create your PIN',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isConfirmStep
                    ? 'Enter the same 4-digit PIN again'
                    : 'Set a 4-digit PIN to secure your hisab',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),

              const SizedBox(height: 36),

              // PIN Dots
              PinDots(
                filledCount: currentPin.length,
                hasError: _hasError,
              ),

              if (_hasError) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText,
                  style: const TextStyle(
                    color: AppColors.toPay,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const Spacer(),

              // Keypad
              PinKeypad(
                onDigitPressed: _onDigit,
                onBackspace: _onBackspace,
                showFingerprint: false,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
