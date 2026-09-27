import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= AppBreakpoints.mobile && w < AppBreakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.desktop;

  /// Side nav tabhi jab width tablet+ ho
  static bool useSideNav(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 1100;
    if (isTablet(context)) return 800;
    return double.infinity;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
    return const EdgeInsets.all(16);
  }
}

/// Extension on BuildContext for dynamic layout calculations using MediaQuery
extension ResponsiveContext on BuildContext {
  /// Screen width from MediaQuery
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Screen height from MediaQuery
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Dynamically scale width from reference design (375px) using MediaQuery
  double w(double widthPx) => (widthPx / 375.0) * screenWidth;

  /// Dynamically scale height from reference design (812px) using MediaQuery
  double h(double heightPx) => (heightPx / 812.0) * screenHeight;

  /// Dynamically scale font/icon size from reference design using MediaQuery
  double sp(double sizePx) => (sizePx / 375.0) * screenWidth;
}

