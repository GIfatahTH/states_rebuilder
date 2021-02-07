import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'domain/entities/user.dart';

import 'injected.dart';
import 'ui/pages/home_page/home_page.dart';
import 'ui/pages/sign_in_page/sign_in_page.dart';
import 'ui/widgets/splash_screen.dart';

main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TopAppWidget(
      waiteFor: () => [
        canSignInWithApple.stateAsync,
      ],
      onWaiting: () => MaterialApp(
        home: SplashScreen(),
      ),
      injectedAuth: user,
      builder: (_) => MaterialApp(
        home: user.futureBuilder(
          future: (s, _) => user.auth.signIn(
            (param) => UserParam(signIn: SignIn.currentUser),
          ),
          onWaiting: () => SplashScreen(),
          onError: (_) => Text('Error'),
          onData: (_) {
            return user.isSigned ? HomePage() : SignInPage();
          },
        ),
        navigatorKey: RM.navigate.navigatorKey,
      ),
    );
  }
}
