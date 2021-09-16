import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/blocs/common/enums.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../blocs/auth_bloc.dart';
import '../../../blocs/todos_bloc.dart';
import '../../../domain/entities/todo.dart';
import '../../common/enums.dart';
import '../../localization/localization.dart';
import '../../pages/add_edit_screen.dart/add_edit_screen.dart';
import '../../theme/theme.dart';
import '../detail_screen/detail_screen.dart';

part 'extra_actions_button.dart';
part 'filter_button.dart';
part 'languages.dart';
part 'stats_counter.dart';
part 'todo_item.dart';
part 'todo_list.dart';

class HomeScreen extends StatelessWidget {
  static String routeName = '/HomeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  static final appTab = RM.injectPageTab(length: 2);

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
          () => todosBloc.todosRM.onOrElse(
            onWaiting: todosBloc.todos.isEmpty
                ? () => const Center(
                      child: const CircularProgressIndicator(),
                    )
                : null,
            onError: todosBloc.todos.isEmpty
                ? (err, refresh) => Center(
                      child: Column(
                        children: [
                          Text(_i18n.errorInRetrievingTodos),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              todosBloc.todosRM.refresh();
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
                builder: (_) => PageView(
                  controller: appTab.pageController,
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
                controller: appTab.tabController,
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
