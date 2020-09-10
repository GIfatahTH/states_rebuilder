// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_mvc_the_flutter_bloc_way/models/models.dart';
import 'package:todos_repository_core/todos_repository_core.dart';

abstract class TodosState extends Equatable {
  final TodosRepository todosRepository;

  const TodosState({@required this.todosRepository});

  @override
  List<Object> get props => [];
}

class TodosLoading extends TodosState {
  final TodosRepository todosRepository;

  TodosLoading(this.todosRepository);

  ///_mapLoadTodosToState
  Future<TodosState> loadTodos() async {
    try {
      final todos = await todosRepository.loadTodos();
      return TodosLoaded(
        todos: todos.map(Todo.fromEntity).toList(),
        todosRepository: todosRepository,
      );
    } catch (_) {
      return TodosNotLoaded();
    }
  }
}

class TodosLoaded extends TodosState {
  final List<Todo> todos;
  final TodosRepository todosRepository;
  const TodosLoaded({
    this.todos = const [],
    @required this.todosRepository,
  });

  @override
  List<Object> get props => [todos];

  ///_mapAddTodoToState
  static Future<TodosState> addTodo(
    TodosLoaded currentState,
    Todo todo,
  ) async {
    final updatedTodos = List<Todo>.from(currentState.todos)..add(todo);
    _saveTodos(currentState, updatedTodos);
    return TodosLoaded(
      todos: updatedTodos,
      todosRepository: currentState.todosRepository,
    );
  }

  ///_mapUpdateTodoToState
  static Stream<TodosState> updateTodo(
    TodosLoaded currentState,
    Todo updatedTodo,
  ) async* {
    final updatedTodos = currentState.todos.map((todo) {
      return todo.id == updatedTodo.id ? updatedTodo : todo;
    }).toList();
    yield TodosLoaded(
      todos: updatedTodos,
      todosRepository: currentState.todosRepository,
    );
    await _saveTodos(currentState, updatedTodos);
  }

  ///_mapDeleteTodoToState
  static Stream<TodosState> deleteTodo(
    TodosLoaded currentState,
    Todo updatedTodo,
  ) async* {
    final updatedTodos =
        currentState.todos.where((todo) => todo.id != updatedTodo.id).toList();
    yield TodosLoaded(
      todos: updatedTodos,
      todosRepository: currentState.todosRepository,
    );
    await _saveTodos(currentState, updatedTodos);
  }

  ///_mapToggleAllToState
  static Stream<TodosState> toggleAll(TodosLoaded currentState) async* {
    final allComplete = currentState.todos.every((todo) => todo.complete);
    final updatedTodos = currentState.todos
        .map((todo) => todo.copyWith(complete: !allComplete))
        .toList();
    yield TodosLoaded(
      todos: updatedTodos,
      todosRepository: currentState.todosRepository,
    );
    await _saveTodos(currentState, updatedTodos);
  }

  ///_mapClearCompletedToState
  static Stream<TodosState> clearCompleted(TodosLoaded currentState) async* {
    final updatedTodos =
        currentState.todos.where((todo) => !todo.complete).toList();
    yield TodosLoaded(
      todos: updatedTodos,
      todosRepository: currentState.todosRepository,
    );
    await _saveTodos(currentState, updatedTodos);
  }

  static Future _saveTodos(TodosLoaded currentState, List<Todo> todos) {
    return currentState.todosRepository.saveTodos(
      todos.map((todo) => todo.toEntity()).toList(),
    );
  }

  @override
  String toString() => 'TodosLoaded { todos: $todos }';
}

class TodosNotLoaded extends TodosState {}
