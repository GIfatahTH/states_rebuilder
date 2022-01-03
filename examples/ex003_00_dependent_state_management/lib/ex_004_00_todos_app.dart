import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:uuid/uuid.dart';

/** Models **/

/// The different ways to filter the list of todos
enum TodoFilter {
  all,
  active,
  completed,
}

const _uuid = Uuid();

/// A read-only description of a todo-item
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

/* View models*/
abstract class TodosRepository {
  Future<List> getTodos();
  Future<Todo> addTodo(Todo todo);
  Future<bool> edit(Todo todo);
  Future<bool> remove(int index);
  Future<bool> toggleTodos(bool to);
}

@immutable
class TodosModelView {
  TodosModelView();
  final Injected<List<Todo>> _todosRM = RM.inject(
    () => [
      Todo(id: 'todo-0', description: 'hi'),
      Todo(id: 'todo-1', description: 'hello'),
      Todo(id: 'todo-2', description: 'bonjour'),
    ],
  );

  late final _todoListFilterRM = RM.inject<TodoFilter>(
    () => TodoFilter.all,
  );
  TodoFilter get filter => _todoListFilterRM.state;
  set filter(TodoFilter value) => _todoListFilterRM.state = value;

  late final _uncompletedTodosCount = RM.inject<int>(
    () {
      final completed = _todosRM.state.where((todo) => !todo.completed);
      return completed.length;
    },
    dependsOn: DependsOn({_todosRM}),
  );
  int get uncompletedTodosCount => _uncompletedTodosCount.state;
  bool get isAllCompleted => uncompletedTodosCount == 0;

  late final Injected<List<Todo>> _filteredTodosRM = RM.inject(
    () {
      switch (filter) {
        case TodoFilter.completed:
          return _todosRM.state.where((todo) => todo.completed).toList();
        case TodoFilter.active:
          return _todosRM.state.where((todo) => !todo.completed).toList();
        case TodoFilter.all:
          return _todosRM.state;
      }
    },
    dependsOn: DependsOn({_todosRM, _todoListFilterRM}),
  );
  List<Todo> get filteredTodos => [..._filteredTodosRM.state];

  void add(String description) {
    _todosRM.state = [
      ..._todosRM.state,
      Todo(
        id: _uuid.v4(),
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

  void remove(int index) {
    _todosRM.state = [..._todosRM.state]..removeAt(index);
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

  static final currentTodo = RM.inject<CurrentTodo>(
    () => throw UnimplementedError(),
    sideEffects: SideEffects.onData(
      (todo) {
        todoList.edit(todo.value);
      },
    ),
  );
}

final todoList = TodosModelView();

@immutable
class CurrentTodo {
  final Todo value;
  final FocusNode itemFocusNode;
  final FocusNode textFocusNode;
  final TextEditingController textEditingController;
  final bool isEditable;
  const CurrentTodo({
    required this.value,
    required this.itemFocusNode,
    required this.textFocusNode,
    required this.textEditingController,
    this.isEditable = false,
  });

  CurrentTodo copyWith({
    Todo? todo,
  }) {
    return CurrentTodo(
      value: todo ?? value,
      itemFocusNode: itemFocusNode,
      textFocusNode: textFocusNode,
      textEditingController: textEditingController,
    );
  }
}

//

/// Some keys used for testing
final addTodoKey = UniqueKey();
final activeFilterKey = UniqueKey();
final completedFilterKey = UniqueKey();
final allFilterKey = UniqueKey();
final toggleAllToComplete = UniqueKey();

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

final newTodoController = TextEditingController();

class Home extends ReactiveStatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todos = todoList.filteredTodos;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            const Title(),
            TextField(
              key: addTodoKey,
              controller: newTodoController,
              decoration: const InputDecoration(
                labelText: 'What needs to be done?',
              ),
              onSubmitted: (value) {
                todoList.add(value);
                newTodoController.clear();
              },
            ),
            const SizedBox(height: 42),
            const Toolbar(),
            if (todos.isNotEmpty) const Divider(height: 0),
            for (var i = 0; i < todos.length; i++) ...[
              if (i > 0) const Divider(height: 0),
              Dismissible(
                key: ValueKey(todos[i].id),
                onDismissed: (_) {
                  todoList.remove(i);
                },
                child: TodosModelView.currentTodo.inherited(
                  stateOverride: () {
                    return CurrentTodo(
                      value: todoList.filteredTodos[i],
                      itemFocusNode: FocusNode(),
                      textFocusNode: FocusNode(),
                      textEditingController: TextEditingController(),
                    );
                  },
                  builder: (_) => const TodoItem(),
                ),
              )
            ],
          ],
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
    final filter = todoList.filter;

    Color? textColorFor(TodoFilter value) {
      return filter == value ? Colors.blue : Colors.black;
    }

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: OnBuilder<bool>.create(
              create: () => todoList.isAllCompleted.inj(),
              builder: (rm) {
                return Tooltip(
                  key: allFilterKey,
                  message:
                      'Toggle All todos to ${rm.state ? 'uncompleted' : 'completed'}',
                  child: Checkbox(
                    value: todoList.isAllCompleted,
                    onChanged: (value) {
                      rm.state = value!;
                      todoList.toggleAll(value);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Text(
              '${todoList.uncompletedTodosCount} items left',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Tooltip(
            key: allFilterKey,
            message: 'All todos',
            child: TextButton(
              onPressed: () => todoList.filter = TodoFilter.all,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor:
                    MaterialStateProperty.all(textColorFor(TodoFilter.all)),
              ),
              child: const Text('All'),
            ),
          ),
          Tooltip(
            key: activeFilterKey,
            message: 'Only uncompleted todos',
            child: TextButton(
              onPressed: () => todoList.filter = TodoFilter.active,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: MaterialStateProperty.all(
                  textColorFor(TodoFilter.active),
                ),
              ),
              child: const Text('Active'),
            ),
          ),
          Tooltip(
            key: completedFilterKey,
            message: 'Only completed todos',
            child: TextButton(
              onPressed: () => todoList.filter = TodoFilter.completed,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: MaterialStateProperty.all(
                  textColorFor(TodoFilter.completed),
                ),
              ),
              child: const Text('Completed'),
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
  const TodoItem({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TodosModelView.currentTodo.of(context);
    final todoRM = TodosModelView.currentTodo(context);

    final itemFocusNode = todoRM.state.itemFocusNode;
    final isFocused = itemFocusNode.hasFocus;
    final textFocusNode = todoRM.state.textFocusNode;
    final textEditingController = todoRM.state.textEditingController;
    final todo = todoRM.state.value;
    return Material(
      color: Colors.white,
      elevation: 6,
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focused) {
          if (isFocused != focused) {
            todoRM.notify();
          }
          if (todo.description == textEditingController.text) return;

          if (focused) {
            textEditingController.text = todo.description;
          } else {
            // Commit changes only when the textField is unfocused, for performance
            todoRM.state = todoRM.state.copyWith(
              todo: todo.copyWith(
                description: textEditingController.text,
              ),
            );
          }
        },
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFocusNode.requestFocus();
          },
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) {
              todoRM.state = todoRM.state.copyWith(
                todo: todo.copyWith(
                  completed: value,
                ),
              );
            },
          ),
          title: isFocused
              ? TextField(
                  focusNode: textFocusNode,
                  controller: textEditingController,
                )
              : Text(todo.description),
        ),
      ),
    );
  }
}
