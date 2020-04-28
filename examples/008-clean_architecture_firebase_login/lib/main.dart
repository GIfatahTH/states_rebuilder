import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/user_repository.dart';
import 'infrastructure/apple_sign_in_available.dart';
import 'service/apple_sign_in_checker_service.dart';
import 'service/user_service.dart';
import 'ui/pages/home_page/home_page.dart';
import 'ui/pages/sign_in_page/sign_in_page.dart';
import 'ui/widgets/splash_screen.dart';

main() {
  runApp(
    MaterialApp(
      home: Injector(
        inject: [
          Inject(() => AppSignInCheckerService(AppleSignInChecker())),
          Inject(() => UserService(userRepository: UserRepository()))
        ],
        builder: (context) {
          return MyApp();
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RM.printActiveRM = true;
    return WhenRebuilder(
      observeMany: [
        () => RM.future(IN.get<UserService>().currentUser()),
        () => RM.future(IN.get<AppSignInCheckerService>().check())
      ],
      onIdle: () => Container(),
      onWaiting: () => SplashScreen(),
      onError: (error) => Text(error.toString()),
      onData: (_) {
        return StateBuilder(
          observe: () => RM.get<UserService>(),
          watch: (userServiceRM) => userServiceRM.state.user,
          builder: (_, userServiceRM) {
            return userServiceRM.state.user == null ? SignInPage() : HomePage();
          },
        );
      },
    );
  }
}
