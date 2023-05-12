import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Pessimistically update a list of items
*/
@immutable
class TodosViewModel {
  TodosRepository get repository => todosRepository.state;

  late final Injected<List<Todo>> _todosRM = RM.injectFuture(
    () => repository.getTodos(),
    sideEffects: SideEffects.onError(
      (err, refresh) {
        // Show snackBar on update error
        RM.scaffold.showSnackBar(
          SnackBar(
            content: Text(err.message),
            action: SnackBarAction(
              label: 'Try again',
              // we can refresh the error state
              onPressed: refresh,
            ),
          ),
        );
      },
    ),
  );

  List<Todo> get todos => _todosRM.state;
  late final whenTodosState = _todosRM.onOrElse;
  //
  // As we want to show a CircularProgressIndication in the bottom of the list
  // while waiting for an item to be added, we use a dedicate bool state for this
  final _isWaitingForAddTodo = false.inj();
  bool get isWaitingForAddTodo => _isWaitingForAddTodo.state;

  void addTodo(String description) {
    _todosRM.setState(
      (s) async {
        final addTodo = await repository.addTodo(
          Todo(
            description: description,
            // One use case of pessimistic update is the case when we want to get
            // the id of the added item from the server
            id: null,
          ),
        );

        return [
          ..._todosRM.state,
          // add the new todo item with the new id
          addTodo,
        ];
      },
      stateInterceptor: (current, next) {
        // ignore waiting state for _todosRM
        if (next.isWaiting) {
          // instead set the _isWaitingForAddTodo to ture
          _isWaitingForAddTodo.state = true;
          return current;
        }
        // in all other cases set the _isWaitingForAddTodo to false
        _isWaitingForAddTodo.state = false;
        return null;
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
                // Will be displayed only when we are fetching for the list of todos
                // and not when we adding a todo
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
                    // if (todosViewModel.isWaitingForAddTodo)
                    //   const Center(
                    //     child: CircularProgressIndicator(),
                    //   ),
                    //
                    // For rebuild optimization we wrap this part with OnReactive
                    OnReactive(
                      () {
                        if (todosViewModel.isWaitingForAddTodo) {
                          // This will be displayed only when we are waiting for
                          // a todo to be added.
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Todo &&
        other.id == id &&
        other.description == description &&
        other.completed == completed;
  }

  @override
  int get hashCode => id.hashCode ^ description.hashCode ^ completed.hashCode;
}
