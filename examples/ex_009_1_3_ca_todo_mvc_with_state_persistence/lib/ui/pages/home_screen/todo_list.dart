// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../../../injected.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return todosFiltered.rebuilder(
      () {
        final todos = todosFiltered.state;
        return ListView.builder(
          key: ArchSampleKeys.todoList,
          itemCount: todos.length,
          itemBuilder: (BuildContext context, int index) {
            return injectedTodo.inherited(
              key: Key('${todos[index].id}'),
              connectWithGlobal: true,
              state: () {
                return todos[index];
              },
              builder: (_) => TodoItem(),
              // debugPrintWhenNotifiedPreMessage: 'todo $index',
            );
          },
        );
      },
      shouldRebuild: () => todosFiltered.hasData || todosFiltered.hasError,
      key: Key('Todos List'),
    );
  }
}
