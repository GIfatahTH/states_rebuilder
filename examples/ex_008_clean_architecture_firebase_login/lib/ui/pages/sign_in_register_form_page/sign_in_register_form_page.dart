import 'package:clean_architecture_firebase_login/service/exceptions/sign_in_out_exception.dart';

import '../../../domain/common/validator.dart';

import '../../../domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../injected.dart';

final _email = RM.injectTextEditing(
  validator: (String? val) {
    if (!Validators.isValidEmail(val!)) {
      return 'Enter a valid email';
    }
  },
);
final _password = RM.injectTextEditing(
  validator: (String? val) {
    if (!Validators.isValidPassword(val!)) {
      return 'Enter a valid password';
    }
  },
  validateOnTyping: true,
);

final _confirmationPassword = RM.injectTextEditing(
  validator: (String? val) {
    if (_password.text != val) {
      return 'Passwords do not match';
    }
  },
  validateOnTyping: true,
);

final _form = RM.injectForm();

class SignInRegisterFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormWidget(),
      ),
    );
  }
}

class FormWidget extends StatelessWidget {
  final _isRegister = false.inj();

  @override
  Widget build(BuildContext context) {
    return On.form(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _email.controller,
            focusNode: _email.focusNode,
            decoration: InputDecoration(
              icon: Icon(Icons.email),
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
              icon: Icon(Icons.lock),
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

          On(() => Column(
                children: [
                  _isRegister.state
                      ? TextField(
                          controller: _confirmationPassword.controller,
                          focusNode: _confirmationPassword.focusNode,
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock),
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
                      Text(' I do not have an account')
                    ],
                  ),
                  On.formSubmission(
                    onSubmitting: () =>
                        Center(child: CircularProgressIndicator()),
                    child: ElevatedButton(
                      focusNode: _form.submitFocusNode,
                      child: _isRegister.state
                          ? Text('Register')
                          : Text('Sign in'),
                      onPressed: () {
                        _form.submit(
                          () async {
                            if (_isRegister.state) {
                              await user.auth.signUp(
                                (_) => UserParam(
                                  signUp: SignUp.withEmailAndPassword,
                                  email: _email.state,
                                  password: _password.state,
                                ),
                              );
                            } else {
                              await user.auth.signIn(
                                (_) => UserParam(
                                  signIn: SignIn.withEmailAndPassword,
                                  email: _email.state,
                                  password: _password.state,
                                ),
                              );
                              //Server validation
                              if (user.error is EmailException) {
                                _email.error = user.error.message;
                              }
                              if (user.error is PasswordException) {
                                _password.error = user.error.message;
                              }
                            }
                          },
                        );
                      },
                    ),
                  ).listenTo(_form),
                ],
              )).listenTo(_isRegister),
          // On(
          //   () {
          //     // Display an error message telling the user what goes wrong.
          //     if (user.hasError) {
          //       return Center(
          //         child: Text(
          //           ExceptionsHandler.errorMessage(user.error).message!,
          //           style: TextStyle(color: Colors.red),
          //         ),
          //       );
          //     }
          //     return Text('');
          //   },
          // ).listenTo(user),
        ],
      ),
    ).listenTo(_form);
  }
}
