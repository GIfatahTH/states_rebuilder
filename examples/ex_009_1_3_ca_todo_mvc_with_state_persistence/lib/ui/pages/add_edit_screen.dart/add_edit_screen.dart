// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/todo.dart';
import '../../../injected.dart';
import '../../../service/todos_state.dart';
import '../../common/localization/localization.dart';

class AddEditPage extends StatefulWidget {
  static String routeName = '/addEditPage';

  const AddEditPage({
    Key key,
  }) : super(key: key);

  @override
  _AddEditPageState createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // Here we use a StatefulWidget to hold local fields _task and _note
  String _task;
  String _note;
  @override
  Widget build(BuildContext context) {
    final todo = injectedTodo(context);
    bool isEditing = todo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? i18n.state.editTodo : i18n.state.addTodo),
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
                initialValue: todo != null ? todo.state.task : '',
                autofocus: isEditing ? false : true,
                style: Theme.of(context).textTheme.headline5,
                decoration: InputDecoration(hintText: i18n.state.newTodoHint),
                validator: (val) =>
                    val.trim().isEmpty ? i18n.state.emptyTodoError : null,
                onSaved: (value) => _task = value,
              ),
              TextFormField(
                initialValue: todo != null ? todo.state.note : '',
                maxLines: 10,
                style: Theme.of(context).textTheme.subtitle1,
                decoration: InputDecoration(
                  hintText: i18n.state.notesHint,
                ),
                onSaved: (value) => _note = value,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: isEditing ? i18n.state.saveChanges : i18n.state.addTodo,
        child: Icon(isEditing ? Icons.check : Icons.add),
        onPressed: () {
          final form = formKey.currentState;
          if (form.validate()) {
            form.save();
            if (isEditing) {
              final newTodo = todo.state.copyWith(
                task: _task,
                note: _note,
              );
              todo.state = newTodo;
            } else {
              todos.setState(
                (s) => s.addTodo(Todo(_task, note: _note)),
              );
            }
            RM.navigate.back();
          }
        },
      ),
    );
  }
}
