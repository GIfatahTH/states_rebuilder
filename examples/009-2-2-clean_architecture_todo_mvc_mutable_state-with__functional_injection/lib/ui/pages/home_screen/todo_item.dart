// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../../../domain/entities/todo.dart';
import '../../../injected.dart';
import '../../exceptions/error_handler.dart';
import '../../pages/detail_screen/detail_screen.dart';

class TodoItem extends StatelessWidget {
  final int index;
  TodoItem({
    Key key,
    @required this.index,
  }) : super(key: key);
  Todo get todo => filteredTodos.state[index];
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ArchSampleKeys.todoItem(todo.id),
      onDismissed: (direction) {
        removeTodo(context, todo);
      },
      child: ListTile(
        onTap: () async {
          final shouldDelete = await RM.navigate.to(
            DetailScreen(index),
          );
          if (shouldDelete == true) {
            removeTodo(context, todo);
          }
        },
        leading: Checkbox(
          key: ArchSampleKeys.todoItemCheckbox(todo.id),
          value: todo.complete,
          onChanged: (value) {
            final newTodo = todo.copyWith(
              complete: value,
            );
            todosService.setState(
              (s) => s.updateTodo(newTodo),
              onError: (context, error) {
                //define onError callback
                //This overrides all error side effects callback that are defined globally.
                ErrorHandler.showErrorSnackBar(context, error);
              },
            );
          },
        ),
        title: Text(
          todo.task,
          key: ArchSampleKeys.todoItemTask(todo.id),
          style: Theme.of(context).textTheme.headline6,
        ),
        subtitle: Text(
          todo.note,
          key: ArchSampleKeys.todoItemNote(todo.id),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ),
    );
  }

  void removeTodo(BuildContext context, Todo todo) {
    todosService.setState(
      (s) => s.deleteTodo(todo),
      //define onError callback
      //This overrides all error side effects callback that are defined globally.
      //
      //IF you uncomment this line an alert dialog will be displayed as defined in the onError
      //of the todosService (in lib/injected.dat file)
      onError: ErrorHandler.showErrorSnackBar,
    );

    Scaffold.of(context).showSnackBar(
      SnackBar(
        key: ArchSampleKeys.snackbar,
        duration: Duration(seconds: 2),
        content: Text(
          ArchSampleLocalizations.of(context).todoDeleted(todo.task),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: ArchSampleLocalizations.of(context).undo,
          onPressed: () {
            todosService.setState((s) => s.addTodo(todo));
          },
        ),
      ),
    );
  }
}
