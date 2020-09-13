import '../common/validator.dart';
import '../exceptions/Validation_exception.dart';

class Email {
  final String value;
  Email(this.value) {
    if (!Validators.isValidEmail(value)) {
      throw ValidationException('Enter a valid email');
    }
  }
}
