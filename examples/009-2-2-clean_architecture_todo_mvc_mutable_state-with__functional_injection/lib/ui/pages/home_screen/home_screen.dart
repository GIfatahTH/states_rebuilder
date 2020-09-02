import 'package:flutter/material.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../../../injected.dart';
import '../../../localization.dart';
import '../../common/enums.dart';
import 'extra_actions_button.dart';
import 'filter_button.dart';
import 'stats_counter.dart';
import 'todo_list.dart';

class HomeScreen extends StatelessWidget {
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
      body: todosService.futureBuilder(
        future: (state, stateAsync) async {
          //await until the SharedPreferences and TodosService are initialized
          return stateAsync.then((s) {
            //call loadTodos
            return s.loadTodos();
          });
        },
        //Show CircularProgressIndicator while loadTodos is executing
        onWaiting: () => Center(
          child: CircularProgressIndicator(
            key: ArchSampleKeys.todosLoading,
          ),
        ),
        //onError is null, which means that onData will be invoked instead in case of error.
        //and a side effect will be executed (as defined while injecting todosService)
        onError: null,
        onData: (_) {
          //register to appTab injected model.
          //rebuilder will be called only if appTab has data
          return appTab.rebuilder(
            () => appTab.state == AppTab.todos ? TodoList() : StatsCounter(),
          );
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
      bottomNavigationBar: appTab.rebuilder(
        () => BottomNavigationBar(
          key: ArchSampleKeys.tabs,
          currentIndex: AppTab.values.indexOf(appTab.state),
          onTap: (index) {
            appTab.state = AppTab.values[index];
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
      ),
    );
  }
}
