class Validators {
  static String? emailValidation(String? email) {
    if (!_emailRegExp.hasMatch(email!)) {
      return 'Enter a valid Email';
    }
    return null;
  }

  static String? passwordValidation(String? password) {
    if (!_passwordRegExp.hasMatch(password!)) {
      return 'Enter a valid password';
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
