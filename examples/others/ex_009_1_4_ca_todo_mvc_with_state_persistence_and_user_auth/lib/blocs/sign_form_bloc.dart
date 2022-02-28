import 'package:flutter/foundation.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'auth_bloc.dart';
import 'common/validators.dart';
import 'exceptions/auth_exception.dart';

@immutable
class SignFormBloc {
  final email = RM.injectTextEditing(
    validators: [
      Validators.emailValidation,
    ],
  );
  final password = RM.injectTextEditing(
    validateOnTyping: true,
    validators: [
      Validators.passwordValidation,
    ],
  );

  late final confirmPassword = RM.injectTextEditing(
    validateOnTyping: true,
    validators: [
      (value) {
        if (password.text != value) {
          return 'Passwords do not match';
        }
      }
    ],
  );
  final isRegister = false.inj();

  late final form = RM.injectForm(
    submit: () async {
      if (isRegister.state) {
        await authBloc.signUp(email.text, password.text);
      } else {
        await authBloc.signIn(email.text, password.text);
      }
      //If the server return exception, it will be  captured in the userRM
      //
      //After server validation
      switch (authBloc.authError.runtimeType) {
        case EmailException:
          email.error = authBloc.authError.message;
          break;
        case PasswordException:
          password.error = authBloc.authError.message;
          break;
        default:
      }
    },
  );
}

final signFormBloc = SignFormBloc();
