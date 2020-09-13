import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todos_app_core/todos_app_core.dart';

import 'data_source/todo_repository.dart';
import 'localization.dart';
import 'service/auth_state.dart';
import 'service/common/enums.dart';
import 'service/todos_state.dart';
import 'ui/exceptions/error_handler.dart';
import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/auth_page/auth_page.dart';
import 'ui/pages/home_screen/home_screen.dart';

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    ////uncomment the following line to consol log Widget rebuild
    //RM.debugWidgetsRebuild
    ////uncomment this line to consol log and see the notification timeline
    // RM.debugPrintActiveRM = true;

    //
    //Injecting the TodosState globally before MaterialApp widget.
    //It will be available throughout all the widget tree even after navigation.
    //The initial state is an empty todos and VisibilityFilter.all
    return Injector(
      inject: [
        Inject(
          () => TodosState(
            todos: [],
            activeFilter: VisibilityFilter.all,
            todoRepository: TodosRepository(
              user: IN.get<AuthState>().user,
            ),
          ),
        )
      ],
      builder: (_) => MaterialApp(
        title: StatesRebuilderLocalizations().appTitle,
        theme: ArchSampleTheme.theme,
        localizationsDelegates: [
          ArchSampleLocalizationsDelegate(),
          StatesRebuilderLocalizationsDelegate(),
        ],
        home: StateBuilder<AuthState>(
          key: Key('Current user'),
          watch: (rm) => rm.state.user,
          observe: () => RM.get<AuthState>()
            ..setState(
              (authState) => AuthState.currentUser(authState),
              onError: ErrorHandler.showErrorDialog,
            ),
          builder: (context, authStateRM) => authStateRM.state is InitAuthState
              ? const AuthScreen()
              : HomeScreen(),
        ),
        routes: {
          ArchSampleRoutes.addTodo: (context) => AddEditPage(),
        },
        navigatorKey: RM.navigate.navigatorKey,
      ),
    );
  }
}

class ArchSampleRoutes {
  static final home = '/home';
  static final addTodo = '/addTodo';
}
