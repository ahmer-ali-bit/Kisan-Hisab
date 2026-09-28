import 'package:flutter/material.dart';

class AppColors {
  // Main Theme
  static const Color primary = Color(0xFF1E6B3B);
  static const Color primaryDark = Color(0xFF14522C);
  static const Color background = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF8F9FA);

  // Text
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status
  static const Color toReceive = Color(0xFF2E7D32);
  static const Color toReceiveLight = Color(0xFFE8F5E9);
  static const Color toPay = Color(0xFFD32F2F);
  static const Color toPayLight = Color(0xFFFFEBEE);

  // Others
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Category Colors
  static const Color kapasColor = Color(0xFFFFF3E0);
  static const Color paaniColor = Color(0xFFE3F2FD);
  static const Color mazdoorColor = Color(0xFFFFF8E1);
  static const Color expenseColor = Color(0xFFF3E5F5);
}

class AppSizes {
  static const double paddingXS = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXL = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;

  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  static const double buttonHeight = 52.0;
}

class AppStrings {
  static const String appName = 'KISAN HISAB';
  static const String appTagline = 'Aapka Khet, Aapka Hisab';
  static const String appVersion = '1.0.0';
}

// ============ ENTRY TYPES ============
class EntryTypes {
  static const String kapas = 'kapas';
  static const String paani = 'paani';
  static const String mazdoori = 'mazdoori';
  static const String expense = 'expense';
  static const String paymentReceive = 'payment_receive';
  static const String paymentPay = 'payment_pay';
}

// ============ HARDCODED CATEGORIES ============
class AppCategories {
  // Work Types for Mazdoori
  static const List<String> workTypes = [
    'Kapas Chunai',
    'Halai',
    'Buwai',
    'Other',
  ];

  // Expense Categories
  static const List<String> expenseCategories = [
    'Khaad (Fertilizer)',
    'Beej (Seed)',
    'Dawai (Pesticide)',
    'Diesel',
    'Other',
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Bank',
    'Other',
  ];

  // Crops
  static const List<String> crops = [
    'Kapas (Cotton)',
    'Gandum (Wheat)',
    'Ganna (Sugarcane)',
    'Chawal (Rice)',
    'Other',
  ];
}
