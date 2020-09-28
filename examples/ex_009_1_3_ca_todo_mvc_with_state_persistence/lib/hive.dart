import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'service/exceptions/persistance_exception.dart';

class HiveImp implements IPersistStore {
  Box box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox('myBox');
  }

  @override
  Object read(String key) {
    try {
      return box.get(key);
    } catch (e) {
      throw PersistanceException('There is a problem in reading $key: $e');
    }
  }

  @override
  Future<void> write<T>(String key, T value) async {
    try {
      // await Future.delayed(Duration(seconds: 3));
      // throw Exception('Error');
      return box.put(key, value);
    } catch (e) {
      throw PersistanceException('There is a problem in writing $key: $e');
    }
  }

  @override
  Future<void> delete(String key) async {
    return box.delete(key);
  }

  @override
  Future<void> deleteAll() async {
    return box.clear();
  }
}
