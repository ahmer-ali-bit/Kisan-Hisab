import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kisan_hisab/screens/auth/pin_login_screen.dart';
import 'package:kisan_hisab/screens/auth/pin_setup_screen.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Smooth, professional 1.2s fade-in
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // 3 seconds delay -> Move to next screen
    Timer(const Duration(seconds: 3), _navigateToNext);
  }

  void _navigateToNext() async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.checkAuthStatus();

    if (!mounted) return;

    Widget nextScreen;
    if (auth.status == AuthStatus.pinNotSet) {
      nextScreen = const PinSetupScreen();
    } else {
      nextScreen = const PinLoginScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: Stack(
        children: [
          // 1. FULL SCREEN BACKGROUND IMAGE (Farm Illustration)
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // 2. LOGO + TITLE + TAGLINE (Positioned in Top/Upper-Center)
          Positioned(
            top: screenHeight * 0.16,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: screenWidth * 0.42,
                    height: screenWidth * 0.42,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: AppSizes.paddingMedium),

                  // App Title (KISAN HISAB)
                  const Text(
                    'KISAN HISAB',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E6B3B), // Exact Kisan Green
                      letterSpacing: 1.2,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // App Tagline
                  const Text(
                    'Aapka Khet, Aapka Hisab',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. BOTTOM LOADING TEXT
          Positioned(
            left: AppSizes.paddingLarge,
            bottom: mediaQuery.padding.bottom + 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Row(
                children: [
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Temporary Next Screen (Module 2: PIN Login Screen yahan aayega)
class _TempNextScreen extends StatelessWidget {
  const _TempNextScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 70, color: AppColors.primary),
            SizedBox(height: 20),
            Text(
              'Splash Complete!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Next: PIN Login Screen',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
