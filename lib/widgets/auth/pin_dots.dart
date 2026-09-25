import 'package:flutter/material.dart';
import '../../config/constants.dart';

class PinDots extends StatelessWidget {
  final int pinLength;
  final int filledCount;
  final bool hasError;

  const PinDots({
    super.key,
    this.pinLength = 4,
    required this.filledCount,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (index) {
        final isFilled = index < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
                ? AppColors.toPay
                : isFilled
                    ? AppColors.primary
                    : AppColors.border,
            border: Border.all(
              color: hasError
                  ? AppColors.toPay
                  : isFilled
                      ? AppColors.primary
                      : AppColors.border,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}
