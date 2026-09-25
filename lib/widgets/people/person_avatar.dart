import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../utils/helpers.dart';

class PersonAvatar extends StatelessWidget {
  final String name;
  final String? photoBase64;
  final double radius;

  const PersonAvatar({
    super.key,
    required this.name,
    this.photoBase64,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(photoBase64!);
        return CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.toReceiveLight,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {
        // fall through to initials
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        AppHelpers.getInitials(name),
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
