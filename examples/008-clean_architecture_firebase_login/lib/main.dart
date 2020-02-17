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
    Injector(
      inject: [
        Inject(() => AppSignInCheckerService(AppleSignInChecker())),
        Inject(() => UserService(userRepository: UserRepository()))
      ],
      builder: (context) {
        return MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  final userServiceRM = Injector.getAsReactive<UserService>();
  final appleCheckerRM = Injector.getAsReactive<AppSignInCheckerService>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WhenRebuilder<UserService>(
        models: [userServiceRM.asNew('main_widget'), appleCheckerRM],
        initState: (_, userServiceRM) {
          appleCheckerRM.setState((s) => s.check());
          userServiceRM.setState((s) => s.currentUser());
        },
        onWaiting: () => SplashScreen(),
        onError: (error) => Text(error.toString()),
        onData: (_) {
          return StateBuilder(
            models: [userServiceRM],
            builder: (_, __) {
              return userServiceRM.state.user == null
                  ? SignInPage()
                  : HomePage();
            },
          );
        },
      ),
    );
  }
}
