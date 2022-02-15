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
      completed: index % 2 == 0,
    ),
  );

  @override
  Future<Todo> create(Todo todo, void param) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (shouldThrowExceptions?.call() ?? false) {
      throw Exception('Create Todo failure');
    }

    _todos.add(todo);
    return todo;
  }

  @override
  Future delete(List<Todo> todos, void param) async {
    final id = todos.first.id;
    await Future.delayed(const Duration(milliseconds: 600));
    if (shouldThrowExceptions?.call() ?? false) {
      throw Exception('Delete Todo failure');
    }
    _todos.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Todo>> read(void param) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (shouldThrowExceptions?.call() ?? false) {
      throw Exception('Fetch Todo failure');
    }
    return [..._todos];
  }

  @override
  Future update(List<Todo> todos, void param) async {
    final todo = todos.first;
    await Future.delayed(const Duration(milliseconds: 600));
    if (shouldThrowExceptions?.call() ?? false) {
      throw Exception('Update Todo failure');
    }
    final index = _todos.indexWhere((e) => e.id == todo.id);
    _todos[index] = todo;
  }

  @override
  Future<void> init() async {}
  @override
  void dispose() {}
}
