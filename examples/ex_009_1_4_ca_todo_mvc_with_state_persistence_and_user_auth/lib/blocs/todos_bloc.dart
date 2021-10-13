import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../data_source/firebase_todos_repository.dart';
import '../domain/entities/todo.dart';
import '../domain/value_object/todos_stats.dart';
import '../ui/exceptions/error_handler.dart';
import '../ui/localization/localization.dart';
import 'auth_bloc.dart';
import 'common/enums.dart';

@immutable
class TodosBloc {
  final InjectedCRUD<Todo, String> todosRM = RM.injectCRUD<Todo, String>(
    () => FireBaseTodosRepository(),
    param: () => '__Todos__/${authBloc.user!.userId}',
    readOnInitialization: true,
    sideEffects: SideEffects.onError(
      (e, r) {
        ErrorHandler.showErrorSnackBar(e);
      },
    ),
    debugPrintWhenNotifiedPreMessage: 'todos',
  );
  List<Todo> get todos => todosRM.state;
  Future<Todo?> createTodo(
    Todo todo, {
    bool isOptimistic = true,
  }) {
    return todosRM.crud.create(
      todo,
      isOptimistic: isOptimistic,
    );
  }

  void toggleAll() {
    final allComplete = todos.every((e) => e.complete);
    todosRM.crud.update(
      where: (t) => t.complete == allComplete,
      set: (t) => t.copyWith(complete: !allComplete),
    );
  }

  void clearCompleted() {
    todosRM.crud.delete(where: (t) => t.complete);
  }

  void removeTodo(Todo todo) {
    todosRM.crud.delete(
      where: (t) => todo.id == t.id,
    );

    RM.scaffold.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          i18n.of(RM.context!).todoDeleted(todo.task),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: i18n.of(RM.context!).undo,
          onPressed: () {
            createTodo(todo);
          },
        ),
      ),
    );
  }

  final activeFilter = RM.inject(() => VisibilityFilter.all);

  late final Injected<List<Todo>> todosFiltered = RM.inject(
    () {
      if (activeFilter.state == VisibilityFilter.active) {
        return todos.where((t) => !t.complete).toList();
      }
      if (activeFilter.state == VisibilityFilter.completed) {
        return todos.where((t) => t.complete).toList();
      }
      return [...todos];
    },
    sideEffects: SideEffects(
      dispose: () {
        print('filter todos disposed');
      },
    ),
    dependsOn: DependsOn({activeFilter, todosRM}),
    debugPrintWhenNotifiedPreMessage: 'filterTodos',
  );

  late final Injected<TodosStats> todosStats = RM.inject(
    () => TodosStats(
      numCompleted: todos.where((t) => t.complete).length,
      numActive: todos.where((t) => !t.complete).length,
    ),
    // initialState: TodosStats(numCompleted: 0, numActive: 0),
    dependsOn: DependsOn({todosRM}),
    // middleSnapState: (middleSnap) {
    //   middleSnap.print(
    //     preMessage: 'stats',
    //   );
    // },
  );

  int get numCompleted => todosStats.state.numCompleted;
  int get numActive => todosStats.state.numActive;
  bool get allComplete => todosStats.state.allComplete;
}

final todosBloc = TodosBloc();
