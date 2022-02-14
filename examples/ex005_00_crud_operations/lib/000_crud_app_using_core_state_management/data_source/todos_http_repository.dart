import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/todo.dart';
import 'i_todos_repository.dart';

class TodosHttpRepository implements ITodosRepository {
  static const baseUrl = 'https://jsonplaceholder.typicode.com';

  @override
  Future<List<Todo>> getTodos() async {
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
      throw Exception();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<void> createTodo(Todo todo) async {
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
        throw Exception();
      }
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
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
        throw Exception();
      }
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/$id'),
      );
      if (response.statusCode > 400) {
        throw Exception();
      }
    } catch (e) {
      throw Exception();
    }
  }
}
