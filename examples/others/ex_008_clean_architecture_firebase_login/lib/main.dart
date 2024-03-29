import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'injected.dart';
import 'ui/pages/home_page/home_page.dart';
import 'ui/pages/sign_in_page/sign_in_page.dart';
import 'ui/widgets/splash_screen.dart';

main() {
  RM.navigate.transitionsBuilder = RM.transitions.leftToRight();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TopAppWidget(
      ensureInitialization: () => [
        //Here we initialize all plugins
        canSignInWithApple.stateAsync,
      ],
      onWaiting: () => MaterialApp(
        home: SplashScreen(),
      ),
      builder: (_) => MaterialApp(
        home: OnAuthBuilder(
          listenTo: user,
          onInitialWaiting: () => SplashScreen(),
          onUnsigned: () => SignInPage(),
          onSigned: () => HomePage(),
          useRouteNavigation: true,
        ),
        navigatorKey: RM.navigate.navigatorKey,
      ),
    );
  }
}
