import 'package:todos_repository_core/todos_repository_core.dart';

class FakeRepository implements TodosRepository {
  @override
  Future<List<TodoEntity>> loadTodos() async {
    await Future.delayed(Duration(milliseconds: 20));
    return [
      TodoEntity(
        'Task1',
        '1',
        'Note1',
        false,
      ),
      TodoEntity(
        'Task2',
        '2',
        'Note2',
        false,
      ),
      TodoEntity(
        'Task3',
        '3',
        'Note3',
        true,
      ),
    ];
  }

  bool throwError = false;
  bool isSaved = false;
  int delay = 50;
  @override
  Future saveTodos(List<TodoEntity> todos) async {
    await Future.delayed(Duration(milliseconds: delay));
    if (throwError) {
      throw PersistanceException('There is a problem in saving todos');
    }
    isSaved = true;
    return true;
  }
}

class PersistanceException implements Exception {
  final String message;
  PersistanceException(this.message);
}
