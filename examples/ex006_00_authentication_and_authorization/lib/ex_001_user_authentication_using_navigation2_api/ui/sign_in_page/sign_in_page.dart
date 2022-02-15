import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../blocs/auth_bloc.dart';
import '../../models/user.dart';
import '../../navigator.dart';
import '../sign_in_register_form_page/sign_in_register_form_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: OnReactive(
          () {
            bool isLoading = authBloc.isWaiting;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: SizedBox(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                    height: 40.0,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  child: const Text('Sign in With Google Account'),
                  onPressed: isLoading
                      ? null
                      : () => authBloc.login(
                            AuthParam(signIn: SignIn.withGoogle),
                          ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  child: const Text('Sign in With Email and password'),
                  onPressed: isLoading
                      ? null
                      : () {
                          navigator.toPageless(
                            const SignInRegisterFormPage(),
                            fullscreenDialog: true,
                          );
                        },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  child: const Text('Sign in anonymously'),
                  onPressed: isLoading
                      ? null
                      : () => authBloc.login(
                            AuthParam(signIn: SignIn.anonymously),
                          ),
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }
}
