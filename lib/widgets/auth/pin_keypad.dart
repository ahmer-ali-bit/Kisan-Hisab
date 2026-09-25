import 'package:flutter/material.dart';
import '../../config/constants.dart';

class PinKeypad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onFingerprint;
  final bool showFingerprint;

  const PinKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
    this.onFingerprint,
    this.showFingerprint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 12),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 12),
        _buildRow([
          showFingerprint ? 'fingerprint' : '',
          '0',
          'backspace',
        ]),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 72, height: 72);
        }
        if (key == 'fingerprint') {
          return _KeypadButton(
            onTap: onFingerprint,
            child: const Icon(
              Icons.fingerprint,
              size: 32,
              color: AppColors.primary,
            ),
          );
        }
        if (key == 'backspace') {
          return _KeypadButton(
            onTap: onBackspace,
            child: const Icon(
              Icons.backspace_outlined,
              size: 26,
              color: AppColors.textDark,
            ),
          );
        }
        return _KeypadButton(
          onTap: () => onDigitPressed(key),
          child: Text(
            key,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _KeypadButton({this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.scaffoldBackground,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
