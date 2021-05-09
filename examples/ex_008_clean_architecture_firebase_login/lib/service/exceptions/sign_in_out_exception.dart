class SignInException implements Exception {
  final String? title;
  final String? code;
  final String? message;
  SignInException({this.title, this.code, this.message});
}

class SignOutException implements Exception {
  final title;
  final String? code;
  final String? message;
  SignOutException({this.title, this.code, this.message});
}

class EmailException extends SignInException {
  final String message;
  EmailException(this.message);
}

class PasswordException extends SignInException {
  final String message;
  PasswordException(this.message);
}
