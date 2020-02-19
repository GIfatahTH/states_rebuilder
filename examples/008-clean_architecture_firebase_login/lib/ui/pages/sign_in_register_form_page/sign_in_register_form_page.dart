import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/password.dart';
import '../../../service/user_service.dart';
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

class FormWidget extends StatefulWidget {
  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final userServiceRM =
      Injector.getAsReactive<UserService>().asNew('formWidget');

  final _emailRM = ReactiveModel.create('');

  final _passwordRM = ReactiveModel.create('');

  final _isRegisterRM = ReactiveModel.create(false);

  bool get _isFormValid => _passwordRM.hasData && _passwordRM.hasData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StateBuilder(
          models: [_emailRM],
          builder: (_, __) {
            return TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
                errorText:
                    ExceptionsHandler.errorMessage(_emailRM.error).message,
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onChanged: (email) {
                _emailRM.setValue(
                  () => Email(email).value,
                  catchError: true,
                );
              },
            );
          },
        ),
        StateBuilder(
          models: [_passwordRM],
          builder: (_, __) {
            return TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'Password',
                errorText:
                    ExceptionsHandler.errorMessage(_passwordRM.error).message,
              ),
              obscureText: true,
              autocorrect: false,
              onChanged: (password) {
                _passwordRM.setValue(
                  () => Password(password).value,
                  catchError: true,
                );
              },
            );
          },
        ),
        SizedBox(height: 10),
        StateBuilder(
            models: [_isRegisterRM],
            builder: (_, __) {
              return Row(
                children: <Widget>[
                  Checkbox(
                    value: _isRegisterRM.value,
                    onChanged: (value) {
                      _isRegisterRM.setValue(() => value);
                    },
                  ),
                  Text(' I do not have an account')
                ],
              );
            }),
        StateBuilder(
          models: [_emailRM, _passwordRM, _isRegisterRM, userServiceRM],
          builder: (_, __) {
            if (userServiceRM.isWaiting) {
              return Center(child: CircularProgressIndicator());
            }
            return RaisedButton(
              child: _isRegisterRM.value ? Text('Register') : Text('Sign in'),
              onPressed: _isFormValid
                  ? () {
                      if (_isRegisterRM.value) {
                        userServiceRM.setState(
                          (s) => s.createUserWithEmailAndPassword(
                            _emailRM.value,
                            _passwordRM.value,
                          ),
                          onData: (_, __) {
                            Navigator.pop(context);
                          },
                          catchError: true,
                          joinSingleton: true,
                        );
                      } else {
                        userServiceRM.setState(
                          (s) => s.signInWithEmailAndPassword(
                            _emailRM.value,
                            _passwordRM.value,
                          ),
                          onData: (_, __) => Navigator.pop(context),
                          catchError: true,
                        );
                      }
                    }
                  : null,
            );
          },
        ),
        StateBuilder(
          models: [userServiceRM],
          builder: (_, __) {
            if (userServiceRM.hasError) {
              return Center(
                child: Text(
                  ExceptionsHandler.errorMessage(userServiceRM.error).message,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return Text('');
          },
        ),
      ],
    );
  }
}
