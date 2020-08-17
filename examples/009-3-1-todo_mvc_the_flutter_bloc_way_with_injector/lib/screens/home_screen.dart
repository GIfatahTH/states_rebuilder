// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todo_mvc_the_flutter_bloc_way/blocs/blocs.dart';
import 'package:todo_mvc_the_flutter_bloc_way/localization.dart';
import 'package:todo_mvc_the_flutter_bloc_way/models/models.dart';
import 'package:todo_mvc_the_flutter_bloc_way/widgets/widgets.dart';
import 'package:todos_app_core/todos_app_core.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder<AppTabState>(
      observe: () => RM.get<AppTabState>(),
      builder: (context, appTabStateRM) {
        return Scaffold(
          appBar: AppBar(
            title: Text(StatesRebuilderLocalizations.of(context).appTitle),
            actions: [
              FilterButton(visible: appTabStateRM.state.appTab == AppTab.todos),
              ExtraActions(),
            ],
          ),
          body: appTabStateRM.state.appTab == AppTab.todos
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
            activeTab: appTabStateRM.state.appTab,
            onTabSelected: (tab) {
              return appTabStateRM.setState(
                (s) => AppTabState.updateAppTab(tab),
              );
            },
          ),
        );
      },
    );
  }
}
