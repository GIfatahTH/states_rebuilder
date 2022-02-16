import 'blocs/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'common/global.dart';
import 'ui/home_page/home_page.dart';
import 'ui/sign_in_page/sign_in_page.dart';
import 'ui/widgets/splash_screen.dart';

main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OnAuthBuilder(
        listenTo: authBloc(),
        onInitialWaiting: () => const SplashScreen(),
        onUnsigned: () => const SignInPage(),
        onSigned: () => const HomePage(),
        navigatorKey: navigationKey,
        // If you want to use the build in navigatorKey
        // navigatorKey: RM.navigate.navigatorKey,
      ),
      navigatorKey: navigationKey,
      // navigatorKey: RM.navigate.navigatorKey,
    );
  }
}
