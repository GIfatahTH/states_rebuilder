import '../common/validator.dart';
import '../exceptions/Validation_exception.dart';

class Password {
  final String value;
  Password(this.value) {
    if (!Validators.isValidPassword(value)) {
      throw ValidationException('Enter a valid password');
    }
  }
}
