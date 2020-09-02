// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:clean_architecture_todo_mvc/injected.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../../../domain/entities/todo.dart';
import '../../exceptions/error_handler.dart';

class AddEditPage extends StatefulWidget {
  final Todo todo;

  AddEditPage({
    Key key,
    this.todo,
  }) : super(key: key ?? ArchSampleKeys.addTodoScreen);

  @override
  _AddEditPageState createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // Here we use a StatefulWidget to hold local fields _task and _note
  String _task;
  String _note;
  bool get isEditing => widget.todo != null;
  Todo get todo => widget.todo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? ArchSampleLocalizations.of(context).editTodo
            : ArchSampleLocalizations.of(context).addTodo),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          autovalidate: false,
          onWillPop: () {
            return Future(() => true);
          },
          child: ListView(
            children: [
              TextFormField(
                initialValue: todo != null ? todo.task : '',
                key: ArchSampleKeys.taskField,
                autofocus: isEditing ? false : true,
                style: Theme.of(context).textTheme.headline5,
                decoration: InputDecoration(
                    hintText: ArchSampleLocalizations.of(context).newTodoHint),
                validator: (val) => val.trim().isEmpty
                    ? ArchSampleLocalizations.of(context).emptyTodoError
                    : null,
                onSaved: (value) => _task = value,
              ),
              TextFormField(
                initialValue: todo != null ? todo.note : '',
                key: ArchSampleKeys.noteField,
                maxLines: 10,
                style: Theme.of(context).textTheme.subtitle1,
                decoration: InputDecoration(
                  hintText: ArchSampleLocalizations.of(context).notesHint,
                ),
                onSaved: (value) => _note = value,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key:
            isEditing ? ArchSampleKeys.saveTodoFab : ArchSampleKeys.saveNewTodo,
        tooltip: isEditing
            ? ArchSampleLocalizations.of(context).saveChanges
            : ArchSampleLocalizations.of(context).addTodo,
        child: Icon(isEditing ? Icons.check : Icons.add),
        onPressed: () {
          final form = formKey.currentState;
          if (form.validate()) {
            form.save();
            todosService.setState(
              (s) {
                if (isEditing) {
                  return s.updateTodo(
                    todo.copyWith(
                      task: _task,
                      note: _note,
                    ),
                  );
                }
                return s.addTodo(Todo(_task, note: _note));
              },
              onError: ErrorHandler.showErrorSnackBar,
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
