import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/todo_repository.dart';
import 'service/interfaces/i_todo_repository.dart';
import 'service/todos_service.dart';
import 'ui/common/enums.dart';
import 'ui/exceptions/error_handler.dart';

final sharedPreferences = RM.injectFuture<SharedPreferences>(
  () async {
    return SharedPreferences.getInstance();
  },
);

//Inject TodosRepository via its interface ITodosRepository
//this give us the ability to mock the TodosRepository in test.
final todosRepository = RM.injectFuture<ITodosRepository>(
  () async {
    //await until the SharedPreferences is initialized to create an instance
    //of TodosRepository
    return TodosRepository(
      prefs: await sharedPreferences.stateAsync,
    );
  },
  onError: (e, s) => print(e),
);

final todosService = RM.injectFuture<TodosService>(
  () async {
    //await until the TodosRepository is initialized to create an instance
    //of TodosService
    return TodosService(
      await todosRepository.stateAsync,
    );
  },
  //If the TodosService throws, error will be captured and treated here
  onError: (e, s) {
    print(e);

    ErrorHandler.showErrorDialog(RM.context, e);
  },
);

//This will optimized the rebuild so that the filteredTodos will
//be recalculated only when the list of todos changes.
final filteredTodos = RM.injectComputed(
  compute: (_) => todosService.state.todos,
);

final appTab = RM.inject(() => AppTab.todos);
