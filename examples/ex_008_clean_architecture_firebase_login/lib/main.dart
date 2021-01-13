import 'package:clean_architecture_firebase_login/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'service/apple_sign_in_checker_service.dart';
import 'service/user_extension.dart';
import 'ui/pages/home_page/home_page.dart';
import 'ui/pages/sign_in_page/sign_in_page.dart';
import 'ui/widgets/splash_screen.dart';

main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return user.futureBuilder(
      future: (s, asyncS) async {
        await appleSignInCheckerService.state.check();
        return s.currentUser();
      },
      onWaiting: () => SplashScreen(),
      onError: (error) => Text(error.toString()),
      onData: (_) {
        return user.listen(
          child: On.data(
            () => user.state is UnLoggedUser ? SignInPage() : HomePage(),
          ),
          watch: () => user.state,
        );
      },
    );
  }
}
