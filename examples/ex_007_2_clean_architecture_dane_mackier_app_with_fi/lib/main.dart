import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'ui/router.dart' as route;

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      initialRoute: 'login',
      onGenerateRoute: route.Router.generateRoute,
      navigatorKey: RM.navigate.navigatorKey,
    );
  }
}
