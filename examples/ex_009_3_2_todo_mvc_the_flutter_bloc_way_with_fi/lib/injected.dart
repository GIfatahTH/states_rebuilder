import 'package:states_rebuilder/states_rebuilder.dart';

import 'blocs/blocs.dart';
import 'blocs/todos/todos_state.dart';

Injected<TodosState> todosState;

final filteredTodosState = RM.inject<FilteredTodosState>(() {
  if (todosState.state is TodosLoaded) {
    return FilteredTodosLoaded.updateTodos(
      filteredTodosState.state,
      (todosState.state as TodosLoaded).todos,
    );
  }
  return filteredTodosState.state;
},
    initialState: FilteredTodosLoading(),
    dependsOn: DependsOn(
      {todosState},
    )
    // onDispose: (_) => todosState.dispose(),
    );

final statsState = RM.inject<StatsState>(
  () {
    if (todosState.state is TodosLoaded) {
      return StatsLoaded.updateStats(
        statsState.state,
        (todosState.state as TodosLoaded).todos,
      );
    }
    return statsState.state;
  },
  initialState: StatsLoading(),
  dependsOn: DependsOn({todosState}),
);

final appTabState = RM.inject(() => AppTabState());
