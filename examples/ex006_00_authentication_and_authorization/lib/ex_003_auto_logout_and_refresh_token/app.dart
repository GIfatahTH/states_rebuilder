import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'blocs/auth_bloc.dart';
import 'data_source/hive_storage.dart';
import 'ui/auth_page/auth_page.dart';
import 'ui/home_page/home_page.dart';
import 'ui/widgets/splash_screen.dart';

main() {
  runApp(const MyApp());
}

class MyApp extends TopStatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  List<Future<void>>? ensureInitialization() {
    return [
      RM.storageInitializer(HiveStorage()),
    ];
  }

  @override
  Widget? splashScreen() {
    return const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OnAuthBuilder(
        listenTo: authBloc(),
        onInitialWaiting: () => const SplashScreen(),
        onUnsigned: () => const AuthPage(),
        onSigned: () => const HomePage(),
        navigatorKey: RM.navigate.navigatorKey,
      ),
      navigatorKey: RM.navigate.navigatorKey,
    );
  }
}
