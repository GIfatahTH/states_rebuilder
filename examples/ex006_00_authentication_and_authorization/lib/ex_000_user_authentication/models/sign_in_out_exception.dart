class AuthException implements Exception {
  final String? title;
  final String? code;
  final String? message;
  AuthException({this.title, this.code, this.message});
}

class EmailException extends AuthException {
  EmailException(String message) : super(title: message, message: message);
}

class PasswordException extends AuthException {
  PasswordException(String message) : super(title: message, message: message);
}
