import '../domain/entities/todo.dart';
import '../service/exceptions/persistance_exception.dart';
import '../service/interfaces/i_todo_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatesRebuilderTodosRepository implements ITodosRepository {
  final databaseReference = Firestore.instance;

  @override
  Future<List<Todo>> loadTodos() async {
    try {
      final snapshot =
          await databaseReference.collection("todos").getDocuments();

      var todos = <Todo>[];

      snapshot.documents.forEach(
        (f) {
          print('${f.data}}');
          todos.add(Todo.fromJson(f.data));
        },
      );

      // final todoEntities = await _todosRepository.loadTodos();
      // var todos = <Todo>[];
      // for (var todoEntity in todoEntities) {
      //   todos.add(
      //     Todo.fromJson(todoEntity.toJson()),
      //   );
      // }
      _cashedTodos = List<Todo>.from(todos);
      return todos;
    } catch (e) {
      throw PersistanceException('There is a problem in loading todos : $e');
    }
  }

  List<Todo> _cashedTodos = [];

  @override
  Future saveTodos(List<Todo> todos) async {
    try {
      final List<Todo> newTodos = List<Todo>.from(todos);
      for (Todo oldTodo in _cashedTodos) {
        final newTodo =
            newTodos.firstWhere((t) => t.id == oldTodo.id, orElse: () => null);
        if (newTodo != null) {
          //remove the newTodo from the list of new todos
          //the new todos list contains an old todo
          if (oldTodo == newTodo) {
            newTodos.remove(newTodo);
            // //If they are different than update the todo
            // await databaseReference
            //     .collection("todos")
            //     .document('1/${oldTodo.id}')
            //     .updateData(newTodo.toJson());
          }
        } else {
          //the new todos does not contain an old todo
          //It must be deleted

          //remove / from provided id (/ is used for path).
          final documentId = oldTodo.id.replaceAll('/', '');
          await databaseReference
              .collection("todos")
              .document('$documentId')
              .delete();
        }
      }

      //All the old todos are removed from the new todos list
      //what remains is new todos added by the user
      for (Todo newTodo in newTodos) {
        //create new todo in the firestore

        //remove / from provided id (/ is used for path).
        final documentId = newTodo.id.replaceAll('/', '');
        await databaseReference
            .collection("todos")
            .document('$documentId')
            .setData(newTodo.toJson());
      }
      _cashedTodos = List<Todo>.from(todos);
      // var todosEntities = <TodoEntity>[];
      // //// to simulate en error uncomment these lines.
      // // await Future.delayed(Duration(milliseconds: 500));
      // // throw Exception();
      // for (var todo in todos) {
      //   todosEntities.add(TodoEntity.fromJson(todo.toJson()));
      // }
      // return _todosRepository.saveTodos(todosEntities);
    } catch (e) {
      throw PersistanceException(
          'There is a problem in saving todos :${e?.message}');
    }
  }
}
