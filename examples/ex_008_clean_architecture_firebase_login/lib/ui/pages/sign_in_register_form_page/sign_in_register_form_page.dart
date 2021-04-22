import 'package:clean_architecture_firebase_login/domain/common/validator.dart';
import 'package:clean_architecture_firebase_login/domain/exceptions/Validation_exception.dart';

import '../../../domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../injected.dart';
import '../../exceptions/exceptions_handler.dart';

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
  //NOTE1: Creating a  ReactiveModel key for email with empty initial value
  final _email = RM.inject<String>(
    () => '',
    middleSnapState: (middleSnap) {
      //
      if (middleSnap.nextSnap.hasData) {
        if (!Validators.isValidEmail(middleSnap.nextSnap.data)) {
          return middleSnap.nextSnap.copyToHasError(
            ValidationException('Enter a valid email'),
          );
        }
      }
      return middleSnap.nextSnap;
    },
  );

  //NOTE1: Creating a  ReactiveModel key for password with empty initial value
  final _password = RM.inject<String>(
    () => '',
    middleSnapState: (middleSnap) {
      //
      if (middleSnap.nextSnap.hasData) {
        if (!Validators.isValidPassword(middleSnap.nextSnap.data)) {
          return middleSnap.nextSnap.copyToHasError(
            ValidationException('Enter a valid password'),
          );
        }
      }
      return middleSnap.nextSnap;
    },
  );
  //NOTE1: Creating a  ReactiveModel key for isRegister with false initial value
  final _isRegister = false.inj();
  //NOTE1: bool getter to check if the form is valid
  bool get _isFormValid => _email.hasData && _password.hasData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        On(
          () => TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.email),
              labelText: 'Email',
              //NOTE4: Delegate to ExceptionsHandler.errorMessage for error handling
              errorText: ExceptionsHandler.errorMessage(_email.error).message,
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onChanged: (email) {
              //NOTE5: set the state of email and notify observers
              _email.state = email;
            },
          ),
        ).listenTo(_email),
        On(
          () => TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.lock),
              labelText: 'Password',
              errorText:
                  ExceptionsHandler.errorMessage(_password.error).message,
            ),
            obscureText: true,
            autocorrect: false,
            onChanged: (password) {
              _password.state = password;
            },
          ),
        ).listenTo(_password),
        SizedBox(height: 10),
        On(
          () => Row(
            children: <Widget>[
              Checkbox(
                value: _isRegister.state,
                onChanged: (value) {
                  _isRegister.state = value;
                },
              ),
              Text(' I do not have an account')
            ],
          ),
        ).listenTo(_isRegister),
        OnCombined(
          (_) {
            if (user.isWaiting) {
              return Center(child: CircularProgressIndicator());
            }
            return RaisedButton(
                //NOTE8: toggle the button text between 'Register' and 'Sign in' depending on the checkbox value
                child: _isRegister.state ? Text('Register') : Text('Sign in'),
                //NOTE8: activate/deactivate the button if the form is valid/non valid
                onPressed: _isFormValid
                    ? () async {
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
                        }
                      }
                    : null);
          },
        ).listenTo([_email, _password, _isRegister, user]),
        On(
          () {
            // Display an error message telling the user what goes wrong.
            if (user.hasError) {
              return Center(
                child: Text(
                  ExceptionsHandler.errorMessage(user.error).message,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return Text('');
          },
        ).listenTo(user),
      ],
    );
  }
}
