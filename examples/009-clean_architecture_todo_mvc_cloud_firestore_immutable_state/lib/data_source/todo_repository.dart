import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/domain/entities/user.dart';
import 'package:flutter/foundation.dart';

import '../domain/entities/todo.dart';
import '../service/exceptions/persistance_exception.dart';
import '../service/interfaces/i_todo_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodosRepository implements ITodosRepository {
  final databaseReference = Firestore.instance;
  final User user;
  TodosRepository({@required this.user});
  String get collectionPath {
    return 'todos/byUser/${user.uid.replaceAll('/', '')}';
  }

  @override
  Future<List<Todo>> loadTodos() async {
    try {
      final snapshot =
          await databaseReference.collection(collectionPath).getDocuments();

      var todos = <Todo>[];

      snapshot.documents.forEach(
        (f) {
          todos.add(Todo.fromJson(f.data));
        },
      );

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
      // await Future.delayed(Duration(milliseconds: 500));
      // throw Exception();
      final List<Todo> newTodos = List<Todo>.from(todos);
      for (Todo oldTodo in _cashedTodos) {
        final newTodo =
            newTodos.firstWhere((t) => t.id == oldTodo.id, orElse: () => null);
        if (newTodo != null) {
          //remove the newTodo from the list of new todos
          //the new todos list contains an old todo
          if (oldTodo == newTodo) {
            newTodos.remove(newTodo);
          }
        } else {
          //the new todos does not contain an old todo
          //It must be deleted

          //remove / from provided id (/ is used for path).
          final documentId = oldTodo.id.replaceAll('/', '');
          await databaseReference
              .collection(collectionPath)
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
            .collection(collectionPath)
            .document('$documentId')
            .setData(newTodo.toJson());
      }
      _cashedTodos = List<Todo>.from(todos);
    } catch (e) {
      throw PersistanceException(
          'There is a problem in saving todos :${e?.message}');
    }
  }
}
