class AuthInputValidator {
  const AuthInputValidator._();

  static final RegExp _emailPattern = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$',
    caseSensitive: false,
  );

  static bool isValidEmail(String value) {
    return _emailPattern.hasMatch(value.trim());
  }
}
