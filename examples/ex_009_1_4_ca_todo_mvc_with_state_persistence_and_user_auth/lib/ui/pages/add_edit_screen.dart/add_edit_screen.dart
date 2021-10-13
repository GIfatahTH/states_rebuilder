// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/blocs/todos_bloc.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/localization/localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/todo.dart';

final _task = RM.injectTextEditing(
  text: 'hhhhhhh',
  validators: [
    (val) {
      if (val!.trim().isEmpty) {
        return i18n.of(RM.context!).emptyTodoError;
      }
    }
  ],
);
final _note = RM.injectTextEditing();
final _form = RM.injectForm();

class AddEditPage extends StatelessWidget {
  static String routeName = '/addEditPage';

  const AddEditPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _i18n = i18n.of(context);
    final todo = todosBloc.todosRM.item(context);
    bool isEditing = todo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? _i18n.editTodo : _i18n.addTodo,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: OnFormBuilder(
          listenTo: _form,
          builder: () => ListView(
            children: [
              TextField(
                key: Key('__TaskField'),
                controller: _task.controller
                  ..text = todo != null ? todo.state.task : '',

                autofocus: isEditing ? false : true,
                style: Theme.of(context).textTheme.headline5,
                decoration: InputDecoration(hintText: _i18n.newTodoHint),
                // validator: (val) =>
                //     val!.trim().isEmpty ? _i18n.emptyTodoError : null,
                // onSaved: (value) => _task = value,
              ),
              TextField(
                key: Key('__NoteField'),
                controller: _note.controller
                  ..text = todo != null ? todo.state.note : '',
                maxLines: 10,
                style: Theme.of(context).textTheme.subtitle1,
                decoration: InputDecoration(
                  hintText: _i18n.notesHint,
                ),
                // onSaved: (value) => _note = value,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: isEditing ? _i18n.saveChanges : _i18n.addTodo,
        child: Icon(isEditing ? Icons.check : Icons.add),
        onPressed: () => _form.submit(() async {
          if (isEditing) {
            final newTodo = todo.state.copyWith(
              task: _task.text,
              note: _note.text,
            );
            todo.state = newTodo;
          } else {
            todosBloc.createTodo(
              Todo(_task.text, note: _note.text),
              isOptimistic: false,
            );
          }
          RM.navigate.back();
        }),
      ),
    );
  }
}
