import 'dart:convert' as convert;

import 'package:states_rebuilder/states_rebuilder.dart';

import '../../data_source/firebase_todos_repository.dart';
import '../../domain/entities/todo.dart';
import '../../domain/value_object/todos_stats.dart';
import '../../service/common/enums.dart';
import '../common/enums.dart';
import '../exceptions/error_handler.dart';
import 'injected_user.dart';

extension ListTodoX on List<Todo> {
  List<Todo> addTodo(Todo todo) {
    return List<Todo>.from(this)..add(todo);
  }

  List<Todo> updateTodo(Todo todo) {
    return map((t) => t.id == todo.id ? todo : t).toList();
  }

  List<Todo> deleteTodo(Todo todo) {
    return List<Todo>.from(this)..remove(todo);
  }

  List<Todo> toggleAll() {
    final allComplete = this.every((e) => e.complete);
    return map(
      (t) => t.copyWith(complete: !allComplete),
    ).toList();
  }

  List<Todo> clearCompleted() {
    return List<Todo>.from(this)
      ..removeWhere(
        (t) => t.complete,
      );
  }

  ///Parsing the state
  String toJson() => convert.json.encode(this);
  static List<Todo> fromJson(json) {
    final result = convert.json.decode(json ?? '[]') as List<dynamic>;
    if (result == null) {
      return [];
    }
    return result.map((m) => Todo.fromJson(m)).toList();
  }
}

final Injected<List<Todo>> todos = RM.inject(
  () => [],
  persist: () => PersistState(
    key: '__Todos__/${user.state.userId}',
    toJson: (todos) => todos.toJson(),
    fromJson: (json) => ListTodoX.fromJson(json),
    persistStateProvider: FireBaseTodosRepository(
      authToken: user.state.token.token,
    ),
    // debugPrintOperations: true,
  ),
  onError: (e, s) {
    todoItem.refresh();
    ErrorHandler.showErrorSnackBar(e);
  },
  onData: (_) {
    // todoItem.refresh();
  },
  debugPrintWhenNotifiedPreMessage: 'todos',
);

final activeFilter = RM.inject(() => VisibilityFilter.all);

final Injected<List<Todo>> todosFiltered = RM.inject(
  () {
    if (activeFilter.state == VisibilityFilter.active) {
      return todos.state.where((t) => !t.complete).toList();
    }
    if (activeFilter.state == VisibilityFilter.completed) {
      return todos.state.where((t) => t.complete).toList();
    }
    return todos.state;
  },
  dependsOn: DependsOn({activeFilter, todos}),
  debugPrintWhenNotifiedPreMessage: 'TodosFilter',
);

final Injected<TodosStats> todosStats = RM.inject(
  () => TodosStats(
    numCompleted: todos.state.where((t) => t.complete).length,
    numActive: todos.state.where((t) => !t.complete).length,
  ),
  dependsOn: DependsOn({todos}),

  // debugPrintWhenNotifiedPreMessage: '',
);

final activeTab = RM.inject(() => AppTab.todos);

final Injected<Todo> todoItem = RM.inject(
  () => null,
  onData: (t) {
    todos.setState(
      (s) {
        return s.updateTodo(t);
      },
    );
  },
);
