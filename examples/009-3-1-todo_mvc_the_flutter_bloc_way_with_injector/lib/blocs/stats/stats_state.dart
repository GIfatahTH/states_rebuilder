import 'package:equatable/equatable.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todo_mvc_the_flutter_bloc_way/blocs/blocs.dart';
import 'package:todo_mvc_the_flutter_bloc_way/models/models.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object> get props => [];
}

class StatsLoading extends StatsState {
  StatsLoading(ReactiveModel<TodosState> todosStateRM) {
    todosStateRM.listenToRM(
      (rm) {
        if (rm.hasData && rm.state is TodosLoaded) {
          RM.get<StatsState>().setState(
                (currentState) => StatsLoaded.updateStats(
                  currentState,
                  (rm.state as TodosLoaded).todos,
                ),
                silent: true,
              );
        }
      },
    );
  }
}

class StatsLoaded extends StatsState {
  final int numActive;
  final int numCompleted;

  const StatsLoaded(
    this.numActive,
    this.numCompleted,
  );

  @override
  List<Object> get props => [numActive, numCompleted];

  static StatsLoaded updateStats(StatsState currentState, List<Todo> todos) {
    final numActive = todos.where((todo) => !todo.complete).toList().length;
    final numCompleted = todos.where((todo) => todo.complete).toList().length;
    return StatsLoaded(
      numActive,
      numCompleted,
    );
  }

  @override
  String toString() {
    return 'StatsLoaded { numActive: $numActive, numCompleted: $numCompleted }';
  }
}
