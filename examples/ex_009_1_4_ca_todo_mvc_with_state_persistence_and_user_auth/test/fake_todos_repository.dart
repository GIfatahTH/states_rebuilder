import 'package:states_rebuilder/states_rebuilder.dart';

import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/entities/todo.dart';

class FakeTodosRepository implements ICRUD<Todo, String> {
  late Map<String, List<Todo>> todos;
  dynamic error;
  FakeTodosRepository() {
    todos = {
      '__Todos__/Id_user1@mail.com': [],
      '__Todos__/user1': [],
      '__Todos__/user2': todos3,
    };
  }
  @override
  Future<List<Todo>> read(String? userId) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    return todos[userId]!;
  }

  @override
  Future<dynamic> update(List<Todo> item, String? userId) async {
    await Future.delayed(Duration(seconds: 1));
    final index = todos[userId]!.indexWhere((e) => e.id == item.first.id);
    todos[userId]![index] = item.first;
    return true;
  }

  @override
  Future<Todo> create(Todo item, String? userId) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    todos[userId]!.add(item);
    return item;
  }

  @override
  Future<dynamic> delete(List<Todo> item, String? userId) async {
    if (error != null) {
      await Future.delayed(Duration(seconds: 1));
      throw error;
    }
    todos[userId]!.remove(item.first);
    return true;
  }

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

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future<ICRUD<Todo, String>> init() async {
    return this;
  }
}
