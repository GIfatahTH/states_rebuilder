import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/value_object/email.dart';
import '../../../domain/value_object/password.dart';
import '../../../injected.dart';
import '../../../service/auth_state.dart';
import '../../../ui/exceptions/error_handler.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key key}) : super(key: key);
  static final route = '/authPage';

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

final _email = RM.inject(() => '');
final _password = RM.inject(() => '');
final _isRegister = RM.inject(() => false);

bool get _isFormValid => _email.hasData && _password.hasData;

class AuthFormWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _email.rebuilder(
          () => TextField(
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
          key: Key('StateBuilder email'),
        ),
        _password.rebuilder(
          () => TextField(
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
          key: Key('StateBuilder password'),
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
          key: Key('StateBuilder _isRegister'),
        ),
        StateBuilder<AuthState>(
          key: Key('Sign in/up Button'),
          observeMany: [
            () => _email.getRM,
            () => _password.getRM,
            () => _isRegister.getRM,
            () => authState.getRM,
          ],
          builder: (_, authStateRM) {
            if (authStateRM.isWaiting) {
              return Center(child: CircularProgressIndicator());
            }
            return RaisedButton(
              child: _isRegister.state ? Text('Register') : Text('Sign in'),
              onPressed: _isFormValid
                  ? () {
                      authStateRM.setState(
                        (authState) {
                          if (_isRegister.state) {
                            return AuthState.createUserWithEmailAndPassword(
                              authState,
                              _email.state,
                              _password.state,
                            );
                          } else {
                            return AuthState.signInWithEmailAndPassword(
                              authState,
                              _email.state,
                              _password.state,
                            );
                          }
                        },
                        onError: ErrorHandler.showErrorSnackBar,
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
