// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/injected.dart';
import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';

class StatsCounter extends StatelessWidget {
  StatsCounter() : super(key: ArchSampleKeys.statsCounter);

  @override
  Widget build(BuildContext context) {
    return todosState.rebuilder(
      () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                ArchSampleLocalizations.of(context).completedTodos,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                '${todosState.state.numCompleted}',
                key: ArchSampleKeys.statsNumCompleted,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                ArchSampleLocalizations.of(context).activeTodos,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                '${todosState.state.numActive}',
                key: ArchSampleKeys.statsNumActive,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            )
          ],
        ),
      ),
    );
  }
}
