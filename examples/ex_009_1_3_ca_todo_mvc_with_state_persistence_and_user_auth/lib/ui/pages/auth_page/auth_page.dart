import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/value_object/email.dart';
import '../../../domain/value_object/password.dart';
import '../../../injected.dart';
import '../../../ui/exceptions/error_handler.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key key}) : super(key: key);
  static final routeName = '/AuthPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: AuthFormWidget(),
      ),
    );
  }
}

class AuthFormWidget extends StatelessWidget {
  final _email = RM.inject(() => '');
  final _password = RM.inject(() => '');
  final _isRegister = RM.inject(() => false);

  bool get _isFormValid => _email.hasData && _password.hasData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _email.whenRebuilderOr(
          builder: () => TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.email),
              labelText: 'Email',
              errorText: ErrorHandler.getErrorMessage(_email.error),
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onChanged: (email) {
              _email.setState(
                (_) => Email(email).value,
                catchError: true,
              );
            },
          ),
        ),
        _password.whenRebuilderOr(
          builder: () => TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.lock),
              labelText: 'Password',
              errorText: ErrorHandler.getErrorMessage(_password.error),
            ),
            obscureText: true,
            autocorrect: false,
            onChanged: (password) {
              _password.setState(
                (_) => Password(password).value,
                catchError: true,
              );
            },
          ),
        ),
        SizedBox(height: 10),
        _isRegister.rebuilder(
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
        ),
        [_email, _password, _isRegister, user].whenRebuilderOr(
          builder: () {
            if (user.isWaiting) {
              return Center(child: CircularProgressIndicator());
            }
            return RaisedButton(
              child: _isRegister.state ? Text('Register') : Text('Sign in'),
              onPressed: _isFormValid
                  ? () {
                      user.setState(
                        (_) {
                          if (_isRegister.state) {
                            return authService.state.signUp(
                              _email.state,
                              _password.state,
                            );
                          } else {
                            return authService.state.login(
                              _email.state,
                              _password.state,
                            );
                          }
                        },
                        // onError: ErrorHandler.showErrorSnackBar,//TODO
                      );
                    }
                  : null,
            );
          },
        ),
      ],
    );
  }
}
