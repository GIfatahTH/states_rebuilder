import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../data_source/firebase_todos_repository.dart';
import '../../../domain/entities/todo.dart';
import '../../../domain/value_object/todos_stats.dart';
import '../../../service/common/enums.dart';
import '../../common/enums.dart';
import '../../common/localization/localization.dart';
import '../../common/theme/theme.dart';
import '../../exceptions/error_handler.dart';
import '../../pages/add_edit_screen.dart/add_edit_screen.dart';
import '../auth_page/auth_page.dart';
import '../detail_screen/detail_screen.dart';

part 'extra_actions_button.dart';
part 'filter_button.dart';
part 'injected_todo.dart';
part 'languages.dart';
part 'stats_counter.dart';
part 'todo_item.dart';
part 'todo_list.dart';

class HomeScreen extends StatelessWidget {
  static String routeName = '/HomeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _i18n = i18n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.appTitle),
        actions: [
          const FilterButton(),
          const ExtraActionsButton(),
          const Languages(),
        ],
      ),
      body: On.future(
        onWaiting: () => const Center(
          child: const CircularProgressIndicator(),
        ),
        onError: (err, refresh) => Center(
          child: Column(
            children: [
              Text('Error in Retrieving todos'),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  refresh();
                },
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        onData: (_, __) {
          return On.data(
            () => activeTab.state == AppTab.todos ? TodoList() : StatsCounter(),
          ).listenTo(activeTab);
        },
      ).listenTo(
        todosFiltered,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          RM.navigate.toNamed(AddEditPage.routeName);
        },
        child: const Icon(Icons.add),
        tooltip: _i18n.addTodo,
      ),
      bottomNavigationBar: On.data(
        () => BottomNavigationBar(
          currentIndex: AppTab.values.indexOf(activeTab.state),
          onTap: (index) {
            activeTab.state = AppTab.values[index];
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: _i18n.stats,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: _i18n.todos,
            ),
          ],
        ),
      ).listenTo(activeTab),
    );
  }
}
