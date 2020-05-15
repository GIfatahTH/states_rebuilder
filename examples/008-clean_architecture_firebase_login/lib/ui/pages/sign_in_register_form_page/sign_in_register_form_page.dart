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
  //NOTE1: Creating a  ReactiveModel key for email with empty initial value
  final _emailRM = RMKey('');
  //NOTE1: Creating a  ReactiveModel key for password with empty initial value
  final _passwordRM = RMKey('');
  //NOTE1: Creating a  ReactiveModel key for isRegister with false initial value
  final _isRegisterRM = RMKey(false);
  //NOTE1: bool getter to check if the form is valid
  bool get _isFormValid => _emailRM.hasData && _passwordRM.hasData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StateBuilder(
          //NOTE2: create and subscribe to local ReactiveModel of empty string
          observe: () => RM.create(''),
          //NOTE3: couple this StateBuilder with the email ReactiveModel key
          rmKey: _emailRM,
          builder: (_, __) {
            return TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
                //NOTE4: Delegate to ExceptionsHandler.errorMessage for error handling
                errorText:
                    ExceptionsHandler.errorMessage(_emailRM.error).message,
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onChanged: (email) {
                //NOTE5: set the state of email and notify observers
                _emailRM.setState(
                  (_) => Email(email).value,
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
                _passwordRM.setState(
                  (_) => Password(password).value,
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
                    value: _isRegisterRM.state,
                    onChanged: (value) {
                      _isRegisterRM.setState((_) => value);
                    },
                  ),
                  Text(' I do not have an account')
                ],
              );
            }),
        StateBuilder<UserService>(
            //NOTE6: subscribe to all the ReactiveModels
            //_emailRM, _passwordRM: to activate/deactivate the button if the form is valid/non valid
            //_isRegisterRM: to toggle the button text between Register and sing in depending on the checkbox value
            //userServiceRM: To show CircularProgressIndicator is the state is waiting
            observeMany: [
              () => _emailRM,
              () => _passwordRM,
              () => _isRegisterRM,
              () => RM.get<UserService>().asNew('signInRegisterForm'),
            ],
            //NOTE7: show CircularProgressIndicator is the userServiceRM state is waiting
            builder: (_, userServiceRM) {
              if (userServiceRM.isWaiting) {
                return Center(child: CircularProgressIndicator());
              }
              return RaisedButton(
                  //NOTE8: toggle the button text between 'Register' and 'Sign in' depending on the checkbox value
                  child:
                      _isRegisterRM.state ? Text('Register') : Text('Sign in'),
                  //NOTE8: activate/deactivate the button if the form is valid/non valid
                  onPressed: _isFormValid
                      ? () {
                          userServiceRM.setState(
                            (s) async {
                              //NOTE9: If _isRegisterRM.state is true call createUserWithEmailAndPassword,
                              if (_isRegisterRM.state) {
                                return s.createUserWithEmailAndPassword(
                                  _emailRM.state,
                                  _passwordRM.state,
                                );
                              } else {
                                //NOTE9: If _isRegisterRM.state is true call signInWithEmailAndPassword,
                                return s.signInWithEmailAndPassword(
                                  _emailRM.state,
                                  _passwordRM.state,
                                );
                              }
                            },
                            //we want to notify the local new ReactiveModel created bellow
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
          //we created a local new ReactiveModel form the global registered ReactiveModel
          observe: () => RM.get<UserService>().asNew('signInRegisterForm'),
          builder: (_, userServiceRM) {
            //NOTE10: Display an error message telling the user what goes wrong.
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
