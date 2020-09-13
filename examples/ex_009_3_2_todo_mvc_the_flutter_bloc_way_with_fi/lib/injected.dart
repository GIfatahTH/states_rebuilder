import 'package:states_rebuilder/states_rebuilder.dart';

import 'blocs/blocs.dart';
import 'blocs/todos/todos_state.dart';

Injected<TodosState> todosState;

final filteredTodosState = RM.injectComputed<FilteredTodosState>(
  initialState: FilteredTodosLoading(),
  compute: (state) {
    if (todosState.state is TodosLoaded) {
      return FilteredTodosLoaded.updateTodos(
        state,
        (todosState.state as TodosLoaded).todos,
      );
    }
    return state;
  },
  // onDispose: (_) => todosState.dispose(),
);

final statsState = RM.injectComputed<StatsState>(
  initialState: StatsLoading(),
  compute: (state) {
    if (todosState.state is TodosLoaded) {
      return StatsLoaded.updateStats(
        state,
        (todosState.state as TodosLoaded).todos,
      );
    }
    return state;
  },
);

final appTabState = RM.inject(() => AppTabState());
