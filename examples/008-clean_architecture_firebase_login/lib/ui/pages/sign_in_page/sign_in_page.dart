import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../service/apple_sign_in_checker_service.dart';
import '../../../service/user_service.dart';
import '../../exceptions/exceptions_handler.dart';
import '../sign_in_register_form_page/sign_in_register_form_page.dart';

class SignInPage extends StatelessWidget {
  //NOTE1: Getting the bool canSignInWithApple value
  final bool canSignInWithApple =
      Injector.get<AppSignInCheckerService>().canSignInWithApple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log in')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Builder(builder: (context) {
          //Using the BuildContext to subscribe is deprecated (removed since v 2.0.0)
          //NOTE1: Getting the Singleton ReactiveModel of UserService and subscribe it with the BuildContext
          // final userServiceRM = RM.get<UserService>(context: context);
          //NOTE1: helper getter
          return StateBuilder<UserService>(
              observe: () => RM.get<UserService>(),
              builder: (context, userServiceRM) {
                bool isLoading = userServiceRM.isWaiting;
                // print('signin page rebuild');
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        //NOTE1: Display the CircularProgressIndicator while signing in
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Text(
                                'Sign In',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30),
                              ),
                        height: 40.0,
                      ),
                    ),
                    SizedBox(height: 32),
                    //NOTE2: IF can log with apple
                    if (canSignInWithApple) ...[
                      RaisedButton(
                        child: Text('Sign in With Apple Account'),
                        onPressed: isLoading
                            ? null
                            : () => userServiceRM.setState(
                                  (s) => s.signInWithApple(),
                                  onError: ExceptionsHandler.showErrorDialog,
                                ),
                      ),
                      SizedBox(height: 8),
                    ],
                    RaisedButton(
                      child: Text('Sign in With Google Account'),
                      onPressed: isLoading
                          ? null
                          : () => userServiceRM.setState(
                                (s) => s.signInWithGoogle(),
                                onError: ExceptionsHandler.showErrorDialog,
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
                          : () => userServiceRM
                                  .setState((s) => s.signInAnonymously(),
                                      onError: (context, error) {
                                // print('error');
                                ExceptionsHandler.showErrorDialog(
                                    context, error);
                              }),
                    ),
                    SizedBox(height: 8),
                  ],
                );
              });
        }),
      ),
    );
  }
}
