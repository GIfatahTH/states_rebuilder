import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'injected.dart';
import 'localization.dart';
import 'service/auth_state.dart';
import 'ui/exceptions/error_handler.dart';
import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/auth_page/auth_page.dart';
import 'ui/pages/home_screen/home_screen.dart';
import 'package:todos_app_core/todos_app_core.dart';

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: StatesRebuilderLocalizations().appTitle,
      theme: ArchSampleTheme.theme,
      localizationsDelegates: [
        ArchSampleLocalizationsDelegate(),
        StatesRebuilderLocalizationsDelegate(),
      ],
      home: authState.whenRebuilderOr(
        initState: () => authState.setState(
          (currentState) => AuthState.currentUser(currentState),
          onError: ErrorHandler.showErrorDialog,
        ),
        onWaiting: () => const Center(
          child: const CircularProgressIndicator(
            key: ArchSampleKeys.todosLoading,
          ),
        ),
        builder: () => authState.state is InitAuthState
            ? const AuthScreen()
            : HomeScreen(),
      ),
      routes: {
        ArchSampleRoutes.addTodo: (context) => AddEditPage(),
      },
      navigatorKey: RM.navigate.navigatorKey,
    );
  }
}

class ArchSampleRoutes {
  static final home = '/home';
  static final addTodo = '/addTodo';
}
