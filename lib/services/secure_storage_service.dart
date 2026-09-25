import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _pinKey = 'user_pin';
  static const _fingerprintKey = 'fingerprint_enabled';
  static const _pinSetKey = 'pin_is_set';

  // Save PIN
  static Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    await _storage.write(key: _pinSetKey, value: 'true');
  }

  // Get PIN
  static Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  // Check if PIN is set
  static Future<bool> isPinSet() async {
    final value = await _storage.read(key: _pinSetKey);
    return value == 'true';
  }

  // Verify PIN
  static Future<bool> verifyPin(String inputPin) async {
    final savedPin = await getPin();
    return savedPin != null && savedPin == inputPin;
  }

  // Fingerprint toggle
  static Future<void> setFingerprintEnabled(bool enabled) async {
    await _storage.write(key: _fingerprintKey, value: enabled.toString());
  }

  static Future<bool> isFingerprintEnabled() async {
    final value = await _storage.read(key: _fingerprintKey);
    return value == 'true';
  }

  // Clear all (Logout / Reset)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
