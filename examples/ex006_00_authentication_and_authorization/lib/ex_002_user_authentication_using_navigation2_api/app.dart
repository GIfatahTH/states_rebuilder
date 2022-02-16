import 'package:states_rebuilder/scr/state_management/state_management.dart';

import 'blocs/auth_bloc.dart';
import 'navigator.dart';

import 'package:flutter/material.dart';

import 'ui/widgets/splash_screen.dart';

main() {
  runApp(const MyApp());
}

class MyApp extends TopStatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  List<Future<void>>? ensureInitialization() {
    return [authBloc.init()];
  }

  @override
  Widget? splashScreen() {
    return const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: navigator.routeInformationParser,
      routerDelegate: navigator.routerDelegate,
    );
  }
}
