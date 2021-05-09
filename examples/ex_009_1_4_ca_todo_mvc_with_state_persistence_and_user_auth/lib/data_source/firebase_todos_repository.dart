import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:states_rebuilder/states_rebuilder.dart';

import '../service/exceptions/fetch_todos_exception.dart';

import '../domain/entities/todo.dart';
import 'my_project_data.dart' as myProjectData; //TODO Delete this.

//1. create firebase project.
//2. create a realtime database and start in test mode.
//3. notice the generated url which we will use. If your project name is YOUR_PROJECT_NAME the the generated url is https://YOUR_PROJECT_NAME.firebaseio.com/. This will be your `baseUrl` const.
const baseUrl = myProjectData.baseUrl; //TODO Use yours.

class TodosQuery {
  final List<Todo> todos;
  final String userId;
  TodosQuery({
    this.todos = const [],
    required this.userId,
  });

  TodosQuery copyWith({
    List<Todo>? todos,
    String? userId,
  }) {
    return TodosQuery(
      todos: todos ?? this.todos,
      userId: userId ?? this.userId,
    );
  }
}

class FireBaseTodosRepository implements ICRUD<Todo, String> {
  final String authToken;

  FireBaseTodosRepository({
    required this.authToken,
  });
  @override
  Future<List<Todo>> read(String? userId) async {
    if (userId == null) {
      return [];
    }
    try {
      // await Future.delayed(Duration(seconds: 5));

      final response = await http.get(
        Uri.parse('$baseUrl/$userId.json?auth=$authToken'),
      );
      if (response.statusCode >= 400) {
        throw CRUDTodosException.pageNotFound();
      }

      final result =
          convert.json.decode(response.body) as Map<String, dynamic>?;
      if (result == null) {
        return [];
      }
      return result
          .map<String, Todo>(
              (k, m) => MapEntry(k, Todo.fromJson(m).copyWith(id: k)))
          .values
          .toList();
    } catch (e) {
      if (e is Error) {
        rethrow;
      }
      throw CRUDTodosException.netWorkFailure();
    }
  }

  @override
  Future<dynamic> update(List<Todo> items, String? userId) async {
    if (userId == null) {
      return null;
    }
    try {
      assert(items.isNotEmpty);
      // await Future.delayed(Duration(seconds: 0));
      // throw PersistanceException('Write failure');
      for (var item in items) {
        final response = await http.put(
          Uri.parse('$baseUrl/$userId/${item.id}.json?auth=$authToken'),
          body: convert.json.encode(item.toJson()),
        );
        if (response.statusCode >= 400) {
          throw CRUDTodosException.pageNotFound();
        }
      }
      return true;
    } catch (e) {
      throw CRUDTodosException.netWorkFailure();
    }
  }

  @override
  Future<Todo> create(Todo item, String? userId) async {
    if (userId == null) {
      return item;
    }
    try {
      // await Future.delayed(Duration(seconds: 0));
      // throw PersistanceException('Write failure');
      final response = await http.post(
        Uri.parse('$baseUrl/$userId.json?auth=$authToken'),
        body: convert.json.encode(item.toJson()),
      );
      if (response.statusCode >= 400) {
        throw CRUDTodosException.pageNotFound();
      }
      final result =
          convert.json.decode(response.body) as Map<dynamic, dynamic>;
      return item.copyWith(id: result['name']);
    } catch (e) {
      throw CRUDTodosException.netWorkFailure();
    }
  }

  @override
  Future<dynamic> delete(List<Todo> item, String? userId) async {
    if (userId == null) {
      return null;
    }
    try {
      // await Future.delayed(Duration(seconds: 0));
      // throw PersistanceException('Write failure');
      final response = await http.delete(
        Uri.parse('$baseUrl/$userId/${item.first.id}.json?auth=$authToken'),
      );
      if (response.statusCode >= 400) {
        throw CRUDTodosException.pageNotFound();
      }
      return true;
    } catch (e) {
      throw CRUDTodosException.netWorkFailure();
    }
  }

  @override
  void dispose() {}

  @override
  Future<void> init() async {}
}
