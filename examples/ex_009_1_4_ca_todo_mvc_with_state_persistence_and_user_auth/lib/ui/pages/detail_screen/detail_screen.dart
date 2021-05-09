// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import '../../common/localization/localization.dart';
import '../home_screen/home_screen.dart';

class DetailScreen extends StatelessWidget {
  DetailScreen();

  @override
  Widget build(BuildContext context) {
    final todo = todos.item.call(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.of(context).todoDetails),
        actions: [
          IconButton(
            tooltip: i18n.of(context).deleteTodo,
            icon: Icon(Icons.delete),
            onPressed: () {
              RM.navigate.back(true);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            On.data(
              () => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Checkbox(
                      value: todo.state.complete,
                      onChanged: (value) {
                        final newTodo = todo.state.copyWith(
                          complete: value,
                        );
                        todo.state = newTodo;
                      },
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
                            todo.state.task,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                        Text(
                          todo.state.note,
                          style: Theme.of(context).textTheme.subtitle1,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ).listenTo(todo),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: i18n.of(context).editTodo,
        child: const Icon(Icons.edit),
        onPressed: () {
          RM.navigate.to(
            todos.item.reInherited(
              context: context,
              builder: (context) => AddEditPage(),
            ),
          );
        },
      ),
    );
  }
}
