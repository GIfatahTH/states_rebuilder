// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'package:clean_architecture_todo_mvc/domain/entities/todo.dart';
import 'package:clean_architecture_todo_mvc/ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'package:clean_architecture_todo_mvc/ui/pages/shared_widgets/check_favorite_box.dart';
import 'package:todos_app_core/todos_app_core.dart';

class DetailScreen extends StatelessWidget {
  DetailScreen(this.todoRM) : super(key: ArchSampleKeys.todoDetailsScreen);
  final ReactiveModel<Todo> todoRM;
  Todo get todo => todoRM.value;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ArchSampleLocalizations.of(context).todoDetails),
        actions: [
          IconButton(
            key: ArchSampleKeys.deleteTodoButton,
            tooltip: ArchSampleLocalizations.of(context).deleteTodo,
            icon: Icon(Icons.delete),
            onPressed: () {
              Navigator.pop(context, true);
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            StateBuilder(
                key: Key('DetailScreen'),
                observe: () => todoRM,
                builder: (_, __) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: CheckFavoriteBox(
                          todoRM: todoRM,
                          key: ArchSampleKeys.detailsTodoItemCheckbox,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: 8.0,
                                bottom: 16.0,
                              ),
                              child: Text(
                                todo.task,
                                key: ArchSampleKeys.detailsTodoItemTask,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                            Text(
                              todo.note,
                              key: ArchSampleKeys.detailsTodoItemNote,
                              style: Theme.of(context).textTheme.subtitle1,
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: ArchSampleLocalizations.of(context).editTodo,
        child: Icon(Icons.edit),
        key: ArchSampleKeys.editTodoFab,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return AddEditPage(
                  key: ArchSampleKeys.editTodoScreen,
                  todoRM: todoRM,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
