import 'domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'service/apple_sign_in_checker_service.dart';
import 'service/user_extension.dart';

import 'ui/widgets/splash_screen.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: user.futureBuilder(
        future: (s, _) async {
          appleSignInCheckerService.state.check();
          return user.auth.signIn(
            (_) => UserParam(signIn: SignIn.currentUser),
          );
        },
        onWaiting: () => SplashScreen(),
        onError: (error) => Text(error.toString()),
        onData: (_) => Container(),
      ),
      navigatorKey: RM.navigate.navigatorKey,
    );

    // return user.listen(
    //   child: On.data(
    //     () => user.state is UnLoggedUser ? SignInPage() : HomePage(),
    //   ),
    // ),);
  }
}
