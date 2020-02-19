import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/api.dart';
import 'service/authentication_service.dart';
import 'service/interfaces/i_api.dart';
import 'ui/router.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
        inject: [
          //NOTE1 : The order doesn't matter.
          //NOTE2: // Register with interface.
          Inject<IApi>(() => Api()),
          //NOTE3: Type is optional here because it is inferred
          Inject(() => AuthenticationService(api: Injector.get())),
        ],
        builder: (context) => MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(),
              initialRoute: 'login',
              onGenerateRoute: Router.generateRoute,
            ));
  }
}
