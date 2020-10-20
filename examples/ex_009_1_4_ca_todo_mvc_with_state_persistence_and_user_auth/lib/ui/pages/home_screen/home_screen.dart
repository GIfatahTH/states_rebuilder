import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../injected.dart';
import '../../common/enums.dart';
import '../../common/localization/localization.dart';
import '../../pages/add_edit_screen.dart/add_edit_screen.dart';
import 'extra_actions_button.dart';
import 'filter_button.dart';
import 'languages.dart';
import 'stats_counter.dart';
import 'todo_list.dart';

class HomeScreen extends StatelessWidget {
  static String routeName = '/HomeScreen';

  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.of(context).appTitle),
        actions: [
          const FilterButton(),
          const ExtraActionsButton(),
          const Languages(),
        ],
      ),
      body: todos.whenRebuilderOr(
        onWaiting: () => const Center(
          child: const CircularProgressIndicator(),
        ),
        builder: () => activeTab.rebuilder(
          () => activeTab.state == AppTab.todos
              ? const TodoList()
              : const StatsCounter(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          RM.navigate.toNamed(AddEditPage.routeName);
        },
        child: const Icon(Icons.add),
        tooltip: i18n.of(context).addTodo,
      ),
      bottomNavigationBar: activeTab.rebuilder(
        () => BottomNavigationBar(
          currentIndex: AppTab.values.indexOf(activeTab.state),
          onTap: (index) {
            activeTab.state = AppTab.values[index];
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: i18n.of(context).stats,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: i18n.of(context).todos,
            ),
          ],
        ),
      ),
    );
  }
}
