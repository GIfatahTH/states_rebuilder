// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../bloc_library_keys.dart';
import '../blocs/todos/todos_state.dart';
import '../injected.dart';
import '../models/models.dart';

class ExtraActions extends StatelessWidget {
  ExtraActions({Key key}) : super(key: ArchSampleKeys.extraActionsButton);

  @override
  Widget build(BuildContext context) {
    return todosState.rebuilder(
      () {
        final state = todosState.state;
        if (state is TodosLoaded) {
          final allComplete = state.todos.every((todo) => todo.complete);
          return PopupMenuButton<ExtraAction>(
            key: BlocLibraryKeys.extraActionsPopupMenuButton,
            onSelected: (action) {
              switch (action) {
                case ExtraAction.clearCompleted:
                  todosState.setState((s) => TodosLoaded.clearCompleted(s));
                  break;
                case ExtraAction.toggleAllComplete:
                  todosState.setState((s) => TodosLoaded.toggleAll(s));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<ExtraAction>>[
              PopupMenuItem<ExtraAction>(
                key: ArchSampleKeys.toggleAll,
                value: ExtraAction.toggleAllComplete,
                child: Text(
                  allComplete
                      ? ArchSampleLocalizations.of(context).markAllIncomplete
                      : ArchSampleLocalizations.of(context).markAllComplete,
                ),
              ),
              PopupMenuItem<ExtraAction>(
                key: ArchSampleKeys.clearCompleted,
                value: ExtraAction.clearCompleted,
                child: Text(
                  ArchSampleLocalizations.of(context).clearCompleted,
                ),
              ),
            ],
          );
        }
        return Container(key: BlocLibraryKeys.extraActionsEmptyContainer);
      },
    );
  }
}
