import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite/sqflite.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'domain/entities/todo.dart';
import 'service/common/enums.dart';
import 'service/exceptions/persistance_exception.dart';

class Query {
  final VisibilityFilter filter;
  final String operation;
  Query({this.filter, this.operation = ''});
}

class SqfliteRepository implements ICRUD<Todo, Query> {
  Database _db;
  final _tableName = 'todos';

  @override
  Future<SqfliteRepository> init() async {
    final databasesPath =
        await path_provider.getApplicationDocumentsDirectory();
    _db = await openDatabase(
      join(databasesPath.path, 'todo_db.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE $_tableName (id TEXT PRIMARY KEY, task TEXT, note TEXT, complete INTEGER)',
        );
      },
    );
    return this;
  }

  @override
  Future<List<Todo>> read(Query query) async {
    try {
      var result;
      if (query.filter == VisibilityFilter.all) {
        result = await _db.query(_tableName);
      } else {
        result = await _db.query(
          _tableName,
          where: 'complete = ?',
          whereArgs: [query.filter == VisibilityFilter.active ? '0' : '1'],
        );
      }

      if (result.isNotEmpty) {
        return result.map((e) => Todo.fromMap(e)).toList().cast<Todo>();
      }
      return null;
    } catch (e) {
      throw PersistanceException('There is a problem in reading from database');
    }
  }

  @override
  Future<Todo> create(Todo item, Query param) async {
    try {
      await _db.insert(_tableName, item.toMap());
      return item;
    } catch (e) {
      throw PersistanceException('There is a problem in writing in database');
    }
  }

  @override
  Future<void> delete(List<Todo> todos, Query param) async {
    // if (todos.isNotEmpty) {
    //   final batch = _db.batch();
    //   for (var todo in todos) {
    //     batch.delete(
    //       _tableName,
    //       where: 'id = ?',
    //       whereArgs: [todo.id],
    //     );
    //   }
    //   await batch.commit();
    // }
    //Or
    if (param.operation == 'deleteCompleted') {
      await _db.delete(
        _tableName,
        where: 'complete = ?',
        whereArgs: ['1'],
      );
    } else if (todos.length == 1) {
      await _db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [todos.first.id],
      );
    }
  }

  @override
  Future<void> update(List<Todo> todos, Query param) async {
    if (todos.isNotEmpty) {
      final batch = _db.batch();
      for (var todo in todos) {
        batch.update(
          _tableName,
          todo.toMap(),
          where: 'id = ?',
          whereArgs: [todo.id],
        );
      }
      await batch.commit();
    }

    // await _db.update(
    //   _tableName,
    //   item.toMap(),
    //   where: 'id = ?',
    //   whereArgs: [item.id],
    // );
  }

  Future<int> count(Query query) async {
    try {
      var result;

      result = await _db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName '
        'WHERE complete = ${query.filter == VisibilityFilter.active ? '0' : '1'}',
      );

      if (result.isNotEmpty) {
        final r = result.first['COUNT(*)'];
        print(r);
        return r;
      }
      return null;
    } catch (e) {
      throw PersistanceException('There is a problem in reading');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
