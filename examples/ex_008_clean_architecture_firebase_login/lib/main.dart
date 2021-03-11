import 'package:clean_architecture_firebase_login/ui/pages/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'injected.dart';
import 'ui/pages/sign_in_page/sign_in_page.dart';
import 'ui/widgets/splash_screen.dart';

main() async {
  RM.navigate.transitionsBuilder = RM.transitions.leftToRight();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TopAppWidget(
      waiteFor: () => [
        //Here we initialize all plugins
        canSignInWithApple.stateAsync,
      ],
      onWaiting: () => MaterialApp(
        home: SplashScreen(),
      ),
      builder: (_) => MaterialApp(
        home: On.auth(
          onInitialWaiting: () => SplashScreen(),
          onUnsigned: () => SignInPage(),
          onSigned: () => HomePage(),
        ).listenTo(
          user,
          useRouteNavigation: true,
        ),
        navigatorKey: RM.navigate.navigatorKey,
      ),
    );
  }
}
