import 'package:firebase_auth/firebase_auth.dart';
import 'secure_storage_service.dart';
import 'local_auth_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current Firebase user
  static User? get currentUser => _auth.currentUser;

  // Check if user is logged in (Firebase)
  static bool get isLoggedIn => currentUser != null;

  // ========== PIN SETUP (First Time) ==========
  static Future<bool> setupPin(String pin) async {
    if (pin.length != 4) return false;
    await SecureStorageService.savePin(pin);
    // Firebase Anonymous Sign In
    await _signInAnonymously();
    return true;
  }

  // ========== PIN LOGIN ==========
  static Future<bool> loginWithPin(String pin) async {
    final isValid = await SecureStorageService.verifyPin(pin);
    if (!isValid) return false;

    // Ensure Firebase session
    if (currentUser == null) {
      await _signInAnonymously();
    }
    return true;
  }

  // ========== FINGERPRINT LOGIN ==========
  static Future<bool> loginWithFingerprint() async {
    final enabled = await SecureStorageService.isFingerprintEnabled();
    if (!enabled) return false;

    final success = await LocalAuthService.authenticate(
      reason: 'Login to Kisan Hisab',
    );

    if (success && currentUser == null) {
      await _signInAnonymously();
    }
    return success;
  }

  // ========== CHANGE PIN ==========
  static Future<bool> changePin(String oldPin, String newPin) async {
    final isValid = await SecureStorageService.verifyPin(oldPin);
    if (!isValid) return false;
    if (newPin.length != 4) return false;
    await SecureStorageService.savePin(newPin);
    return true;
  }

  // ========== FINGERPRINT TOGGLE ==========
  static Future<void> enableFingerprint(bool enable) async {
    if (enable) {
      final available = await LocalAuthService.isBiometricAvailable();
      if (!available) throw Exception('Biometric not available');
      // Verify once before enabling
      final ok = await LocalAuthService.authenticate(
        reason: 'Verify to enable fingerprint login',
      );
      if (!ok) throw Exception('Verification failed');
    }
    await SecureStorageService.setFingerprintEnabled(enable);
  }

  // ========== CHECK STATUS ==========
  static Future<bool> isPinSet() async {
    return await SecureStorageService.isPinSet();
  }

  static Future<bool> isFingerprintEnabled() async {
    return await SecureStorageService.isFingerprintEnabled();
  }

  // ========== FIREBASE ANONYMOUS ==========
  static Future<void> _signInAnonymously() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
    } catch (e) {
      // Offline mode mein bhi allow karenge
      print('Firebase anonymous sign-in: $e');
    }
  }

  // ========== LOGOUT ==========
  static Future<void> logout() async {
    await _auth.signOut();
    // PIN clear nahi karte — sirf session
  }

  // ========== RESET APP (Forgot PIN extreme) ==========
  static Future<void> resetApp() async {
    await SecureStorageService.clearAll();
    await _auth.signOut();
  }
}
