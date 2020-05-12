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
  @override
  Widget build(BuildContext context) {
    RM.debugPrintActiveRM = false;
    RM.debugWidgetsRebuild = true;
    ////uncomment the following line to consol log Widget rebuild
    //RM.debugWidgetsRebuild
    ////uncomment this line to consol log and see the notification timeline
    //RM.printActiveRM = true;

    //
    //Injecting the TodosState globally before MaterialApp widget.
    //It will be available throughout all the widget tree even after navigation.
    //The initial state is an empty todos and VisibilityFilter.all
    return
        // Injector(
        //   inject: [
        //     Inject(
        //       () => TodosState(
        //         todos: [],
        //         activeFilter: VisibilityFilter.all,
        //         todoRepository: TodosRepository(
        //           user: IN.get<AuthState>().user,
        //         ),
        //       ),
        //     )
        //   ],
        //   reinjectOn: [RM.get<AuthState>()],
        //   builder: (_) =>

        MaterialApp(
      title: StatesRebuilderLocalizations().appTitle,
      theme: ArchSampleTheme.theme,
      localizationsDelegates: [
        ArchSampleLocalizationsDelegate(),
        StatesRebuilderLocalizationsDelegate(),
      ],
      home: StateBuilder<AuthState>(
          key: Key('Current user'),
          watch: (rm) => rm.value.user,
          observe: () => RM.get<AuthState>()
            ..future(
              (authState) => AuthState.currentUser(authState),
            ).onError(ErrorHandler.showErrorDialog),
          builder: (context, authStateRM) => Router()),
      routes: {
        ArchSampleRoutes.addTodo: (context) => AddEditPage(),
      },
      // ),
    );
  }
}

class Router extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RM.get<AuthState>().value is InitAuthState
        ? AuthScreen()
        : Injector(
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
            // reinjectOn: [
            //     RM.get<AuthState>()
            //   ],
            builder: (_) {
              return HomeScreen();
            });
  }
}

class ArchSampleRoutes {
  // static final auth = '/';
  static final home = '/home';
  static final addTodo = '/addTodo';
}
