import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/common/localization/localization.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class EmailException implements Exception {
  final String message;
  EmailException.invalidEmail() : message = i18n.state.invalidEmail;
  EmailException.emailNotFound() : message = i18n.state.emailNotFound;
  EmailException.emailExists() : message = i18n.state.emailExists;
}

class PasswordException implements Exception {
  final String message;
  PasswordException.weakPassword() : message = i18n.state.weakPassword;
  PasswordException.invalidPassword() : message = i18n.state.invalidPassword;
}
