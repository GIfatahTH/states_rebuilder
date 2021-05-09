part of 'home_screen.dart';

final InjectedCRUD<Todo, String> todos = RM.injectCRUD<Todo, String>(
  () => FireBaseTodosRepository(
    authToken: user.state!.token.token!,
  ),
  param: () => '__Todos__/${user.state!.userId}',
  readOnInitialization: true,
  onSetState: On.error((e, r) {
    ErrorHandler.showErrorSnackBar(e);
  }),
  onInitialized: (_) {
    Injected.debugAddRemoveListener(todos, onAaddListener: (_) {
      print(_);
    });
  },
  debugPrintWhenNotifiedPreMessage: 'todos',
);

extension ListTodoX on List<Todo> {
  void toggleAll() {
    final allComplete = this.every((e) => e.complete);
    todos.crud.update(
      where: (t) => t.complete == allComplete,
      set: (t) => t.copyWith(complete: !allComplete),
    );
  }

  void clearCompleted() {
    todos.crud.delete(where: (t) => t.complete);
  }
}

final activeFilter = RM.inject(() => VisibilityFilter.all);

final Injected<List<Todo>> todosFiltered = RM.inject(
  () {
    if (activeFilter.state == VisibilityFilter.active) {
      return todos.state.where((t) => !t.complete).toList();
    }
    if (activeFilter.state == VisibilityFilter.completed) {
      return todos.state.where((t) => t.complete).toList();
    }
    return [...todos.state];
  },
  onDisposed: (_) {
    print('filter todos disposed');
  },
  dependsOn: DependsOn({activeFilter, todos}),
  debugPrintWhenNotifiedPreMessage: 'filterTodos',
);

final Injected<TodosStats> todosStats = RM.inject(
  () => TodosStats(
    numCompleted: todos.state.where((t) => t.complete).length,
    numActive: todos.state.where((t) => !t.complete).length,
  ),
  // initialState: TodosStats(numCompleted: 0, numActive: 0),
  dependsOn: DependsOn({todos}),
  // middleSnapState: (middleSnap) {
  //   middleSnap.print(
  //     preMessage: 'stats',
  //   );
  // },
);

final activeTab = RM.inject(() => AppTab.todos);
