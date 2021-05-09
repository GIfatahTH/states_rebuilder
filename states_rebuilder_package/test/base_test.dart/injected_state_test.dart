import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    // counter.dispose();
  });
  testWidgets(
    'WHEN1'
    'THEN',
    (tester) async {
      // expect(counter.state, 0);
      // counter.increment();
      // expect(counter.state, 1);
      // counter.incrementAsync();
      // expect(counter.isWaiting, true);
      // await tester.pump(Duration(seconds: 1));
      // expect(counter.hasData, true);
      // expect(counter.state, 10);
    },
  );

  // testWidgets(
  //   'WHEN2'
  //   'THEN',
  //   (tester) async {
  //     expect(counter.state, 0);
  //     counter.increment();
  //     expect(counter.state, 1);
  //     counter.incrementAsync();
  //     expect(counter.isWaiting, true);
  //     await tester.pump(Duration(seconds: 1));
  //     expect(counter.hasData, true);
  //     expect(counter.state, 10);
  //     counter.param = 10;
  //     expect(counter.state, 20);
  //     counter.refresh();
  //     expect(counter.state, 0);
  //   },
  // );
  // testWidgets(
  //   'WHEN'
  //   'THEN',
  //   (tester) async {
  //     expect(todos.isWaiting, true);
  //     expect(filteredTodos.isWaiting, true);
  //     await tester.pump(Duration(seconds: 1));
  //     expect(todos.hasData, true);
  //     expect(filteredTodos.hasData, true);
  //     expect(todos.state.length, 3);
  //     expect(filteredTodos.state.length, 3);
  //     filteredTodos.filter = Filter.active;
  //     expect(filteredTodos.state.length, 2);
  //     todos.addTodo(Todo(
  //       id: '4',
  //       title: 'Todo 4',
  //       isCompleted: false,
  //     ));
  //     expect(todos.state.length, 4);
  //     expect(filteredTodos.state.length, 3);
  //   },
  // );
}

// final counter = Counter();

// class Counter extends InjectedState<int> {
//   int stateCreator() => 0;
//   int? _param;
//   set param(int p) {
//     if (p == _param) {
//       return;
//     }
//     _param = p;
//     state = state + p;
//   }

//   @override
//   void onInitialized(int? s) {
//     print('onInitialized');
//   }

//   @override
//   void onData(int s) {
//     print('onData $s');
//   }

//   @override
//   On<void>? get onSetState => On(() => print('onSetState'));

//   void increment() => state++;

//   void incrementAsync() async {
//     setState((s) => Future.delayed(Duration(seconds: 1), () => 10));
//   }
// }

// class Todo {
//   final String id;
//   final String title;
//   final bool isCompleted;
//   Todo({
//     required this.id,
//     required this.title,
//     required this.isCompleted,
//   });
// }

// class TodosRepository {
//   Future<List<Todo>> getTodos() async {
//     await Future.delayed(Duration(seconds: 1));
//     return [
//       Todo(
//         id: '1',
//         title: 'Todo 1',
//         isCompleted: false,
//       ),
//       Todo(
//         id: '2',
//         title: 'Todo 2',
//         isCompleted: true,
//       ),
//       Todo(
//         id: '3',
//         title: 'Todo 3',
//         isCompleted: false,
//       ),
//     ];
//   }
// }

// final repository = RM.inject(() => TodosRepository());

// class Todos extends InjectedState<List<Todo>> {
//   @override
//   Future<List<Todo>> stateCreator() => repository.state.getTodos();

//   void addTodo(Todo todo) {
//     state = [...state, todo];
//   }
// }

// final todos = Todos();

// enum Filter { all, active, done }

// class FilteredTodos extends InjectedState<List<Todo>> {
//   FilteredTodos() : super(dependsOn: DependsOn({todos}));

//   @override
//   List<Todo> stateCreator() {
//     if (_filter == Filter.active) {
//       return todos.state.where((e) => !e.isCompleted).toList();
//     }
//     if (_filter == Filter.done) {
//       return todos.state.where((e) => e.isCompleted).toList();
//     }
//     return [...todos.state];
//   }

//   Filter _filter = Filter.all;
//   set filter(Filter f) {
//     if (f == _filter) {
//       return;
//     }
//     _filter = f;
//     refresh();
//   }
// }

// final filteredTodos = FilteredTodos();
