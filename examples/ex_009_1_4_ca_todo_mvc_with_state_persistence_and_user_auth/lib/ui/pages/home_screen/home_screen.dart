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

  static final appTab = RM.injectTab(length: 2);

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
        body: OnReactive(
          () => todos.onOrElse(
            onWaiting: todos.state.isEmpty
                ? () => const Center(
                      child: const CircularProgressIndicator(),
                    )
                : null,
            onError: todos.state.isEmpty
                ? (err, refresh) => Center(
                      child: Column(
                        children: [
                          Text(_i18n.errorInRetrievingTodos),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              todos.refresh();
                              refresh();
                            },
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    )
                : null,
            orElse: (data) {
              return OnTabBuilder(
                listenTo: appTab,
                builder: (_) => TabBarView(
                  controller: appTab.controller,
                  children: [const TodoList(), const StatsCounter()],
                ),
              );
            },
          ),
          debugPrintWhenRebuild: 'todosHomePage',
          debugPrintWhenObserverAdd: 'todosHomePage',
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            RM.navigate.toNamed(AddEditPage.routeName);
          },
          child: const Icon(Icons.add),
          tooltip: _i18n.addTodo,
        ),
        bottomNavigationBar: OnTabBuilder(
          listenTo: appTab,
          builder: (index) {
            return SizedBox(
              height: 50,
              child: TabBar(
                controller: appTab.controller,
                tabs: [
                  Transform.scale(
                    scale: index == 0 ? 1.2 : 1.0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.show_chart,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        Text(
                          _i18n.todos,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: index == 1 ? 1.2 : 1.0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.list,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        Text(
                          _i18n.stats,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
