// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../blocs/blocs.dart';
import '../injected.dart';
import '../localization.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return appTabState.rebuilder(
      () {
        return Scaffold(
          appBar: AppBar(
            title: Text(StatesRebuilderLocalizations.of(context).appTitle),
            actions: [
              FilterButton(),
              ExtraActions(),
            ],
          ),
          body: appTabState.state.appTab == AppTab.todos
              ? FilteredTodos()
              : Stats(),
          floatingActionButton: FloatingActionButton(
            key: ArchSampleKeys.addTodoFab,
            onPressed: () {
              Navigator.pushNamed(context, ArchSampleRoutes.addTodo);
            },
            child: Icon(Icons.add),
            tooltip: ArchSampleLocalizations.of(context).addTodo,
          ),
          bottomNavigationBar: TabSelector(
            activeTab: appTabState.state.appTab,
            onTabSelected: (tab) {
              return appTabState.setState(
                (s) => AppTabState.updateAppTab(tab),
              );
            },
          ),
        );
      },
    );
  }
}
