import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../service/apple_sign_in_checker_service.dart';
import '../../../service/user_service.dart';
import '../../exceptions/exceptions_handler.dart';
import '../sign_in_register_form_page/sign_in_register_form_page.dart';

class SignInPage extends StatelessWidget {
  final bool canSignInWithApple =
      Injector.get<AppSignInCheckerService>().canSignInWithApple;
  final userServiceRM = Injector.getAsReactive<UserService>();
  bool get isLoading => userServiceRM.isWaiting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log in')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
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
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                height: 40.0,
              ),
            ),
            SizedBox(height: 32),
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
                  : () => userServiceRM.setState(
                        (s) => s.signInAnonymously(),
                        onError: ExceptionsHandler.showErrorDialog,
                      ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
