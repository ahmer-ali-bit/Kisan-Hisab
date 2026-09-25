import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/local_auth_service.dart';

enum AuthStatus { unknown, pinNotSet, pinSet, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  bool _isLoading = false;
  String? _error;
  bool _fingerprintAvailable = false;
  bool _fingerprintEnabled = false;

  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get fingerprintAvailable => _fingerprintAvailable;
  bool get fingerprintEnabled => _fingerprintEnabled;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // App start par call hoga (Splash se)
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final pinSet = await AuthService.isPinSet();
      _fingerprintAvailable = await LocalAuthService.isBiometricAvailable();
      _fingerprintEnabled = await AuthService.isFingerprintEnabled();

      if (!pinSet) {
        _status = AuthStatus.pinNotSet;
      } else {
        _status = AuthStatus.pinSet;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.pinNotSet;
    }

    _isLoading = false;
    notifyListeners();
  }

  // First time PIN setup
  Future<bool> setupPin(String pin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await AuthService.setupPin(pin);
      if (success) {
        _status = AuthStatus.authenticated;
      } else {
        _error = 'Failed to setup PIN';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login with PIN
  Future<bool> loginWithPin(String pin) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await AuthService.loginWithPin(pin);
      if (success) {
        _status = AuthStatus.authenticated;
      } else {
        _error = 'Incorrect PIN. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login with Fingerprint
  Future<bool> loginWithFingerprint() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await AuthService.loginWithFingerprint();
      if (success) {
        _status = AuthStatus.authenticated;
      } else {
        _error = 'Fingerprint authentication failed';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Enable / Disable fingerprint
  Future<bool> toggleFingerprint(bool enable) async {
    try {
      await AuthService.enableFingerprint(enable);
      _fingerprintEnabled = enable;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
