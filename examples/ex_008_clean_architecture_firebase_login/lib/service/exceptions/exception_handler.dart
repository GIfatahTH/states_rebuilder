import '../../domain/exceptions/Validation_exception.dart';
import '../../service/exceptions/sign_in_out_exception.dart';

class ExceptionsHandler {
  static ErrorMessage errorMessage(dynamic error) {
    if (error == null) {
      return ErrorMessage();
    }
    if (error is SignInException) {
      return ErrorMessage(message: error.message!, title: error.title);
    }

    if (error is ValidationException) {
      return ErrorMessage(message: error.message);
    }
    throw error;
  }
}

class ErrorMessage {
  final String? title;
  final String? message;

  ErrorMessage({this.title, this.message});
}
