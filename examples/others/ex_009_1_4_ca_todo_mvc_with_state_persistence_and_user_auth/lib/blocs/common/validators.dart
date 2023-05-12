import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/localization/localization.dart';

class Validators {
  static String? emailValidation(String? email) {
    if (!_emailRegExp.hasMatch(email!)) {
      return i18n.state.enterValidEmail;
    }
    return null;
  }

  static String? passwordValidation(String? password) {
    if (!_passwordRegExp.hasMatch(password!)) {
      return i18n.state.enterValidPassword;
    }
    return null;
  }

  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
}
