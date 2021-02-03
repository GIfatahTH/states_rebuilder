import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todos_repository_core/todos_repository_core.dart';

import 'blocs/blocs.dart';
import 'blocs/todos/todos_state.dart';

Injected<TodosRepository> todosRepository;
final Injected<TodosState> todosState = RM.injectFuture(
  () => todosState.stateAs<TodosLoading>().loadTodos(),
  initialState: TodosLoading(todosRepository.state),
);

final filteredTodosState = RM.inject<FilteredTodosState>(
  () {
    if (todosState.state is TodosLoaded) {
      return FilteredTodosLoaded.updateTodos(
        filteredTodosState.state,
        todosState.stateAs<TodosLoaded>().todos,
      );
    }
    return filteredTodosState.state;
  },
  initialState: FilteredTodosLoading(),
  dependsOn: DependsOn({todosState}),
);

final statsState = RM.inject<StatsState>(
  () {
    if (todosState.state is TodosLoaded) {
      return StatsLoaded.updateStats(
        statsState.state,
        todosState.stateAs<TodosLoaded>().todos,
      );
    }
    return statsState.state;
  },
  initialState: StatsLoading(),
  dependsOn: DependsOn({todosState}),
);

final appTabState = RM.inject(() => AppTabState());
