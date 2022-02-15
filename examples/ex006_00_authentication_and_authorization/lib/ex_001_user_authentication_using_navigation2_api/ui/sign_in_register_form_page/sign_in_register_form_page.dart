import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../blocs/auth_bloc.dart';
import '../../common/validator.dart';
import '../../models/sign_in_out_exception.dart';
import '../../models/user.dart';

final _email = RM.injectTextEditing(
  validators: [
    (String? val) {
      if (!Validators.isValidEmail(val!)) {
        return 'Enter a valid email';
      }
      return null;
    }
  ],
);
final _password = RM.injectTextEditing(
  validators: [
    (String? val) {
      if (!Validators.isValidPassword(val!)) {
        return 'Enter a valid password';
      }
      return null;
    }
  ],
  validateOnTyping: true,
);

final _confirmationPassword = RM.injectTextEditing(
  validators: [
    (String? val) {
      if (_password.text != val) {
        return 'Passwords do not match';
      }
      return null;
    }
  ],
  validateOnTyping: true,
);

final _form = RM.injectForm();

class SignInRegisterFormPage extends StatelessWidget {
  const SignInRegisterFormPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormWidget(),
      ),
    );
  }
}

class FormWidget extends StatelessWidget {
  final _isRegister = false.inj();

  FormWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnFormBuilder(
      listenTo: _form,
      builder: () {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _email.controller,
              focusNode: _email.focusNode,
              decoration: InputDecoration(
                icon: const Icon(Icons.email),
                labelText: 'Email',
                errorText: _email.error,
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onSubmitted: (_) {
                _password.focusNode.requestFocus();
              },
            ),
            TextField(
              controller: _password.controller,
              focusNode: _password.focusNode,
              decoration: InputDecoration(
                icon: const Icon(Icons.lock),
                labelText: 'Password',
                errorText: _password.error,
              ),
              obscureText: true,
              autocorrect: false,
              onSubmitted: (_) {
                if (_isRegister.state) {
                  _confirmationPassword.focusNode.requestFocus();
                } else {
                  _form.submitFocusNode.requestFocus();
                }
              },
            ),
            OnBuilder(
              listenTo: _isRegister,
              builder: () => Column(
                children: [
                  _isRegister.state
                      ? TextField(
                          controller: _confirmationPassword.controller,
                          focusNode: _confirmationPassword.focusNode,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            labelText: 'Confirm Password',
                            errorText: _confirmationPassword.error,
                          ),
                          obscureText: true,
                          autocorrect: false,
                          onSubmitted: (_) {
                            _form.submitFocusNode.requestFocus();
                          },
                        )
                      : Container(),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _isRegister.state,
                        onChanged: (value) {
                          _isRegister.state = value!;
                        },
                      ),
                      const Text(' I do not have an account')
                    ],
                  ),
                  OnFormSubmissionBuilder(
                    listenTo: _form,
                    onSubmitting: () =>
                        const Center(child: CircularProgressIndicator()),
                    child: ElevatedButton(
                      focusNode: _form.submitFocusNode,
                      child: _isRegister.state
                          ? const Text('Register')
                          : const Text('Sign in'),
                      onPressed: () {
                        _form.submit(
                          () async {
                            if (_isRegister.state) {
                              await authBloc.register(
                                AuthParam(
                                  signUp: SignUp.withEmailAndPassword,
                                  email: _email.value,
                                  password: _password.value,
                                ),
                              );
                            } else {
                              await authBloc.login(
                                AuthParam(
                                  signIn: SignIn.withEmailAndPassword,
                                  email: _email.value,
                                  password: _password.value,
                                ),
                              );
                              //Server validation
                              if (authBloc.error is EmailException) {
                                _email.error = authBloc.error.message;
                              }
                              if (authBloc.error is PasswordException) {
                                _password.error = authBloc.error.message;
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
