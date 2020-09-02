// import 'dart:async';
// import 'package:meta/meta.dart';
// import 'package:bloc/bloc.dart';
// import 'package:bloc_library/blocs/blocs.dart';

// class StatsBloc extends Bloc<StatsEvent, StatsState> {
//   final TodosBloc todosBloc;
//   StreamSubscription todosSubscription;

//   StatsBloc({@required this.todosBloc}) {
//     todosSubscription = todosBloc.listen((state) {
//       if (state is TodosLoaded) {
//         add(UpdateStats(state.todos));
//       }
//     });
//   }

//   @override
//   StatsState get initialState => StatsLoading();

//   @override
//   Stream<StatsState> mapEventToState(StatsEvent event) async* {
//     if (event is UpdateStats) {
//       var numActive =
//           event.todos.where((todo) => !todo.complete).toList().length;
//       var numCompleted =
//           event.todos.where((todo) => todo.complete).toList().length;
//       yield StatsLoaded(numActive, numCompleted);
//     }
//   }

//   @override
//   Future<void> close() {
//     todosSubscription?.cancel();
//     return super.close();
//   }
// }
