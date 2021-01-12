part of '../../reactive_model.dart';

///Mock implementation of [IPersistStore] used for test
class _PersistStoreMock extends IPersistStore {
  ///The fake store
  Map<String, String>? store;
  bool isAsyncRead = false;

  ///Exception to throw
  Exception? exception;

  ///Milliseconds to await before throwing
  int timeToThrow = 0;

  ///Milliseconds to await for async operation
  int? timeToWait;
  @override
  Future<void> init() {
    final oldStore = (_persistStateGlobalTest as _PersistStoreMock).store;
    if (oldStore != null) {
      store = oldStore;
    } else {
      store = <String, String>{};
    }

    return timeToWait == null
        ? Future.value()
        : Future.delayed(Duration(milliseconds: timeToWait!));
  }

  @override
  Future<void> delete(String key) async {
    if (exception != null) {
      await Future.delayed(
        Duration(milliseconds: timeToThrow),
        () => throw exception!,
      );
    }
    store?.remove(key);
    return timeToWait == null
        ? Future.value()
        : Future.delayed(Duration(milliseconds: timeToWait!));
  }

  @override
  Future<void> deleteAll() async {
    if (exception != null) {
      await Future.delayed(
        Duration(milliseconds: timeToThrow),
        () => throw exception!,
      );
    }
    store?.clear();
    return timeToWait == null
        ? Future.value()
        : Future.delayed(Duration(milliseconds: timeToWait!));
  }

  @override
  Object? read(String key) {
    if (isAsyncRead) {
      if (exception != null) {
        return Future.delayed(
          Duration(milliseconds: timeToThrow),
          () => throw exception!,
        );
      }
      return timeToWait == null
          ? Future.value(store?[key])
          : Future.delayed(
              Duration(milliseconds: timeToWait!), () => store?[key]);
    }
    if (exception != null) {
      throw exception!;
    }
    return store?[key];
  }

  @override
  Future<void> write<T>(String key, T value) async {
    if (exception != null) {
      await Future.delayed(
        Duration(milliseconds: timeToThrow),
        () => throw exception!,
      );
    }
    store?[key] = '$value';
    return timeToWait == null
        ? Future.value()
        : Future.delayed(Duration(milliseconds: timeToWait!));
  }

  ///Clear the store, Typically used indide setUp method of tests
  void clear() {
    store?.clear();
    isAsyncRead = false;
    exception = null;
    timeToThrow = 0;
  }
}
