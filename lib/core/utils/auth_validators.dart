class AuthValidators {
  const AuthValidators._();

  static bool isEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

  static bool isPassword(String value) {
    return value.trim().length >= 6;
  }
}
