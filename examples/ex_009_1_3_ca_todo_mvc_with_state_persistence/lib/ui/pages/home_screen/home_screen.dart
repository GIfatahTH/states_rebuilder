import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../injected.dart';
import '../../common/enums.dart';
import '../../common/localization/localization.dart';
import '../../pages/add_edit_screen.dart/add_edit_screen.dart';
import 'extra_actions_button.dart';
import 'filter_button.dart';
import 'stats_counter.dart';
import 'todo_list.dart';

class HomeScreen extends StatelessWidget {
  static String routeName = '/';

  HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.state.appTitle),
        actions: [
          FilterButton(),
          ExtraActionsButton(),
        ],
      ),
      body: todos.whenRebuilderOr(
        key: Key('WhenRebuilderOr Home screen'),
        onWaiting: () => Center(
          child: CircularProgressIndicator(),
        ),
        builder: () => activeTab.rebuilder(
          () => activeTab.state == AppTab.todos ? TodoList() : StatsCounter(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          RM.navigate.toNamed(AddEditPage.routeName);
        },
        child: Icon(Icons.add),
        tooltip: i18n.state.addTodo,
      ),
      bottomNavigationBar: activeTab.rebuilder(
        () => BottomNavigationBar(
          currentIndex: AppTab.values.indexOf(activeTab.state),
          onTap: (index) {
            activeTab.state = AppTab.values[index];
          },
          items: AppTab.values.map(
            (tab) {
              return BottomNavigationBarItem(
                icon: Icon(
                  tab == AppTab.todos ? Icons.list : Icons.show_chart,
                ),
                title: Text(
                  tab == AppTab.stats ? i18n.state.stats : i18n.state.todos,
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
