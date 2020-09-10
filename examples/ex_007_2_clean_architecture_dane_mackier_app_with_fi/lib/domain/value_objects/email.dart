import 'package:meta/meta.dart';

import '../exceptions/validation_exception.dart';

@immutable
class Email {
  Email(this.email) {
    if (!email.contains('@')) {
      //Validation at the time of construction
      throw ValidationException('Your email must contain "@"');
    }
  }

  final String email;
}
