import 'dart:convert' as convert;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:states_rebuilder/states_rebuilder.dart';

import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/service/exceptions/persistance_exception.dart';

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
    this.userId,
  });

  TodosQuery copyWith({
    List<Todo> todos,
    String userId,
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
    @required this.authToken,
  });
  @override
  Future<List<Todo>> read(String userId) async {
    try {
      // await Future.delayed(Duration(seconds: 5));

      final response = await http.get('$baseUrl/$userId.json?auth=$authToken');
      if (response.statusCode >= 400) {
        throw PersistanceException('Read failure');
      }

      final result =
          convert.json.decode(response.body ?? '{}') as Map<dynamic, dynamic>;
      if (result == null) {
        return [];
      }
      return result
          .map((k, m) => MapEntry(k, Todo.fromJson(m).copyWith(id: k)))
          .values
          .toList();
    } catch (e) {
      if (e is PersistanceException) {
        rethrow;
      }
      throw PersistanceException('NetWork Failure');
    }
  }

  @override
  Future<dynamic> update(List<Todo> items, String userId) async {
    try {
      assert(items.isNotEmpty);
      // await Future.delayed(Duration(seconds: 0));
      // throw PersistanceException('Write failure');
      for (var item in items) {
        final response = await http.put(
          '$baseUrl/$userId/${item.id}.json?auth=$authToken',
          body: convert.json.encode(item.toJson()),
        );
        if (response.statusCode >= 400) {
          throw PersistanceException('Write failure');
        }
      }
      return true;
    } catch (e) {
      if (e is PersistanceException) {
        rethrow;
      }
      throw PersistanceException('NetWork Failure');
    }
  }

  @override
  Future<Todo> create(Todo item, String userId) async {
    try {
      // await Future.delayed(Duration(seconds: 0));
      // throw PersistanceException('Write failure');
      final response = await http.post(
        '$baseUrl/$userId.json?auth=$authToken',
        body: convert.json.encode(item.toJson()),
      );
      if (response.statusCode >= 400) {
        throw PersistanceException('Write failure');
      }
      final result =
          convert.json.decode(response.body) as Map<dynamic, dynamic>;
      return item.copyWith(id: result['name']);
    } catch (e) {
      if (e is PersistanceException) {
        rethrow;
      }
      throw PersistanceException('NetWork Failure');
    }
  }

  @override
  Future<dynamic> delete(List<Todo> item, String userId) async {
    try {
      // await Future.delayed(Duration(seconds: 0));
      // throw PersistanceException('Write failure');
      final response = await http.delete(
        '$baseUrl/$userId/${item.first.id}.json?auth=$authToken',
      );
      if (response.statusCode >= 400) {
        throw PersistanceException('Write failure');
      }
      return true;
    } catch (e) {
      if (e is PersistanceException) {
        rethrow;
      }
      throw PersistanceException('NetWork Failure');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future<ICRUD<Todo, String>> init() async {
    return this;
  }
}

// class FireBaseTodosRepository implements IPersistStore {
//   final String authToken;

//   FireBaseTodosRepository({
//     @required this.authToken,
//   });

//   @override
//   Future<void> init() async {}

//   @override
//   Object read(String key) async {
//     try {
//       // await Future.delayed(Duration(seconds: 5));

//       final response = await http.get('$baseUrl/$key.json?auth=$authToken');
//       if (response.statusCode > 400) {
//         throw PersistanceException('Read failure');
//       }
//       return response.body;
//     } catch (e) {
//       if (e is PersistanceException) {
//         rethrow;
//       }
//       throw PersistanceException('NetWork Failure');
//     }
//   }

//   @override
//   Future<void> write<T>(String key, T value) async {
//     try {
//       // await Future.delayed(Duration(seconds: 0));
//       // throw PersistanceException('Write failure');
//       final response =
//           await http.put('$baseUrl/$key.json?auth=$authToken', body: value);
//       if (response.statusCode >= 400) {
//         throw PersistanceException('Write failure');
//       }
//     } catch (e) {
//       if (e is PersistanceException) {
//         rethrow;
//       }
//       throw PersistanceException('NetWork Failure');
//     }
//   }

//   @override
//   Future<void> delete(String key) {
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> deleteAll() {
//     throw UnimplementedError();
//   }
// }
