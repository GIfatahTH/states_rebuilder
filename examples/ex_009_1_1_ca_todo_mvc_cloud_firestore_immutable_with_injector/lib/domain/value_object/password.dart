import '../exceptions/validation_exception.dart';

class Password {
  final String value;
  Password(this.value) {
    validate(value);
  }

  static void validate(String password) {
    if (!_passwordRegExp.hasMatch(password)) {
      throw ValidationException('Enter a valid password');
    }
  }

  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );
}
