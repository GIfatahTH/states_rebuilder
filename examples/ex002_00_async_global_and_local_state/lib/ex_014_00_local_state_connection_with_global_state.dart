import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* In this example we will create a simple todo app. We will use the concept of
* local state and connect it with global state that creates them.
* 
* 
* 
* Example inspired from riverpod official examples.
*/

@immutable
class TodosViewModel {
  // the global injected state to hold the list of todos
  final Injected<List<Todo>> _todosRM = RM.inject(
    () => [
      Todo(id: 'todo-0', description: 'Learn states_rebuilder'),
      Todo(id: 'todo-1', description: 'Learn Riverpod'),
      Todo(id: 'todo-2', description: 'Learn Bloc library'),
    ],
  );
  // getters
  List<Todo> get todos => _todosRM.state;
  bool get isAllCompleted => _todosRM.state.every((todo) => todo.completed);

  // add, edit, remove methods
  void add(String description) {
    _todosRM.state = [
      ..._todosRM.state,
      Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: description,
      )
    ];
  }

  void edit(Todo todoToEdit) {
    _todosRM.state = [
      for (final todo in _todosRM.state)
        if (todo.id == todoToEdit.id) todoToEdit else todo,
    ];
  }

  void remove(String id) {
    _todosRM.state = _todosRM.state.where((todo) => todo.id != id).toList();
  }

  void toggleAll(bool to) {
    // first toggle the state of the global _todosRM
    _todosRM.state = [
      for (final todo in _todosRM.state)
        if (todo.completed == to)
          todo
        else
          todo.copyWith(
            completed: to,
          ),
    ];
    // after todos list update we set the todo local state to recalculate by
    // calling refresh method on the currentTodo state
    //
    // This is the connection from global ==> local
    currentTodo.refresh();
  }

  // As currentTodd is a local state scoped for each List tile, we postpone its
  // initialization until in the widget tree.
  static final currentTodo = RM.inject<Todo>(
    () => throw UnimplementedError(),
    // side effects are triggered when a local state is updated
    sideEffects: SideEffects.onData(
      (todo) {
        // Each time a todo item reactive local state is mutated,
        // we set it to edit the todos list
        //
        // This is the connection from local ==> global
        todosViewModel.edit(todo);
      },
    ),
  );
}

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
  static final newTodoController = TextEditingController();
  @override
  void didUnmountWidget() {
    newTodoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todos = todosViewModel.todos;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        children: [
          const Title(),
          TextField(
            controller: newTodoController,
            decoration: const InputDecoration(
              labelText: 'What needs to be done?',
            ),
            onSubmitted: (value) {
              todosViewModel.add(value);
              newTodoController.clear();
            },
          ),
          const SizedBox(height: 42),
          const Toolbar(),
          if (todos.isNotEmpty) const Divider(height: 0),
          for (var i = 0; i < todos.length; i++) ...[
            if (i > 0) const Divider(height: 0),
            // initialize the local states
            TodosViewModel.currentTodo.inherited(
              stateOverride: () {
                // It important to calculate the the todo item from the state of
                // _todosRM.
                return todosViewModel.todos[i];
              },
              // setting that the local created state will notify the global
              // state currentTodo.
              // connectWithGlobal: true, // default to ture
              builder: (_) => const TodoItem(),
            )
          ],
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

class Toolbar extends ReactiveStatelessWidget {
  const Toolbar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            // OnBuilder.create creates an Injected state and expose it to its child
            child: OnBuilder<bool>.create(
              create: () => todosViewModel.isAllCompleted.inj(),
              builder: (rm) {
                // As OnBuilder screens its children from ReactiveStateless
                // we add OnReactive widget here
                return OnReactive(
                  () {
                    return Row(
                      children: [
                        Checkbox(
                          value: todosViewModel.isAllCompleted,
                          onChanged: (value) {
                            rm.state = value!;
                            todosViewModel.toggleAll(value);
                          },
                        ),
                        Text(
                          'Toggle All todos to ${rm.state ? 'uncompleted' : 'completed'}',
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TodoItem extends ReactiveStatelessWidget {
  const TodoItem({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final todoRM = TodosViewModel.currentTodo(context);

    return Material(
      color: Colors.white,
      elevation: 6,
      child: ListTile(
        leading: Checkbox(
          value: todoRM.state.completed,
          onChanged: (value) {
            todoRM.state = todoRM.state.copyWith(
              completed: value,
            );
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => todosViewModel.remove(todoRM.state.id),
        ),
        title: Text(todoRM.state.description),
      ),
    );
  }
}

class Todo {
  Todo({
    required this.description,
    required this.id,
    this.completed = false,
  });

  final String id;
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
