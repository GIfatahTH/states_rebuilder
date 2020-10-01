// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../injected.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  const TodoList();
  @override
  Widget build(BuildContext context) {
    return todosFiltered.whenRebuilderOr(
      builder: () {
        final todos = todosFiltered.state;
        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (BuildContext context, int index) {
            return injectedTodo.inherited(
              key: Key('${todos[index].id}'),
              connectWithGlobal: true,
              state: () {
                return todosFiltered.state[index];
              },
              builder: (_) => const TodoItem(),
              // debugPrintWhenNotifiedPreMessage: 'todo $index',
            );
          },
        );
      },
    );
  }
}
