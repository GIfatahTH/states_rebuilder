part of '../../rm.dart';

IPersistStore? _persistStateGlobalTest;

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
  int timeToWait = 0;
  @override
  Future<void> init() {
    final oldStore = (_persistStateGlobalTest as _PersistStoreMock).store;
    if (oldStore != null) {
      store = oldStore;
    } else {
      store = <String, String>{};
    }

    return timeToWait == 0
        ? Future.value()
        : Future.delayed(Duration(milliseconds: timeToWait));
  }

  @override
  Future<void> delete(String key) async {
    if (exception != null) {
      await Future.delayed(
        Duration(milliseconds: timeToThrow),
        () => throw exception!,
      );
    }

    if (timeToWait == 0) {
      store?.remove(key);
      return;
    } else {
      return Future.delayed(
        Duration(milliseconds: timeToWait),
        () => store?.remove(key),
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    if (exception != null) {
      await Future.delayed(
        Duration(milliseconds: timeToThrow),
        () => throw exception!,
      );
    }
    if (timeToWait == 0) {
      store?.clear();
      return;
    } else {
      return Future.delayed(
        Duration(milliseconds: timeToWait),
        () => store?.clear(),
      );
    }
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
      return timeToWait == 0
          ? Future.value(store?[key])
          : Future.delayed(
              Duration(milliseconds: timeToWait), () => store?[key]);
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
    if (timeToWait == 0) {
      store?[key] = '$value';
      return;
    } else {
      return Future.delayed(
        Duration(milliseconds: timeToWait),
        () => store?[key] = '$value',
      );
    }
  }

  ///Clear the store, Typically used inside setUp method of tests
  void clear() {
    store?.clear();
    isAsyncRead = false;
    exception = null;
    timeToThrow = 0;
    timeToWait = 0;
  }

  String toString() {
    return '$store';
  }
}
