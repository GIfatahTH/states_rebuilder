// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/injected.dart';
import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../../../domain/entities/todo.dart';
import '../../../service/todos_state.dart';
import '../../../ui/exceptions/error_handler.dart';
import '../../../ui/pages/detail_screen/detail_screen.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  TodoItem({
    Key key,
    @required this.todo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ArchSampleKeys.todoItem(todo.id),
      onDismissed: (direction) {
        removeTodo(context, todo);
      },
      child: ListTile(
        onTap: () async {
          final shouldDelete = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) {
                return DetailScreen(todo);
              },
            ),
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
            todosState
              ..setState(
                (t) => TodosState.updateTodo(t, newTodo),
                onError: ErrorHandler.showErrorSnackBar,
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
    todosState.setState(
      (t) => TodosState.deleteTodo(t, todo),
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
            todosState.setState(
              (t) => TodosState.addTodo(t, todo),
              onError: ErrorHandler.showErrorSnackBar,
            );
          },
        ),
      ),
    );
  }
}
