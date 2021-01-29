import 'package:clean_architecture_firebase_login/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../service/apple_sign_in_checker_service.dart';
import '../../../service/user_extension.dart';
import '../sign_in_register_form_page/sign_in_register_form_page.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log in')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: user.listen(
          child: On(
            () {
              bool isLoading = user.isWaiting;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      child: isLoading
                          ? CircularProgressIndicator()
                          : Text(
                              'Sign In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                      height: 40.0,
                    ),
                  ),
                  SizedBox(height: 32),
                  //NOTE2: IF can log with apple
                  if (appleSignInCheckerService.state.canSignInWithApple) ...[
                    RaisedButton(
                      child: Text('Sign in With Apple Account'),
                      onPressed: isLoading
                          ? null
                          : () => user.auth.signIn(
                                () => UserParam(signIn: SignIn.withApple),
                              ),
                    ),
                    SizedBox(height: 8),
                  ],
                  RaisedButton(
                    child: Text('Sign in With Google Account'),
                    onPressed: isLoading
                        ? null
                        : () => user.auth.signIn(
                              () => UserParam(signIn: SignIn.withGoogle),
                            ),
                  ),
                  SizedBox(height: 8),
                  RaisedButton(
                    child: Text('Sign in With Email and password'),
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  //Display form screen
                                  return SignInRegisterFormPage();
                                },
                              ),
                            );
                          },
                  ),
                  SizedBox(height: 8),
                  RaisedButton(
                    child: Text('Sign in anonymously'),
                    onPressed: isLoading
                        ? null
                        : () => user.auth.signIn(
                              () => UserParam(signIn: SignIn.anonymously),
                            ),
                  ),
                  SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
