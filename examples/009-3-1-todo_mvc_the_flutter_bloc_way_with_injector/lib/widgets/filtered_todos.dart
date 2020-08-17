// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todo_mvc_the_flutter_bloc_way/blocs/blocs.dart';
import 'package:todo_mvc_the_flutter_bloc_way/models/models.dart';
import 'package:todo_mvc_the_flutter_bloc_way/screens/screens.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../bloc_library_keys.dart';
import 'loading_indicator.dart';
import 'widgets.dart';

class FilteredTodos extends StatelessWidget {
  FilteredTodos({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = ArchSampleLocalizations.of(context);

    return StateBuilder<FilteredTodosState>(
      observe: () => RM.get<FilteredTodosState>(),
      builder: (
        BuildContext context,
        filteredTodosStateRM,
      ) {
        if (filteredTodosStateRM.state is FilteredTodosLoading) {
          return LoadingIndicator(key: ArchSampleKeys.todosLoading);
        } else if (filteredTodosStateRM.state is FilteredTodosLoaded) {
          final todos =
              (filteredTodosStateRM.state as FilteredTodosLoaded).filteredTodos;
          return ListView.builder(
            key: ArchSampleKeys.todoList,
            itemCount: todos.length,
            itemBuilder: (BuildContext context, int index) {
              final todo = todos[index];
              return TodoItem(
                todo: todo,
                onDismissed: (_) {
                  RM.get<TodosState>().setState(
                        (s) => TodosLoaded.deleteTodo(s, todo),
                      );
                  Scaffold.of(context).showSnackBar(DeleteTodoSnackBar(
                    key: ArchSampleKeys.snackbar,
                    todo: todo,
                    onUndo: () => RM.get<TodosState>().setState(
                          (s) => TodosLoaded.addTodo(s, todo),
                        ),
                    localizations: localizations,
                  ));
                },
                onTap: () async {
                  final removedTodo = await Navigator.of(context).push<Todo>(
                    MaterialPageRoute(builder: (_) {
                      return DetailsScreen(id: todo.id);
                    }),
                  );
                  if (removedTodo != null) {
                    Scaffold.of(context).showSnackBar(DeleteTodoSnackBar(
                      key: ArchSampleKeys.snackbar,
                      todo: todo,
                      onUndo: () => RM.get<TodosState>().setState(
                            (s) => TodosLoaded.addTodo(s, todo),
                          ),
                      localizations: localizations,
                    ));
                  }
                },
                onCheckboxChanged: (_) {
                  RM.get<TodosState>().setState(
                        (s) => TodosLoaded.updateTodo(
                            s, todo.copyWith(complete: !todo.complete)),
                      );
                },
              );
            },
          );
        } else {
          return Container(key: BlocLibraryKeys.filteredTodosEmptyContainer);
        }
      },
    );
  }
}
