import '../models/todo.dart';
import 'i_todos_repository.dart';

class TodosFakeRepository implements ITodosRepository {
  final bool Function()? shouldThrowExceptions;
  TodosFakeRepository({
    this.shouldThrowExceptions,
  });

  final _todos = List.generate(
    5,
    (index) => Todo(
        description: 'description of todo $index',
        id: '$index',
        completed: index % 2 == 0),
  );
  @override
  Future<void> createTodo(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (shouldThrowExceptions?.call() ?? false) {
      throw Exception('Create Todo failure');
    }
    _todos.add(todo);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (shouldThrowExceptions?.call() ?? false) {
      throw Exception('Delete Todo failure');
    }
    _todos.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Todo>> getTodos() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (shouldThrowExceptions?.call() ?? false) {
      throw Exception('Fetch Todo failure');
    }
    return [..._todos];
  }

  bool l = true;
  @override
  Future<void> updateTodo(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 600));
    print('$l::$todo');
    if (l && (shouldThrowExceptions?.call() ?? false)) {
      l = false;
      print('l=$l');
      throw Exception('Update Todo failure');
    }
    final index = _todos.indexWhere((e) => e.id == todo.id);
    _todos[index] = todo;
  }
}
