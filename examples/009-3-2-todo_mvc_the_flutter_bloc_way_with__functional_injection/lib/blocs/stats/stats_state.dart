import 'package:equatable/equatable.dart';

import 'package:todo_mvc_the_flutter_bloc_way/models/models.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object> get props => [];
}

class StatsLoading extends StatsState {
  const StatsLoading();
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
