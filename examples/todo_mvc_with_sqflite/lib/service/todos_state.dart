import 'package:todo_mvc_with_sqflite/sqflite.dart';

import '../domain/entities/todo.dart';
import '../injected.dart';

extension ListTodoX on List<Todo> {
  Future<void> toggleAll() {
    final allComplete = this.every((e) => e.complete);
    todos.crud.update(
      where: (todo) => todo.complete == allComplete,
      set: (todo) => todo.copyWith(complete: !allComplete),
      param: () => Query(operation: 'toggleAll'),
      onStateMutation: () {
        //The todos list state is changed after toggling
        //Tell todoItem to refresh their state and re-invoke their stateOverride callback
        //Only todoItem that are changed will be notified to rebuild
        todoItem.refresh();
      },
      onCRUD: (_) {
        todosStat.refresh();
      },
    );
  }

  Future<void> clearCompleted() async {
    await todos.crud.delete(
      where: (todo) => todo.complete,
      param: () => Query(operation: 'deleteCompleted'),
      onCRUD: (_) => todosStat.refresh(),
    );
  }
}
