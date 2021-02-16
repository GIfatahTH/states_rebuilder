import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../data_source/firebase_auth_repository.dart';
import '../../../domain/common/extensions.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/value_object/email.dart';
import '../../../domain/value_object/password.dart';
import '../../../ui/exceptions/error_handler.dart';
import '../home_screen/home_screen.dart';

part 'injected_user.dart';

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
  final _email = ''.inj();
  final _password = ''.inj();
  final _isRegister = false.inj();

  bool get _isFormValid => _email.hasData && _password.hasData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        On(
          () => TextField(
            key: Key('__EmailField__'),
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
              );
            },
          ),
        ).listenTo(_email),
        On(
          () => TextField(
            key: Key('__PasswordField__'),
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
              );
            },
          ),
        ).listenTo(_password),
        SizedBox(height: 10),
        On.data(
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
              child: _isRegister.state ? Text('Register') : Text('Sign in'),
              onPressed: _isFormValid
                  ? () {
                      if (_isRegister.state) {
                        return user.auth.signUp(
                          (_) => UserParam(
                            email: _email.state,
                            password: _password.state,
                          ),
                        );
                      } else {
                        return user.auth.signIn(
                          (_) => UserParam(
                            email: _email.state,
                            password: _password.state,
                          ),
                        );
                      }
                    }
                  : null,
            );
          },
        ).listenTo(
          [_email, _password, _isRegister, user],
        ),
      ],
    );
  }
}
