class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class EmailException implements Exception {
  final String message;
  EmailException.invalidEmail() : message = 'Invalid Email';
  EmailException.emailNotFound() : message = 'Email Not Found';
  EmailException.emailExists() : message = 'Email Exists';
}

class PasswordException implements Exception {
  final String message;
  PasswordException.weakPassword() : message = 'Weak Password';
  PasswordException.invalidPassword() : message = 'Invalid Password';
}
