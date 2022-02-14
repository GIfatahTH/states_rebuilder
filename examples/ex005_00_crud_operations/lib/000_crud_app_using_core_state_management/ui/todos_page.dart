import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../blocs/todos_bloc.dart';
import '../models/todo_filter.dart';

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

class Home extends ReactiveStatelessWidget {
  const Home({Key? key}) : super(key: key);
  static late TextEditingController newTodoController;

  @override
  void didMountWidget(BuildContext context) {
    newTodoController = TextEditingController();
    todosViewModel.init();
  }

  @override
  void didUnmountWidget() {
    newTodoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todos = todosViewModel.filteredTodos;
    return Scaffold(
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
              todosViewModel.add(value);
              newTodoController.clear();
            },
          ),
          const SizedBox(height: 42),
          const Toolbar(),
          if (todos.isNotEmpty) const Divider(height: 0),
          todosViewModel.onAll(
            onWaiting: todos.isEmpty
                ? () => const Center(child: CircularProgressIndicator())
                : null,
            onError: todos.isEmpty
                ? (error, refresh) {
                    return Center(
                      child: TextButton.icon(
                        label: Text(error.message),
                        icon: const Icon(Icons.refresh),
                        onPressed: refresh,
                      ),
                    );
                  }
                : null,
            onData: (_) {
              return Column(
                children: [
                  for (var i = 0; i < todos.length; i++) ...[
                    if (i > 0) const Divider(height: 0),
                    Dismissible(
                      key: ValueKey(todos[i].id),
                      onDismissed: (_) {
                        todosViewModel.remove(todos[i].id);
                      },
                      child: TodosViewModel.currentTodo.inherited(
                        key: ValueKey(todos[i].id),
                        stateOverride: () {
                          return TodoItem(
                            value: todosViewModel.filteredTodos[i],
                            itemFocusNode: FocusNode(),
                            textFocusNode: FocusNode(),
                            textEditingController: TextEditingController(),
                          );
                        },
                        builder: (_) => const TodoItemWidget(),
                      ),
                    )
                  ],
                ],
              );
            },
          ),
        ],
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
    final filter = todosViewModel.filter;

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
              creator: () => todosViewModel.isAllCompleted,
              builder: (rm) {
                return Tooltip(
                  key: allFilterKey,
                  message:
                      'Toggle All todos to ${todosViewModel.isAllCompleted ? 'uncompleted' : 'completed'}',
                  child: Checkbox(
                    value: todosViewModel.isAllCompleted,
                    onChanged: (value) {
                      rm.state = value!;
                      todosViewModel.toggleAll(value);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Text(
              '${todosViewModel.uncompletedTodosCount} items left',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Tooltip(
            key: allFilterKey,
            message: 'All todos',
            child: TextButton(
              onPressed: () => todosViewModel.filter = TodoFilter.all,
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
              onPressed: () => todosViewModel.filter = TodoFilter.active,
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
              onPressed: () => todosViewModel.filter = TodoFilter.completed,
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

class TodoItemWidget extends ReactiveStatelessWidget {
  const TodoItemWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final todoRM = TodosViewModel.currentTodo(context);
    final todo = todoRM.state;

    final itemFocusNode = todo.itemFocusNode;
    final isFocused = itemFocusNode.hasFocus;
    final textFocusNode = todo.textFocusNode;
    final textEditingController = todo.textEditingController;
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
            todoRM.state = todo.copyWith(
              description: textEditingController.text,
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
              todoRM.state = todo.copyWith(
                completed: value,
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
