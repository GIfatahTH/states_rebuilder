import 'package:states_rebuilder/states_rebuilder.dart';

import './ui/common/enums.dart';
import 'domain/entities/todo.dart';
import 'domain/value_object/todos_stats.dart';
import 'service/common/enums.dart';
import 'service/todos_state.dart';

import 'ui/exceptions/error_handler.dart';

final Injected<List<Todo>> todos = RM.inject(
  () => [],
  persist: () => PersistState(
    key: '__Todos__',
    toJson: (todos) => todos.toJson(),
    fromJson: (json) => ListTodoX.fromJson(json),
    // debugPrintOperations: true,
  ),
  onError: (e, s) => ErrorHandler.showErrorSnackBar(e),
  undoStackLength: 1,
  // debugPrintWhenNotifiedPreMessage: 'todos',
);

final activeFilter = RM.inject(() => VisibilityFilter.all);

final Injected<List<Todo>> todosFiltered = RM.injectComputed(
  compute: (_) {
    if (activeFilter.state == VisibilityFilter.active) {
      return todos.state.where((t) => !t.complete).toList();
    }
    if (activeFilter.state == VisibilityFilter.completed) {
      return todos.state.where((t) => t.complete).toList();
    }
    return todos.state;
  },
  // debugPrintWhenNotifiedPreMessage: 'TodosFilter',
);

final activeTab = RM.inject(() => AppTab.todos);

final Injected<TodosStats> todosStats = RM.injectComputed(
  compute: (_) {
    return TodosStats(
      numCompleted: todos.state.where((t) => t.complete).length,
      numActive: todos.state.where((t) => !t.complete).length,
    );
  },
  // debugPrintWhenNotifiedPreMessage: '',
);

final Injected<Todo> injectedTodo = RM.inject(
  () => null,
  onData: (todo) {
    if (todo != null) {
      todos.state.updateTodo(todo);
    }
  }, //TODO check when throwing
  onError: (e, s) {
    ErrorHandler.showErrorSnackBar(e);
  },
);
