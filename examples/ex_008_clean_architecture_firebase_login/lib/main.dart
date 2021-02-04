import 'domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'service/apple_sign_in_checker_service.dart';
import 'service/user_extension.dart';

import 'ui/widgets/splash_screen.dart';

main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TopWidget(
      waiteFor: () => [
        canSignInWithApple.stateAsync,
      ],
      onWaiting: () => MaterialApp(
        home: SplashScreen(),
      ),
      builder: (_) => MaterialApp(
        home: user.futureBuilder(
          future: (_, __) => user.auth.signIn(
            (_) => UserParam(signIn: SignIn.currentUser),
          ),
          onWaiting: () => SplashScreen(),
          onError: (error) => Text(error.toString()),
          onData: (_) => SplashScreen(),
        ),
        navigatorKey: RM.navigate.navigatorKey,
      ),
    );
  }
}
