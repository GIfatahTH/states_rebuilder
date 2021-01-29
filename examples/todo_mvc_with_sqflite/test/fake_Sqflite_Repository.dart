import 'package:todo_mvc_with_sqflite/domain/entities/todo.dart';
import 'package:todo_mvc_with_sqflite/service/common/enums.dart';
import 'package:todo_mvc_with_sqflite/sqflite.dart';

class FakeSqfliteRepository implements SqfliteRepository {
  List<Todo> _todos;
  List<Todo> get todos => _todos;
  Exception exception;
  FakeSqfliteRepository(List<Todo> todos) {
    _todos = [...todos];
  }
  @override
  Future<SqfliteRepository> init() async {
    return this;
  }

  @override
  Future<List<Todo>> read(Query query) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    if (query.filter == VisibilityFilter.all) {
      return [..._todos];
    } else if (query.filter == VisibilityFilter.completed) {
      return _todos.where((e) => e.complete).toList();
    } else {
      return _todos.where((e) => !e.complete).toList();
    }
  }

  @override
  Future<Todo> create(Todo item, Query param) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    _todos.add(item);
    return item;
  }

  @override
  Future<void> delete(List<Todo> todos, Query param) async {
    if (exception != null) {
      await Future.delayed(Duration(seconds: 1));
      throw exception;
    }
    for (var todo in todos) {
      _todos.remove(todo);
    }
  }

  @override
  Future<void> update(List<Todo> todos, Query param) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    for (var todo in todos) {
      final index = _todos.indexWhere((e) => e.id == todo.id);
      _todos[index] = todo;
    }
  }

  @override
  Future<int> count(Query query) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    if (query.filter == VisibilityFilter.completed) {
      return _todos.where((e) => e.complete).length;
    } else if (query.filter == VisibilityFilter.active) {
      return _todos.where((e) => !e.complete).length;
    }
    return null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

List<Todo> todos3 = [
  Todo(
    'Task1',
    id: 'user1-1',
    note: 'Note1',
  ),
  Todo(
    'Task2',
    id: 'user1-2',
    note: 'Note2',
    complete: false,
  ),
  Todo(
    'Task3',
    id: 'user1-3',
    note: 'Note3',
    complete: true,
  ),
];
