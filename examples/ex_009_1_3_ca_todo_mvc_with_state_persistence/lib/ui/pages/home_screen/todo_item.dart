// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/todo.dart';
import '../../../injected.dart';
import '../../../service/todos_state.dart';
import '../../../ui/pages/detail_screen/detail_screen.dart';
import '../../common/localization/localization.dart';

class TodoItem extends StatelessWidget {
  const TodoItem({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todo = injectedTodo(context);
    return todo.rebuilder(
      () {
        return Dismissible(
          key: Key('__${todo.state.id}__'),
          onDismissed: (direction) {
            removeTodo(todo.state);
          },
          child: ListTile(
            onTap: () async {
              final shouldDelete = await RM.navigate.to(
                injectedTodo.reInherited(
                  context: context,
                  builder: (context) => const DetailScreen(),
                ),
              );
              if (shouldDelete == true) {
                //Removing todo will show a Snackbar
                //We explicitly set the context to get the right scaffold
                RM.scaffoldShow.context = context; //TODO
                removeTodo(todo.state);
              }
            },
            leading: Checkbox(
              key: Key('__Checkbox${todo.state.id}__'),
              value: todo.state.complete,
              onChanged: (value) {
                final newTodo = todo.state.copyWith(
                  complete: value,
                );
                todo.state = newTodo;
              },
            ),
            title: Text(
              todo.state.task,
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: Text(
              todo.state.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        );
      },
    );
  }

  void removeTodo(Todo todo) {
    todos.setState((s) => s.deleteTodo(todo));

    RM.scaffoldShow.snackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          i18n.state.todoDeleted(todo.task),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: i18n.state.undo,
          onPressed: () {
            todos.undoState();
          },
        ),
      ),
    );
  }
}
