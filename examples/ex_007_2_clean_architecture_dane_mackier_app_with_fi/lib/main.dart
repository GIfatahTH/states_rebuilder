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
      onGenerateRoute: route.Router.generateRoute,
      //As we will use states_rebuilder navigator
      //we assign its key to the navigator key
      navigatorKey: RM.navigate.navigatorKey,
    );
  }
}


/*
//As userInj is not autodisposed, you have to dispose it manually
//One of the method is to autoDispose all non disposed state is
//To wrap the MaterialApp widget with TopWidget

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TopWidget(
      didChangeAppLifecycleState: (state) {
        // app state life
      },
      didChangeLocales: (locales) {
        // system locales
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(),
        onGenerateRoute: route.Router.generateRoute,
        navigatorKey: RM.navigate.navigatorKey,
      ),
    );
  }
}
*/
