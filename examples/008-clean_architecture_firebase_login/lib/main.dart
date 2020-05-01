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
          //NOTE1: Injecting the apple_sign_in plugging
          Inject(() => AppSignInCheckerService(AppleSignInChecker())),
          //NOTE1: Injecting the UserService class
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
    //Note2: this is use for debug.
    //It prints on the console log the active ReactiveModel that is emitting the notification
    RM.printActiveRM = true;
    return WhenRebuilder(
      //Note3: use the observeMany instead of observe parameter to subscribe to many ReactiveModels
      observeMany: [
        //Note3: Create a local ReactiveModel of type future form currentUser() method of the registered instance of UserService
        () => RM.future(IN.get<UserService>().currentUser()),
        //Note3: Create a local ReactiveModel of type future form check() method of the registered instance of AppSignInCheckerService
        () => RM.future(IN.get<AppSignInCheckerService>().check())
      ],
      onIdle: () => Container(),
      //NOTE4: If any of appleCheckerRM or userServiceRM is in the waiting state show a SplashScreen
      onWaiting: () => SplashScreen(),
      //NOTE4: If any of appleCheckerRM or userServiceRM is has error, display it
      onError: (error) => Text(error.toString()),
      onData: (_) {
        return StateBuilder(
          //NOTE5: Subscribe to the reactiveModel global registered singleton
          observe: () => RM.get<UserService>(),
          //NOTE6: This StateBuilder will not rebuild unless the user changes
          watch: (userServiceRM) => userServiceRM.state.user,
          builder: (_, userServiceRM) {
            //NOTE6: depending of he user we are directed to SignInPage or HomePage
            return userServiceRM.state.user == null ? SignInPage() : HomePage();
          },
        );
      },
    );
  }
}
