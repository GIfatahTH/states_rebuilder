import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todos_app_core/todos_app_core.dart';

import 'data_source/todo_repository.dart';
import 'localization.dart';
import 'service/interfaces/i_todo_repository.dart';
import 'service/todos_service.dart';
import 'ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'ui/pages/home_screen/home_screen.dart';

class StatesRebuilderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RM.debugPrintActiveRM = true;
    ////uncomment this line to consol log and see the notification timeline
    // RM.debugPrintActiveRM = true;
    //
    ////uncomment this line to consol log the widget that have been notified and rebuild
    // RM.debugWidgetsRebuild = true;
    //
    //Injecting the TodoService globally before MaterialApp widget.
    //It will be available throughout all the widget tree even after navigation.
    return Injector(
        inject: [
          Inject<SharedPreferences>.future(
            () async {
              await Future.delayed(Duration(seconds: 2));
              return SharedPreferences.getInstance();
            },
          ),
          //Inject TodosRepository via its interface ITodosRepository
          //this give us the ability to mock the TodosRepository in test.
          Inject<ITodosRepository>.future(
            () async {
              await Future.delayed(Duration(seconds: 2));

              final prefs = await RM.get<SharedPreferences>().stateFuture;
              print('pref is ready');
              return TodosRepository(prefs: prefs);
            },
          ),
          Inject<TodosService>.future(
            () async {
              await Future.delayed(Duration(seconds: 2));

              final repos = await RM.get<ITodosRepository>().stateFuture;
              print('repos is ready');
              return TodosService(await repos);
            },
          )
        ],
        builder: (context) {
          return MaterialApp(
            title: StatesRebuilderLocalizations().appTitle,
            theme: ArchSampleTheme.theme,
            localizationsDelegates: [
              ArchSampleLocalizationsDelegate(),
              StatesRebuilderLocalizationsDelegate(),
            ],
            routes: {
              ArchSampleRoutes.home: (context) => HomeScreen(),
              ArchSampleRoutes.addTodo: (context) => AddEditPage(),
            },
          );
        });
  }
}
