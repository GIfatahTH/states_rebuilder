import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/todo.dart';
import 'i_todos_repository.dart';

class TodosHttpRepository implements ITodosRepository {
  static const baseUrl = 'https://jsonplaceholder.typicode.com';

  @override
  Future<List<Todo>> read(void param) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/todos?userId=2'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as List;
        return body
            .map(
              (e) => Todo(
                id: '${e['id']}',
                description: e['title'],
                completed: e['completed'],
              ),
            )
            .toList();
      }
      throw Exception('Read Todo failure statusCode = ${response.statusCode}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Read Todo failure');
    }
  }

  @override
  Future<Todo> create(Todo todo, void param) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        body: jsonEncode(
          {
            'id': todo.id,
            'title': todo.description,
            'completed': todo.completed,
          },
        ),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode > 400) {
        throw Exception(
            'Create Todo failure statusCode = ${response.statusCode}');
      }
      return todo;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Create Todo failure');
    }
  }

  @override
  Future update(List<Todo> todos, void param) async {
    for (var todo in todos) {
      try {
        // print('before ${todo.id}');

        final response = await http.put(
          Uri.parse('$baseUrl/todos/${todo.id}'),
          body: jsonEncode(
            {
              'id': todo.id,
              'title': todo.description,
              'completed': todo.completed,
            },
          ),
          headers: {
            'Content-type': 'application/json; charset=UTF-8',
          },
        );
        // print(response.body);
        if (response.statusCode > 400) {
          throw Exception(
            'Update Todo failure statusCode = ${response.statusCode}',
          );
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Update Todo failure');
      }
    }
  }

  @override
  Future delete(List<Todo> todos, void param) async {
    for (var todo in todos) {
      final id = todo.id;
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/todos/$id'),
        );
        if (response.statusCode > 400) {
          throw Exception(
              'Delete Todo failure statusCode = ${response.statusCode}');
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Delete Todo failure');
      }
    }
  }

  @override
  Future<void> init() async {}
  @override
  void dispose() {}
}
