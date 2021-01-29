import 'package:states_rebuilder/states_rebuilder.dart';

import './ui/common/enums.dart';
import 'domain/entities/todo.dart';
import 'service/common/enums.dart';
import 'service/todos_state.dart';
import 'sqflite.dart';
import 'ui/exceptions/error_handler.dart';

final todos = RM.injectCRUD<Todo, Query>(
  () => SqfliteRepository(),
  readOnInitialization: true,
  param: () => Query(filter: VisibilityFilter.all),
  onError: (e, s) => ErrorHandler.showErrorSnackBar(e),
  // debugPrintWhenNotifiedPreMessage: 'todos',
);

class TodosStat {
  final int active;
  final int completed;
  TodosStat({
    this.active = 0,
    this.completed = 0,
  });
}

final todosStat = RM.injectFuture<TodosStat>(
  () async {
    final todosRepo = await todos.getRepoAs<SqfliteRepository>();
    final active = todosRepo.count(
      Query(filter: VisibilityFilter.active),
    );
    final completed = todosRepo.count(
      Query(filter: VisibilityFilter.completed),
    );
    return TodosStat(
      active: await active,
      completed: await completed,
    );
  },
  initialState: TodosStat(active: 0, completed: 0),
  debugPrintWhenNotifiedPreMessage: '',
);

final activeFilter = RM.inject(() => VisibilityFilter.all);

final activeTab = RM.inject(() => AppTab.todos);

final Injected<Todo> todoItem = RM.inject(
  () =>
      null, //null here. It will be overridden when inflating TodoItem widget in ListView builder
  onData: (todo) {
    //called when any todoItem is updated
    if (todo != null) {
      todos.crud.update(
        where: (t) => t.id == todo.id,
        set: (t) => todo,
      );
    }
  },
  onError: (e, s) {
    ErrorHandler.showErrorSnackBar(e);
  },
);
