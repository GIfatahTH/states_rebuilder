part of '../../rm.dart';

///PersistStore Interface to implementation.
///
///You don't have to use try-catch, as it is done by the library.
///
///# Examples
///## SharedPreferences:
///```dart
///class SharedPreferencesImp implements IPersistStore {
///  late SharedPreferences _sharedPreferences;
///
///  @override
///  Future<void> init() async {
///    //Initialize the plugging
///    _sharedPreferences = await SharedPreferences.getInstance();
///  }
///
///  @override
///  Object? read(String key) {
///      return _sharedPreferences.getString(key);
///  }
///
///  @override
///  Future<void> write<T>(String key, T value) async {
///      await _sharedPreferences.setString(key, value as String);
///  }
///
///  @override
///  Future<void> delete(String key) async {
///    await _sharedPreferences.remove(key);
///  }
///
///  @override
///  Future<void> deleteAll() async {
///    await _sharedPreferences.clear();
///  }
///}
///```
///
///## Hive:
///```dart
///class HiveImp implements IPersistStore {
///  late Box box;
///
///  @override
///  Future<void> init() async {
///    await Hive.initFlutter();
///    box = await Hive.openBox('myBox');
///  }
///
///  @override
///  Object? read(String key) async {
///      return box.get(key);
///  }
///
///  @override
///  Future<void> write<T>(String key, T value) async {
///      await box.put(key, value);
///  }
///
///  @override
///  Future<void> delete(String key) async {
///    await box.delete(key);
///  }
///
///  @override
///  Future<void> deleteAll() async {
///    await box.clear();
///  }
///}
///```
///
abstract class IPersistStore {
  ///Initialize the localStorage service
  Future<void> init();

  ///Read from localStorage
  Object? read(String key);

  ///Write on the localStorage
  Future<void> write<T>(String key, T value);

  ///Delete
  Future<void> delete(String key);

  ///Purge localStorage
  Future<void> deleteAll();
}
