import 'package:states_rebuilder/states_rebuilder.dart';

import './ui/common/enums.dart';
import 'domain/entities/todo.dart';
import 'service/common/enums.dart';
import 'service/todos_state.dart';

import 'sqflite.dart';
import 'ui/exceptions/error_handler.dart';

final todos = RM.injectCRUD<Todo, Query>(
  () => SqfliteRepository(),
  id: (todo) => todo.id,
  param: () => Query(filter: VisibilityFilter.all),
  onError: (e, s) => ErrorHandler.showErrorSnackBar(e),
  undoStackLength: 1,
  // debugPrintWhenNotifiedPreMessage: 'todos',
);

final activeTodosCount = RM.injectFuture<int>(
  () => todos.getRepoAs<SqfliteRepository>().count(
        Query(filter: VisibilityFilter.active),
      ),
  dependsOn: DependsOn({todos}),
);

final completedTodosCount = RM.injectFuture<int>(
  () => todos.getRepoAs<SqfliteRepository>().count(
        Query(filter: VisibilityFilter.completed),
      ),
  dependsOn: DependsOn({todos}),
);

final activeFilter = RM.inject(() => VisibilityFilter.all);

final activeTab = RM.inject(() => AppTab.todos);

final Injected<Todo> todoItem = RM.inject(
  () =>
      null, //null here. It will be overridden when inflating TodoItem widget in ListView builder
  onData: (todo) {
    //called when any todoItem is updated
    if (todo != null) {
      todos.crud.update(todo);
    }
  },
  onError: (e, s) {
    ErrorHandler.showErrorSnackBar(e);
  },
);
