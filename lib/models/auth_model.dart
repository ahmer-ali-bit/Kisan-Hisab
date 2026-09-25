class AuthModel {
  final bool isPinSet;
  final bool fingerprintEnabled;
  final int autoLockMinutes;

  AuthModel({
    this.isPinSet = false,
    this.fingerprintEnabled = false,
    this.autoLockMinutes = 5,
  });
}
