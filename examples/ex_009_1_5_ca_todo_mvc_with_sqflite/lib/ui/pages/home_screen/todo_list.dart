// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../injected.dart';
import 'todo_item.dart';

class TodoList extends StatelessWidget {
  const TodoList();
  @override
  Widget build(BuildContext context) {
    return On.data(
      () => ListView.builder(
        itemCount: todos.state.length,
        itemBuilder: (BuildContext context, int index) {
          return todoItem.inherited(
            key: Key('${todos.state[index].id}'),
            connectWithGlobal: true,
            stateOverride: () {
              return todos.state[index];
            },
            builder: (_) => const TodoItem(),
          );
        },
      ),
    ).listenTo(todos);
  }
}
