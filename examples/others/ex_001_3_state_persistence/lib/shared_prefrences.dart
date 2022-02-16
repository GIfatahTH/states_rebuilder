import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class SharedPreferencesStore implements IPersistStore {
  late SharedPreferences _sharedPreferences;

  @override
  Future<void> init() async {
    //Initialize the plugging

    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Object? read(String key) {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<void> write<T>(String key, T value) async {
    await _sharedPreferences.setString(key, value as String);
  }

  @override
  Future<void> delete(String key) async {
    await _sharedPreferences.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    await _sharedPreferences.clear();
  }
}
