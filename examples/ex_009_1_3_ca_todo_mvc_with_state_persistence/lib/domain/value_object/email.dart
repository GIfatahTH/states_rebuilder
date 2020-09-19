import '../exceptions/validation_exception.dart';

class Email {
  final String value;

  Email(this.value) {
    validate(value);
  }

  static void validate(String password) {
    if (!_emailRegExp.hasMatch(password)) {
      throw ValidationException('Enter a valid password');
    }
  }

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
}
