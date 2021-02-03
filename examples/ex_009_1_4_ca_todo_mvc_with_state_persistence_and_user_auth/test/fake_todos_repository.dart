import 'package:states_rebuilder/states_rebuilder.dart';

import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/entities/todo.dart';

class FakeTodosRepository implements ICRUD<List<Todo>, String> {
  final List<Todo> todos;

  FakeTodosRepository(this.todos);

  @override
  Future<List<List<Todo>>> read(String userId) async {
    await Future.delayed(Duration(seconds: 1));

    return [todos];
  }

  @override
  Future<bool> update(List<Todo> item, String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Todo>> create(List<Todo> item, String userId) {
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(List<Todo> item, String userId) {
    throw UnimplementedError();
  }
}

final todos1 = [
  Todo(
    'Task1',
    id: 'user1-1',
    note: 'Note1',
  ),
];

final todos3 = [
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
