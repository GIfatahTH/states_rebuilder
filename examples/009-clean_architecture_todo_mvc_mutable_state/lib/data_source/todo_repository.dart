import '../domain/entities/todo.dart';
import 'dart:convert';
import '../service/exceptions/persistance_exception.dart';
import '../service/interfaces/i_todo_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodosRepository implements ITodosRepository {
  final SharedPreferences prefs;

  TodosRepository({this.prefs});
  @override
  Future<List<Todo>> loadTodos() async {
    try {
      final result = prefs.getString('todos');
      if (result == null) {
        return [];
      }
      List<dynamic> todosList = json.decode(result);
      return todosList.map((t) => Todo.fromJson(t)).toList();
    } catch (e) {
      throw PersistanceException('There is a problem in loading todos : $e');
    }
  }

  @override
  Future saveTodos(List<Todo> todos) async {
    try {
      final t = todos.map((e) => e.toJson()).toList();
      await Future.delayed(Duration(seconds: 5));
      // throw PersistanceException('net work error');
      // await prefs.setString('todos', json.encode(t));
    } catch (e) {
      throw PersistanceException(
          'There is a problem in saving todos :${e?.message}');
    }
  }
}
