import 'package:clean_architecture_todo_mvc/data_source/todo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_todo_mvc/domain/entities/todo.dart';
import 'package:clean_architecture_todo_mvc/service/common/enums.dart';
import 'package:clean_architecture_todo_mvc/service/interfaces/i_todo_repository.dart';
import 'package:clean_architecture_todo_mvc/service/todos_service.dart';

import 'fake_repository.dart';

//TodoService class is a pure dart class, you can test it just as you test a plain dart class.
void main() {
  group(
    'TodosService',
    () {
      ITodosRepository todosRepository;
      TodosService todoService;
      setUp(
        () {
          todosRepository = FakeRepository();
          todoService = TodosService(todosRepository);
        },
      );

      test(
        'should load todos works',
        () async {
          expect(todoService.todos.isEmpty, isTrue);
          await todoService.loadTodos();
          expect(todoService.todos.length, equals(3));
        },
      );

      test(
        'should filler todos works',
        () async {
          await todoService.loadTodos();
          //all todos
          expect(todoService.todos.length, equals(3));
          //active todos
          todoService.activeFilter = VisibilityFilter.active;
          expect(todoService.todos.length, equals(2));
          //completed todos
          todoService.activeFilter = VisibilityFilter.completed;
          expect(todoService.todos.length, equals(1));
        },
      );

      test(
        'should add todo works',
        () async {
          await todoService.loadTodos();
          expect(todoService.todos.length, equals(3));
          final todoToAdd = Todo('addTask');
          await todoService.addTodo(todoToAdd);
          expect(todoService.todos.length, equals(4));
          expect((todosRepository as FakeRepository).isSaved, isTrue);
        },
      );

      test(
        'should update todo works',
        () async {
          await todoService.loadTodos();
          final beforeUpdate =
              todoService.todos.firstWhere((todo) => todo.id == '1');
          expect(beforeUpdate.task, equals('Task1'));
          await todoService.updateTodo(Todo('updateTodo', id: '1'));
          expect((todosRepository as FakeRepository).isSaved, isTrue);
          final afterUpdate =
              todoService.todos.firstWhere((todo) => todo.id == '1');
          expect(afterUpdate.task, equals('updateTodo'));
        },
      );

      test(
        'should delete todo works',
        () async {
          await todoService.loadTodos();
          expect(todoService.todos.length, equals(3));
          await todoService.deleteTodo(Todo('updateTodo', id: '1'));
          expect((todosRepository as FakeRepository).isSaved, isTrue);
          expect(todoService.todos.length, equals(2));
        },
      );

      test(
        'should toggleAll todos works',
        () async {
          await todoService.loadTodos();
          expect(todoService.numActive, equals(2));
          expect(todoService.numCompleted, equals(1));

          await todoService.toggleAll();
          expect((todosRepository as FakeRepository).isSaved, isTrue);
          expect(todoService.numActive, equals(0));
          expect(todoService.numCompleted, equals(3));

          await todoService.toggleAll();
          expect(todoService.numActive, equals(3));
          expect(todoService.numCompleted, equals(0));
        },
      );

      test(
        'should clearCompleted todos works',
        () async {
          await todoService.loadTodos();
          expect(todoService.numActive, equals(2));
          expect(todoService.numCompleted, equals(1));

          await todoService.clearCompleted();
          expect((todosRepository as FakeRepository).isSaved, isTrue);
          expect(todoService.todos.length, equals(2));
          expect(todoService.numActive, equals(2));
          expect(todoService.numCompleted, equals(0));
        },
      );
    },
  );
}
