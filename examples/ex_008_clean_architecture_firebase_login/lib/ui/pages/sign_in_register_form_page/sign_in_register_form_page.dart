import 'package:clean_architecture_firebase_login/domain/entities/user.dart';
import 'package:clean_architecture_firebase_login/service/user_extension.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/password.dart';
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
  final _email = ''.inj();
  //NOTE1: Creating a  ReactiveModel key for password with empty initial value
  final _password = ''.inj();
  //NOTE1: Creating a  ReactiveModel key for isRegister with false initial value
  final _isRegister = true.inj();
  //NOTE1: bool getter to check if the form is valid
  bool get _isFormValid => _email.hasData && _password.hasData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _email.listen(
            child: On(
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
              _email.setState(
                (_) => Email(email).value,
                catchError: true,
              );
            },
          ),
        )),
        _password.listen(
          child: On(
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
                _password.setState(
                  (_) => Password(password).value,
                  catchError: true,
                );
              },
            ),
          ),
        ),
        SizedBox(height: 10),
        _isRegister.listen(
          child: On(
            () => Row(
              children: <Widget>[
                Checkbox(
                  value: _isRegister.state,
                  onChanged: (value) {
                    _isRegister.setState((_) => value);
                  },
                ),
                Text(' I do not have an account')
              ],
            ),
          ),
        ),
        [_email, _password, _isRegister, user].listen(
          child: OnCombined(
            (_)

            // StateBuilder<UserService>(
            //     //NOTE6: subscribe to all the ReactiveModels
            //     //_emailRM, _passwordRM: to activate/deactivate the button if the form is valid/non valid
            //     //_isRegisterRM: to toggle the button text between Register and sing in depending on the checkbox value
            //     //userServiceRM: To show CircularProgressIndicator is the state is waiting
            //     observeMany: [
            //       () => _emailRM,
            //       () => _passwordRM,
            //       () => _isRegisterRM,
            //       () => RM.get<UserService>().asNew('signInRegisterForm'),
            //     ],
            // shouldRebuild: (_) => true,
            //NOTE7: show CircularProgressIndicator is the userServiceRM state is waiting
            {
              if (user.isWaiting) {
                return Center(child: CircularProgressIndicator());
              }
              return RaisedButton(
                  //NOTE8: toggle the button text between 'Register' and 'Sign in' depending on the checkbox value
                  child: _isRegister.state ? Text('Register') : Text('Sign in'),
                  //NOTE8: activate/deactivate the button if the form is valid/non valid
                  onPressed: _isFormValid
                      ? () {
                          if (_isRegister.state) {
                            user.auth.signUp(
                              () => UserParam(
                                signUp: SignUp.withEmailAndPassword,
                                email: _email.state,
                                password: _password.state,
                              ),
                            );
                          } else {
                            user.auth.signIn(
                              () => UserParam(
                                signIn: SignIn.withEmailAndPassword,
                                email: _email.state,
                                password: _password.state,
                              ),
                            );
                          }
                          Navigator.pop(context);
                        }
                      : null);
            },
          ),
        ),
        // StateBuilder<UserService>(
        //   //we created a local new ReactiveModel form the global registered ReactiveModel
        //   observe: () => RM.get<UserService>().asNew('signInRegisterForm'),
        //   builder: (_, userServiceRM) {

        user.listen(
          child: On(
            () {
              //NOTE10: Display an error message telling the user what goes wrong.
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
          ),
        ),
      ],
    );
  }
}
