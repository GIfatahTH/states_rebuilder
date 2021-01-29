import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite/sqflite.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'domain/entities/todo.dart';
import 'service/common/enums.dart';
import 'service/exceptions/persistance_exception.dart';

class Query {
  final VisibilityFilter filter;
  Query({this.filter});
}

class SqfliteRepository implements ICRUD<Todo, Query> {
  Database _db;
  final _tableName = 'todos';

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
        return result.first['value'];
      }
      return null;
    } catch (e) {
      throw PersistanceException('There is a problem in reading');
    }
  }

  @override
  Future<Todo> create(Todo item, Query param) async {
    try {
      // await Future.delayed(Duration(seconds: 3));
      // throw Exception('Error');

      await _db.insert(_tableName, item.toMap());
      return item;
    } catch (e) {
      throw PersistanceException('There is a problem in writing ');
    }
  }

  @override
  Future<bool> delete(Todo item, Query param) async {
    await _db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [item.id],
    );
    return true;
  }

  @override
  Future<bool> update(Todo item, Query param) async {
    await _db.update(
      _tableName,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
    return true;
  }

  Future<int> count(Query query) async {
    try {
      var result;

      result = await _db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName'
        'WHERE complete = ${query.filter == VisibilityFilter.active ? '0' : '1'}',
      );

      if (result.isNotEmpty) {
        return result.first['value'];
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
