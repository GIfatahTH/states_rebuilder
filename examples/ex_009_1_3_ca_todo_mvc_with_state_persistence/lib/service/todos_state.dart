import 'dart:convert' as convert;
import '../domain/entities/todo.dart';

extension ListTodoX on List<Todo> {
  List<Todo> addTodo(Todo todo) {
    return List<Todo>.from(this)..add(todo);
  }

  List<Todo> updateTodo(Todo todo) {
    return map((t) => t.id == todo.id ? todo : t).toList();
  }

  List<Todo> deleteTodo(Todo todo) {
    return List<Todo>.from(this)..remove(todo);
  }

  List<Todo> toggleAll() {
    final allComplete = this.every((e) => e.complete);
    return map(
      (t) => t.copyWith(complete: !allComplete),
    ).toList();
  }

  List<Todo> clearCompleted() {
    return List<Todo>.from(this)
      ..removeWhere(
        (t) => t.complete,
      );
  }

  ///Parsing the state
  String toJson() => convert.json.encode(this);
  static List<Todo> fromJson(json) {
    final result = convert.json.decode(json) as List<dynamic>;
    return result.map((m) => Todo.fromJson(m)).toList();
  }
}
