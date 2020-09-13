import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../../../injected.dart';
import '../../../localization.dart';
import '../../../service/todos_state.dart';
import '../../common/enums.dart';
import 'extra_actions_button.dart';
import 'filter_button.dart';
import 'stats_counter.dart';
import 'todo_list.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StatesRebuilderLocalizations.of(context).appTitle),
        actions: [
          FilterButton(),
          ExtraActionsButton(),
        ],
      ),
      body: todosState.futureBuilder(
        key: Key('WhenRebuilderOr Home screen'),
        onWaiting: () => Center(
          child: CircularProgressIndicator(
            key: ArchSampleKeys.todosLoading,
          ),
        ),
        onData: (_) => activeTab.rebuilder(
          () => activeTab.state == AppTab.todos ? TodoList() : StatsCounter(),
        ),
        onError: null,
        future: (s, asyncS) {
          return asyncS.then((s) => TodosState.loadTodos(s));
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: ArchSampleKeys.addTodoFab,
        onPressed: () {
          Navigator.pushNamed(context, ArchSampleRoutes.addTodo);
        },
        child: Icon(Icons.add),
        tooltip: ArchSampleLocalizations.of(context).addTodo,
      ),
      bottomNavigationBar: activeTab.rebuilder(
        () => BottomNavigationBar(
          key: ArchSampleKeys.tabs,
          currentIndex: AppTab.values.indexOf(activeTab.state),
          onTap: (index) {
            activeTab.state = AppTab.values[index];
          },
          items: AppTab.values.map(
            (tab) {
              return BottomNavigationBarItem(
                icon: Icon(
                  tab == AppTab.todos ? Icons.list : Icons.show_chart,
                  key: tab == AppTab.stats
                      ? ArchSampleKeys.statsTab
                      : ArchSampleKeys.todoTab,
                ),
                title: Text(
                  tab == AppTab.stats
                      ? ArchSampleLocalizations.of(context).stats
                      : ArchSampleLocalizations.of(context).todos,
                ),
              );
            },
          ).toList(),
        ),
        key: Key('StateBuilder AppTab'),
      ),
    );
  }
}
