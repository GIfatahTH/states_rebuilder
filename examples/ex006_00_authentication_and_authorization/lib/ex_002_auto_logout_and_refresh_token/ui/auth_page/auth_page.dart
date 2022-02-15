import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../blocs/auth_bloc.dart';
import '../../common/validators.dart';
import '../../models/auth_exception.dart';

final email = RM.injectTextEditing(
  validators: [
    Validators.emailValidation,
  ],
);
final password = RM.injectTextEditing(
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
      return null;
    }
  ],
);
final isRegister = false.inj();

late final form = RM.injectForm(
  submit: () async {
    if (isRegister.state) {
      await authBloc.register(email.text, password.text);
    } else {
      await authBloc.login(email.text, password.text);
    }
    //If the server return exception, it will be  captured in the userRM
    //
    //After server validation
    switch (authBloc.error.runtimeType) {
      case EmailException:
        email.error = authBloc.error.message;
        break;
      case PasswordException:
        password.error = authBloc.error.message;
        break;
      default:
    }
  },
);

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: AuthFormWidget(),
      ),
    );
  }
}

class AuthFormWidget extends StatelessWidget {
  const AuthFormWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnFormBuilder(
      listenTo: form,
      builder: () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            key: const Key('__EmailField__'),
            controller: email.controller,
            focusNode: email.focusNode,
            decoration: InputDecoration(
              icon: const Icon(Icons.email),
              labelText: 'Email',
              errorText: email.error,
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onSubmitted: (_) {
              password.focusNode.requestFocus();
            },
          ),
          TextField(
            key: const Key('__PasswordField__'),
            controller: password.controller,
            focusNode: password.focusNode,
            decoration: InputDecoration(
              icon: const Icon(Icons.lock),
              labelText: 'Password',
              errorText: password.error,
            ),
            obscureText: true,
            autocorrect: false,
            onSubmitted: (_) {
              if (isRegister.state) {
                confirmPassword.focusNode.requestFocus();
              } else {
                form.submitFocusNode.requestFocus();
              }
            },
          ),
          if (isRegister.state)
            TextField(
              key: const Key('__ConfirmPasswordField__'),
              controller: confirmPassword.controller,
              focusNode: confirmPassword.focusNode,
              decoration: InputDecoration(
                icon: const Icon(Icons.lock),
                labelText: 'Confirm password',
                errorText: confirmPassword.error,
              ),
              obscureText: true,
              autocorrect: false,
              onSubmitted: (_) {
                form.submitFocusNode.requestFocus();
              },
            ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Checkbox(
                value: isRegister.state,
                onChanged: (value) {
                  isRegister.state = value!;
                },
              ),
              const Text('I do not have an account')
            ],
          ),
          OnFormSubmissionBuilder(
            listenTo: form,
            onSubmitting: () => const Center(
              child: CircularProgressIndicator(),
            ),
            child: ElevatedButton(
              focusNode: form.submitFocusNode,
              child: isRegister.state
                  ? const Text('Sign Up')
                  : const Text('Sign in'),
              onPressed: () {
                form.submit();
              },
            ),
          ),
        ],
      ),
    );
  }
}
