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
    //rebuilder will rebuild only if filteredTodos hasData.
    return filteredTodos.rebuilder(
      () {
        return ListView.builder(
          key: ArchSampleKeys.todoList,
          itemCount: filteredTodos.state.length,
          itemBuilder: (BuildContext context, int index) {
            return TodoItem(index: index);
          },
        );
      },
    );
  }
}
