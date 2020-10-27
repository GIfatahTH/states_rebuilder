class SignInException implements Exception {
  final title;
  final String code;
  final String message;
  SignInException({this.title, this.code, this.message});
}

class SignOutException implements Exception {
  final title;
  final String code;
  final String message;
  SignOutException({this.title, this.code, this.message});
}
