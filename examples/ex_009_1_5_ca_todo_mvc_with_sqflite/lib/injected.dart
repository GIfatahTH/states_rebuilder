import 'package:states_rebuilder/states_rebuilder.dart';

import './ui/common/enums.dart';
import 'domain/entities/todo.dart';
import 'service/common/enums.dart';
import 'service/todos_state.dart';

import 'sqflite.dart';
import 'ui/exceptions/error_handler.dart';

final InjectedCRUD<Todo, TodoParam> todos = RM.injectCRUD<Todo, TodoParam>(
  () => SqfliteRepository(),
  onError: (e, s) => ErrorHandler.showErrorSnackBar(e),
  onInitialized: (_) {
    todos.crud.read(param: () => TodoParam(filter: VisibilityFilter.all));
  },
  undoStackLength: 1,
  debugPrintWhenNotifiedPreMessage: 'todos',
);

final activeTodosCount = RM.injectFuture<int>(
  () async {
    final repo = await todos.getRepoAs<SqfliteRepository>();
    return repo.count(
      TodoParam(filter: VisibilityFilter.active),
    );
  },
  dependsOn: DependsOn({todos}),
);

final completedTodosCount = RM.injectFuture<int>(
  () async {
    final repo = await todos.getRepoAs<SqfliteRepository>();

    return repo.count(
      TodoParam(filter: VisibilityFilter.completed),
    );
  },
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
