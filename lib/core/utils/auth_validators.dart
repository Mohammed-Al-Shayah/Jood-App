class AuthValidators {
  const AuthValidators._();

  static bool isEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

  static bool isPhone(String value) {
    final digits = normalizePhone(value);
    return digits.length >= 7 && digits.length <= 15;
  }

  static bool isPassword(String value) {
    return value.trim().length >= 6;
  }

  static String normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
