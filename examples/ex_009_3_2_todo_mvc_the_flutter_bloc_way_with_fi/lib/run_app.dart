// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:todo_mvc_the_flutter_bloc_way/blocs/blocs.dart';
import 'package:todo_mvc_the_flutter_bloc_way/blocs/todos/todos_state.dart';
import 'package:todo_mvc_the_flutter_bloc_way/localization.dart';
import 'package:todos_app_core/todos_app_core.dart';

import 'injected.dart';
import 'models/todo.dart';
import 'screens/add_edit_screen.dart';
import 'screens/home_screen.dart';

class TodosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) =>
          StatesRebuilderLocalizations.of(context).appTitle,
      theme: ArchSampleTheme.theme,
      localizationsDelegates: [
        ArchSampleLocalizationsDelegate(),
        StatesRebuilderLocalizationsDelegate(),
      ],
      routes: {
        ArchSampleRoutes.home: (context) => HomeScreen(),
        ArchSampleRoutes.addTodo: (context) {
          return AddEditScreen(
            key: ArchSampleKeys.addTodoScreen,
            onSave: (task, note) {
              todosState.setState(
                (currentState) => TodosLoaded.addTodo(
                  currentState,
                  Todo(task, note: note),
                ),
              );
            },
            isEditing: false,
          );
        },
      },
    );
  }
}
