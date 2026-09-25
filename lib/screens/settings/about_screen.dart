import 'package:flutter/material.dart';
import '../../config/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('About App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Placeholder
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.eco, size: 80, color: AppColors.primary),
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              // App Info
              const Text(
                AppStrings.appName,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark),
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.appTagline,
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: const Text(
                  'Version ${AppStrings.appVersion}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ),
              const SizedBox(height: 40),

              // Developer Credit
              const Text(
                'Made with ❤️ for Farmers',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Managing Khata & Hisab effectively.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
