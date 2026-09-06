import 'package:ai_food_analyzer/features/auth/domain/auth_input_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts common Outlook and Hotmail email addresses', () {
    expect(AuthInputValidator.isValidEmail('user@outlook.com'), isTrue);
    expect(AuthInputValidator.isValidEmail('name.surname@hotmail.com'), isTrue);
    expect(AuthInputValidator.isValidEmail('user+test@outlook.com'), isTrue);
  });

  test('rejects malformed email addresses', () {
    expect(AuthInputValidator.isValidEmail('user@outlook'), isFalse);
    expect(AuthInputValidator.isValidEmail('user outlook.com'), isFalse);
    expect(AuthInputValidator.isValidEmail('@hotmail.com'), isFalse);
  });
}
