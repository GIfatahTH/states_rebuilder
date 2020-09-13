import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/domain/entities/todo.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/domain/entities/user.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/service/exceptions/persistance_exception.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/service/interfaces/i_todo_repository.dart';

class FakeTodosRepository implements ITodosRepository {
  final User user;
  bool throwError;
  int delay;
  FakeTodosRepository({this.user, this.throwError = false, this.delay = 50});

  @override
  Future<List<Todo>> loadTodos() async {
    await Future.delayed(Duration(milliseconds: delay ?? 20));
    if (user.uid == 'user1') {
      return [
        Todo(
          'Task1',
          id: 'user1-1',
          note: 'Note1',
        ),
        Todo(
          'Task2',
          id: 'user1-2',
          note: 'Note2',
          complete: false,
        ),
        Todo(
          'Task3',
          id: 'user1-3',
          note: 'Note3',
          complete: true,
        ),
      ];
    } else {
      return [
        Todo(
          'Task1',
          id: 'user1-1',
          note: 'Note1',
        ),
      ];
    }
  }

  bool isSaved = false;
  @override
  Future saveTodos(List<Todo> todos) async {
    await Future.delayed(Duration(milliseconds: delay));
    if (throwError) {
      throw PersistanceException('There is a problem in saving todos');
    }
    isSaved = true;
    return true;
  }
}
