import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/service/todos_state.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/value_object/email.dart';
import '../../../domain/value_object/password.dart';
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

class AuthFormWidget extends StatelessWidget {
  // NOTE1: Creating a  ReactiveModel key for email with empty initial value

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
          key: Key('StateBuilder email'),
          //NOTE2: create and subscribe to local ReactiveModel of empty string
          observe: () => RM.create(''),
          //NOTE3: couple this StateBuilder with the email ReactiveModel key
          rmKey: _emailRM,
          builder: (_, _emailRM) {
            return TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
                //NOTE4: Delegate to ExceptionsHandler.errorMessage for error handling
                errorText: ErrorHandler.getErrorMessage(_emailRM.error),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onChanged: (email) {
                //NOTE5: set the value of email and notify observers
                _emailRM.setState(
                  (_) => Email(email).value,
                  catchError: true,
                );
              },
            );
          },
        ),
        StateBuilder(
          key: Key('StateBuilder password'),
          observe: () => RM.create(''),
          rmKey: _passwordRM,
          builder: (_, _passwordRM) {
            return TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'Password',
                errorText: ErrorHandler.getErrorMessage(_passwordRM.error),
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
            key: Key('StateBuilder checkBox'),
            observe: () => RM.create(false),
            rmKey: _isRegisterRM,
            builder: (_, __) {
              return Row(
                children: <Widget>[
                  Checkbox(
                    value: _isRegisterRM.state,
                    onChanged: (value) {
                      _isRegisterRM.state = value;
                    },
                  ),
                  Text(' I do not have an account')
                ],
              );
            }),
        StateBuilder<AuthState>(
          key: Key('Sign in/up Button'),
          //NOTE6: subscribe to all the ReactiveModels
          //_emailRM, _passwordRM: to activate/deactivate the button if the form is valid/non valid
          //_isRegisterRM: to toggle the button text between Register and sing in depending on the checkbox value
          //userServiceRM: To show CircularProgressIndicator is the state is waiting
          observeMany: [
            () => _emailRM,
            () => _passwordRM,
            () => _isRegisterRM,
            () => RM.get<AuthState>(),
          ],
          //NOTE7: show CircularProgressIndicator is the userServiceRM state is waiting
          builder: (_, authStateRM) {
            if (authStateRM.isWaiting) {
              return Center(child: CircularProgressIndicator());
            }
            return RaisedButton(
              //NOTE8: toggle the button text between 'Register' and 'Sign in' depending on the checkbox value
              child: _isRegisterRM.state ? Text('Register') : Text('Sign in'),
              //NOTE8: activate/deactivate the button if the form is valid/non valid
              onPressed: _isFormValid
                  ? () {
                      authStateRM.setState(
                        (authState) {
                          //NOTE9: If _isRegisterRM.state is true call createUserWithEmailAndPassword,
                          if (_isRegisterRM.state) {
                            return AuthState.createUserWithEmailAndPassword(
                              authState,
                              _emailRM.state,
                              _passwordRM.state,
                            );
                          } else {
                            //NOTE9: If _isRegisterRM.state is true call signInWithEmailAndPassword,
                            return AuthState.signInWithEmailAndPassword(
                              authState,
                              _emailRM.state,
                              _passwordRM.state,
                            );
                          }
                        },
                        //When ever a new user is logged in, the injected instance of
                        //TodosState will be refreshed to account for the new user.
                        onData: (context, authState) =>
                            RM.get<TodosState>().refresh(),
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
