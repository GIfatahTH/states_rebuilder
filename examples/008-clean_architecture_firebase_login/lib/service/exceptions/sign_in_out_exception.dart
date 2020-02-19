class SignInException extends Error {
  final title;
  final String code;
  final String message;
  SignInException({this.title, this.code, this.message});
}

class SignOutException extends Error {
  final title;
  final String code;
  final String message;
  SignOutException({this.title, this.code, this.message});
}
