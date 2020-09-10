// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../../../domain/entities/todo.dart';
import '../../../injected.dart';
import '../../exceptions/error_handler.dart';
import '../add_edit_screen.dart/add_edit_screen.dart';

class DetailScreen extends StatelessWidget {
  DetailScreen(this.index)
      //create an Injected model of this Todo
      : todo = RM.inject(() => filteredTodos.state[index]),
        super(key: ArchSampleKeys.todoDetailsScreen);
  final int index;
  final Injected<Todo> todo;
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
        child: todo.rebuilder(
          () => ListView(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Checkbox(
                      key: ArchSampleKeys.detailsTodoItemCheckbox,
                      value: todo.state.complete,
                      onChanged: (value) {
                        final oldTodo = todo.state;
                        final newTodo = todo.state.copyWith(
                          complete: value,
                        );
                        todo.state = newTodo;
                        todosService.setState(
                          (s) => s.updateTodo(newTodo),
                          onError: (context, error) {
                            todo.state = oldTodo;
                            ErrorHandler.showErrorSnackBar(context, error);
                          },
                        );
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
                            key: ArchSampleKeys.detailsTodoItemTask,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                        Text(
                          todo.state.note,
                          key: ArchSampleKeys.detailsTodoItemNote,
                          style: Theme.of(context).textTheme.subtitle1,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: ArchSampleLocalizations.of(context).editTodo,
        child: Icon(Icons.edit),
        key: ArchSampleKeys.editTodoFab,
        onPressed: () async {
          await RM.navigate.to(
            AddEditPage(
              key: ArchSampleKeys.editTodoScreen,
              todo: todo.state,
            ),
          );
          //await if todosService is in the waiting state
          //the refresh the injected todo to hold the new todo
          //if the todo changes the widget will rebuild
          todosService.stateAsync.then(
            (value) => todo.refresh(),
          );
        },
      ),
    );
  }
}
