import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Optimistic update a list of items
*/
@immutable
class TodosViewModel {
  TodosRepository get repository => todosRepository.state;

  late final Injected<List<Todo>> _todosRM = RM.injectFuture(
    () => repository.getTodos(),
    sideEffects: SideEffects.onError(
      (err, refresh) {
        RM.scaffold.showSnackBar(
          SnackBar(
            content: Text(err.message),
            action: SnackBarAction(
              label: 'Try again',
              onPressed: refresh,
            ),
          ),
        );
      },
    ),
    debugPrintWhenNotifiedPreMessage: '',
    toDebugString: (s) => s?.length,
  );

  List<Todo> get todos => _todosRM.state;
  late final whenTodosState = _todosRM.onOrElse;
  // No need for _isWaitingForAddTodo as we want to update optimistically
  // final _isWaitingForAddTodo = false.inj();
  // bool get isWaitingForAddTodo => _isWaitingForAddTodo.state;

  void addTodo(String description) {
    // cache the todo to add
    final todoToAdd = Todo(
      description: description,
      // we have the id form the backend
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _todosRM.setState(
      (s) async* {
        // use stream
        //
        // yield the updated state
        yield [
          ..._todosRM.state,
          todoToAdd,
        ];
        // call the server to add the todo
        // we are optimistic and we expect to add it without problem
        await repository.addTodo(todoToAdd);
      },
      stateInterceptor: (current, next) {
        // skip the waiting state
        if (next.isWaiting) return current;
        if (next.hasError) {
          // if the server fails to add the todo
          // just return the last state before update.
          return next.copyWith(
            data: next.state.where((todo) => todo.id != todoToAdd.id).toList(),
          );
        }
      },
    );
  }
}

final todosRepository = RM.inject(() => TodosRepository());
final todosViewModel = TodosViewModel();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends ReactiveStatelessWidget {
  const Home({Key? key}) : super(key: key);
  static late TextEditingController newTodoController;
  @override
  void didMountWidget(BuildContext context) {
    newTodoController = TextEditingController();
  }

  @override
  void didUnmountWidget() {
    newTodoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Title(),
          Expanded(
            child: todosViewModel.whenTodosState(
              onWaiting: () => const Center(
                child: CircularProgressIndicator(),
              ),
              orElse: (todos) {
                return ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  children: [
                    TextField(
                      controller: newTodoController,
                      decoration: const InputDecoration(
                        labelText: 'What needs to be done?',
                      ),
                      onSubmitted: (value) {
                        todosViewModel.addTodo(value);
                        newTodoController.clear();
                      },
                    ),
                    const SizedBox(height: 42),
                    if (todos.isNotEmpty) const Divider(height: 0),
                    for (var i = 0; i < todos.length; i++) ...[
                      if (i > 0) const Divider(height: 0),
                      TodoItem(todo: todosViewModel.todos[i]),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Title extends ReactiveStatelessWidget {
  const Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'todos',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(38, 47, 47, 247),
        fontSize: 100,
        fontWeight: FontWeight.w100,
        fontFamily: 'Helvetica Neue',
      ),
    );
  }
}

class TodoItem extends ReactiveStatelessWidget {
  const TodoItem({Key? key, required this.todo}) : super(key: key);

  final Todo todo;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (value) {},
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {},
        ),
        title: Text(todo.description),
      ),
    );
  }
}

class TodosRepository {
  final List<Todo> todos = [
    Todo(id: 'todo-0', description: 'Learn states_rebuilder'),
    Todo(id: 'todo-1', description: 'Learn Riverpod'),
    Todo(id: 'todo-2', description: 'Learn Bloc library'),
  ];

  Future<List<Todo>> getTodos() async {
    await Future.delayed(const Duration(seconds: 1));
    return [...todos];
  }

  Future<Todo> addTodo(Todo todo) async {
    await Future.delayed(const Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('Bad network!');
    }
    todos.add(
      todo.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    );

    return todo;
  }
}

class Todo {
  Todo({
    required this.description,
    required this.id,
    this.completed = false,
  });

  final String? id;
  final String description;
  final bool completed;

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }

  Todo copyWith({
    String? id,
    String? description,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}
