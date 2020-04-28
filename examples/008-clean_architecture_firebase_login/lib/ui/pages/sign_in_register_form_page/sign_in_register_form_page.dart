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

class FormWidget extends StatelessWidget {
  final _emailRM = RMKey('');
  final _passwordRM = RMKey('');
  final _isRegisterRM = RMKey(false);
  bool get _isFormValid => _emailRM.hasData && _passwordRM.hasData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StateBuilder(
          observe: () => RM.create(''),
          rmKey: _emailRM,
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
          observe: () => RM.create(''),
          rmKey: _passwordRM,
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
            observe: () => RM.create(false),
            rmKey: _isRegisterRM,
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
        StateBuilder<UserService>(
            observeMany: [
              () => _emailRM,
              () => _passwordRM,
              () => _isRegisterRM,
              () => RM.get<UserService>().asNew('signInRegisterForm'),
            ],
            builder: (_, userServiceRM) {
              if (userServiceRM.isWaiting) {
                return Center(child: CircularProgressIndicator());
              }
              return RaisedButton(
                  child:
                      _isRegisterRM.value ? Text('Register') : Text('Sign in'),
                  onPressed: _isFormValid
                      ? () {
                          userServiceRM.setState(
                            (s) async {
                              if (_isRegisterRM.value) {
                                return s.createUserWithEmailAndPassword(
                                  _emailRM.value,
                                  _passwordRM.value,
                                );
                              } else {
                                return s.signInWithEmailAndPassword(
                                  _emailRM.value,
                                  _passwordRM.value,
                                );
                              }
                            },
                            notifyAllReactiveInstances: true,
                            onData: (_, __) {
                              Navigator.pop(context);
                            },
                            catchError: true,
                          );
                        }
                      : null);
            }),
        StateBuilder<UserService>(
          models: [RM.get<UserService>().asNew('signInRegisterForm')],
          builder: (_, userServiceRM) {
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
