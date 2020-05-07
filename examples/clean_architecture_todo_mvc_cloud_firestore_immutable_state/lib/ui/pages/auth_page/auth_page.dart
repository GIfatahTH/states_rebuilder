import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/value_object/email.dart';
import '../../../domain/value_object/password.dart';
import '../../../service/auth_state.dart';
import '../../../ui/exceptions/error_handler.dart';

class AuthScreen extends StatelessWidget {
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
                errorText: ErrorHandler.getErrorMessage(_emailRM.error),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onChanged: (email) {
                //NOTE5: set the value of email and notify observers
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
                errorText: ErrorHandler.getErrorMessage(_passwordRM.error),
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
        StateBuilder<AuthState>(
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
              child: _isRegisterRM.value ? Text('Register') : Text('Sign in'),
              //NOTE8: activate/deactivate the button if the form is valid/non valid
              onPressed: _isFormValid
                  ? () {
                      authStateRM.future((authState) {
                        //NOTE9: If _isRegisterRM.value is true call createUserWithEmailAndPassword,
                        if (_isRegisterRM.value) {
                          return AuthState.createUserWithEmailAndPassword(
                            authState,
                            _emailRM.value,
                            _passwordRM.value,
                          );
                        } else {
                          //NOTE9: If _isRegisterRM.value is true call signInWithEmailAndPassword,
                          return AuthState.signInWithEmailAndPassword(
                            authState,
                            _emailRM.value,
                            _passwordRM.value,
                          );
                        }
                      }).onError(ErrorHandler.showErrorSnackBar);
                    }
                  : null,
            );
          },
        ),
        // StateBuilder<UserService>(
        //   //we created a local new ReactiveModel form the global registered ReactiveModel
        //   observe: () => RM.get<UserService>().asNew('signInRegisterForm'),
        //   builder: (_, userServiceRM) {
        //     //NOTE10: Display an error message telling the user what goes wrong.
        //     if (userServiceRM.hasError) {
        //       return Center(
        //         child: Text(
        //           ExceptionsHandler.errorMessage(userServiceRM.error).message,
        //           style: TextStyle(color: Colors.red),
        //         ),
        //       );
        //     }
        //     return Text('');
        //   },
        // ),
      ],
    );
  }
}
