import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* This example is for demo purposes.
*
* We set TodosViewModel to have one global state and one local state. Both live 
* together independently.
*
* Only changes from the last example are commented
*/
@immutable
class TodosViewModel {
  final Injected<List<Todo>> _todosRM = RM.inject(
    () => [
      Todo(id: 'todo-0', description: 'Learn States_rebuilder'),
    ],
  );

  List<Todo> get todos => _todosRM.state;

  bool get isAllCompleted => _todosRM.state.every((todo) => todo.completed);

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
    _todosRM.state = [
      for (final todo in _todosRM.state)
        if (todo.completed == to)
          todo
        else
          todo.copyWith(
            completed: to,
          ),
    ];
    currentTodo.refresh();
  }

  // currentTodo is a object field.
  late final currentTodo = RM.inject<Todo>(
    () => throw UnimplementedError(),
    sideEffects: SideEffects.onData(
      (todo) {
        edit(todo);
      },
    ),
  );
}

// As we want to use two independent instance of TodosViewModel, one global and
// the other local, we inject it using RM.inject
//
// TodosViewModel object instantiated here is the global one
final todosViewModel = RM.inject(() => TodosViewModel());

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Column(
        children: [
          const Title(),
          Expanded(child: Home()),
          Expanded(
            // Create the local TodosViewModel
            child: todosViewModel.inherited(
              stateOverride: () => TodosViewModel(),
              builder: (_) => Home(),
            ),
          ),
        ],
      ),
    );
  }
}

class Home extends ReactiveStatelessWidget {
  Home({Key? key}) : super(key: key);
  final newTodoController = TextEditingController();
  @override
  void didUnmountWidget() {
    newTodoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the scoped (local) TodosViewModel. If no one is found just return
    // the global one
    final _todosViewModel = todosViewModel.of(context, defaultToGlobal: true);
    final todos = _todosViewModel.todos;
    return Scaffold(
      body: ListView(
        controller: ScrollController(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        children: [
          TextField(
            controller: newTodoController,
            decoration: const InputDecoration(
              labelText: 'What needs to be done?',
            ),
            onSubmitted: (value) {
              _todosViewModel.add(value);
              newTodoController.clear();
            },
          ),
          const SizedBox(height: 42),
          const Toolbar(),
          if (todos.isNotEmpty) const Divider(height: 0),
          for (var i = 0; i < todos.length; i++) ...[
            if (i > 0) const Divider(height: 0),
            _todosViewModel.currentTodo.inherited(
              key: ValueKey(todos[i].id),
              stateOverride: () {
                // It important to calculate the the todo item from the state of
                // _todosRM.
                return _todosViewModel.todos[i];
              },
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
    return const Material(
      child: Center(
        child: Text(
          'todos',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.fromARGB(38, 47, 47, 247),
            fontSize: 80,
            fontWeight: FontWeight.w100,
            fontFamily: 'Helvetica Neue',
          ),
        ),
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
    // Get the scoped TodosViewModel
    final _todosViewModel = todosViewModel.of(context, defaultToGlobal: true);
    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: OnBuilder<bool>.create(
              create: () => _todosViewModel.isAllCompleted.inj(),
              builder: (rm) {
                return OnReactive(
                  () {
                    return Row(
                      children: [
                        Checkbox(
                          value: _todosViewModel.isAllCompleted,
                          onChanged: (value) {
                            rm.state = value!;
                            _todosViewModel.toggleAll(value);
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
    final _todosViewModel = todosViewModel.of(context, defaultToGlobal: true);

    final todoRM = _todosViewModel.currentTodo(context);

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
          onPressed: () => _todosViewModel.remove(todoRM.state.id),
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
