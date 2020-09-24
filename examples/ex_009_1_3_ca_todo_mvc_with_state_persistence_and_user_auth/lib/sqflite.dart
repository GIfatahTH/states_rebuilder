import 'package:sqflite/sqflite.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'service/exceptions/persistance_exception.dart';

class SqfliteImp implements IPersistStore {
  Database _db;
  final _tableName = 'AppStorage';

  @override
  Future<void> init() async {
    final databasesPath =
        await path_provider.getApplicationDocumentsDirectory();
    _db = await openDatabase(
      join(databasesPath.path, 'todo_db.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE $_tableName (key TEXT PRIMARY KEY, value TEXT)',
        );
      },
    );
  }

  @override
  Object read(String key) async {
    try {
      final result = await _db.query(
        _tableName,
        where: 'key = ?',
        whereArgs: [key],
      );
      if (result.isNotEmpty) {
        return result.first['value'];
      }
      return null;
    } catch (e) {
      throw PersistanceException('There is a problem in loading todos: $e');
    }
  }

  @override
  Future<void> write<T>(String key, T value) async {
    try {
      // await Future.delayed(Duration(seconds: 3));
      // throw Exception('Error');

      return await _db.insert(
        _tableName,
        {
          'key': key,
          'value': value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw PersistanceException('There is a problem in saving todos: $e');
    }
  }

  @override
  Future<void> delete(String key) async {
    return _db.delete(_tableName, where: 'key = $key');
  }

  @override
  Future<void> deleteAll() async {
    return _db.delete(_tableName);
  }
}
