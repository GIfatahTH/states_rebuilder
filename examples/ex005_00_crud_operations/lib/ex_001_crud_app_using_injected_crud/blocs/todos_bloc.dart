import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:uuid/uuid.dart';

import '../data_source/i_todos_repository.dart';
import '../data_source/todos_fake_repository.dart';
import '../data_source/todos_http_repository.dart';
import '../models/todo.dart';
import '../models/todo_filter.dart';

const _uuid = Uuid();

@immutable
class TodosViewModel {
  void init() {
    // _todosRM.setState((s) => _todosRepository.state.read(null));
  }
  InjectedCRUD<Todo, void> call() => _todosRM;

  // TODO: Switch between implementations
  late final InjectedCRUD<Todo, void> _todosRM = RM.injectCRUD<Todo, void>(
    () => TodosHttpRepository(),
    // () => TodosFakeRepository(),
    // () => TodosFakeRepository(shouldThrowExceptions: () => Random().nextBool()),
    readOnInitialization: true,
    sideEffects: SideEffects.onError(
      (err, refresh) {
        if (_todosRM.state.isEmpty) return;
        RM.scaffold.showSnackBar(
          SnackBar(
            content: Text(err.message),
            action: SnackBarAction(label: 'Refresh', onPressed: refresh),
          ),
        );
      },
    ),
  );

  final _todoListFilterRM = RM.inject<TodoFilter>(
    () => TodoFilter.all,
  );
  TodoFilter get filter => _todoListFilterRM.state;
  set filter(TodoFilter value) => _todoListFilterRM.state = value;

  late final _uncompletedTodosCount = RM.inject<int>(
    () {
      final uncompleted = _todosRM.state.where((todo) => !todo.completed);
      return uncompleted.length;
    },
    initialState: 0,
    // uncompletedTodosCount depends on _todosRM. When the state of _todosRM changes
    // the uncompletedTodosCount is recalculated to get the new uncompleted count
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
    initialState: const [],

    // the filteredTodosRM depended on two states. When any of them changes the
    // filteredTodosRM is recalculated
    dependsOn: DependsOn({_todosRM, _todoListFilterRM}),
  );
  List<Todo> get filteredTodos => [..._filteredTodosRM.state];
  late final onAll = _filteredTodosRM.onAll;

  // Methods to add, edit, remove and toggle todos item
  void add(String description) {
    _todosRM.crud.create(
      Todo(
        id: _uuid.v4(),
        description: description,
      ),
    );
  }

  void edit(Todo todoToEdit) {
    _todosRM.crud.update(
      where: (todo) {
        return todo.id == todoToEdit.id;
      },
      set: (_) {
        return todoToEdit;
      },
    );
  }

  void remove(String id) {
    _todosRM.crud.delete(
      where: (todo) => todo.id == id,
    );
  }

  void toggleAll(bool to) {
    _todosRM.crud.update(
      where: (todo) => todo.completed != to,
      set: (todo) => todo.copyWith(completed: to),
    );
  }

  late final item = _todosRM.item;
  Injected<Todo> getTodoRM(BuildContext context) {
    return _todosRM.item(context)!;
  }

  late final onCRUD = _todosRM.rebuild.onCRUD;
}

// TodoViewModel is a global state
final todosViewModel = TodosViewModel();

// We create a custom object for each todo items.
//
// Each todo item will have the Todo object with two FocusNode and one TextEditingController
// It will be used in the UI
@immutable
class TodoItem extends Todo {
  final FocusNode itemFocusNode;
  final FocusNode textFocusNode;
  final TextEditingController textEditingController;
  final bool isEditable;
  TodoItem({
    required Todo value,
    required this.itemFocusNode,
    required this.textFocusNode,
    required this.textEditingController,
    this.isEditable = false,
  }) : super(
          id: value.id,
          description: value.description,
          completed: value.completed,
        );

  @override
  TodoItem copyWith({
    bool? completed,
    String? description,
    String? id,
  }) {
    return TodoItem(
      value: super.copyWith(
        id: id,
        description: description,
        completed: completed,
      ),
      itemFocusNode: itemFocusNode,
      textFocusNode: textFocusNode,
      textEditingController: textEditingController,
    );
  }
}
