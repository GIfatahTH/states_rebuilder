import '../models/todo.dart';

abstract class ITodosRepository {
  Future<List<Todo>> getTodos();
  Future<void> createTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}
