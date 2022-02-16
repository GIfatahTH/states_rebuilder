import 'package:states_rebuilder/states_rebuilder.dart';

class FakeStore implements IPersistStore {
  late Map<String, String> _store;
  @override
  Future<void> init() async {
    _store = {};
  }

  @override
  Object? read(String key) {
    return _store[key];
  }

  @override
  Future<void> write<T>(String key, T value) async {
    Future.delayed(Duration(milliseconds: 500));
    _store[key] = value as String;
  }

  @override
  Future<void> delete(String key) async {
    Future.delayed(Duration(milliseconds: 500));
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    Future.delayed(Duration(milliseconds: 500));
    _store.clear();
  }
}
