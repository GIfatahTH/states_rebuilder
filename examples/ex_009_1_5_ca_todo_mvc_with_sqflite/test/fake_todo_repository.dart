import 'package:ex_009_1_3_ca_todo_mvc_with_sqflite/domain/entities/todo.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_sqflite/service/common/enums.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_sqflite/sqflite.dart';

class FakeTodoRepository implements SqfliteRepository {
  List<Todo> todos;
  dynamic error;

  FakeTodoRepository(this.todos);

  @override
  Future<void> init() async {}

  @override
  Future<Todo> create(Todo item, TodoParam param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    todos = [...todos, item];
    return item;
  }

  @override
  Future<List<Todo>> read(TodoParam param) async {
    await Future.delayed(Duration(seconds: 1));

    if (param.filter == VisibilityFilter.active) {
      return todos.where((e) => !e.complete).toList();
    }
    if (param.filter == VisibilityFilter.completed) {
      return todos.where((e) => e.complete).toList();
    }
    return [...todos];
  }

  @override
  Future update(List<Todo> items, TodoParam param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }

    for (var item in items) {
      final index = todos.indexOf(item);
      assert(index != -1);
      todos[index] = item;
    }
  }

  @override
  Future delete(List<Todo> item, TodoParam param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    todos = todos.where((e) => !item.contains(e)).toList();
  }

  @override
  Future<int> count(TodoParam param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }

    if (param.filter == VisibilityFilter.active) {
      return todos.where((e) => !e.complete).length;
    }
    if (param.filter == VisibilityFilter.completed) {
      return todos.where((e) => e.complete).length;
    }
    return todos.length;
  }

  @override
  void dispose() {}
}
