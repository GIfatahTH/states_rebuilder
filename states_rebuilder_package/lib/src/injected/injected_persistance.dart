part of '../injected.dart';

///PersistStore Interface to implementation.
///
///You don't have to use try-catch, as it is done by the library.
abstract class IPersistStore {
  ///Initialize the localStorage service
  Future<void> init();

  ///Read from localStorage
  Object read(String key);

  ///Write on the localStorage
  Future<void> write<T>(String key, T value);

  ///Delete
  Future<void> delete(String key);

  ///Purge localStorage
  Future<void> deleteAll();
}

///Mock implementation of [IPersistStore] used for test
class PersistStoreMock extends IPersistStore {
  ///The fake store
  Map<String, String> store;
  bool isAsyncRead = false;
  dynamic exception;
  int timeToThrow = 0;
  PersistStoreMock();
  @override
  Future<void> init() {
    final oldStore = (persistStateGlobalTest as PersistStoreMock)?.store;
    if (oldStore != null) {
      store = oldStore;
    } else {
      store = <String, String>{};
    }

    return Future.value();
  }

  @override
  Future<void> delete(String key) async {
    if (exception != null) {
      await Future.delayed(
        Duration(milliseconds: timeToThrow),
        () => throw exception,
      );
    }
    store.remove(key);
    return Future.value();
  }

  @override
  Future<void> deleteAll() async {
    if (exception != null) {
      await Future.delayed(
        Duration(milliseconds: timeToThrow),
        () => throw exception,
      );
    }
    store.clear();
    return Future.value();
  }

  @override
  Object read(String key) {
    if (isAsyncRead) {
      if (exception != null) {
        return Future.delayed(
          Duration(milliseconds: timeToThrow),
          () => throw exception,
        );
      }
      return Future.value(store[key]);
    }
    if (exception != null) {
      throw exception;
    }
    return store[key];
  }

  @override
  Future<void> write<T>(String key, T value) async {
    if (exception != null) {
      await Future.delayed(
        Duration(milliseconds: timeToThrow),
        () => throw exception,
      );
    }
    store[key] = '$value';
    return Future.value();
  }

  void clear() {
    store.clear();
    isAsyncRead = false;
    exception = null;
    timeToThrow = 0;
  }
}

///State persistence setting.
class PersistState<T> {
  ///String identifer to be use to store the state
  final String key;

  ///Callback that exposes the String representation of the state and returns
  ///the parsed state.
  final FutureOr<T> Function(String json) fromJson;

  ///Callback that exposes the current state and returns a String representation
  ///of the state.
  final String Function(T s) toJson;

  ///Enum to determine when to persist the state:
  ///- null: the state is persisted on each change. This is the default case.
  ///- PersistOn.disposed: The state is persisted one time when the state is
  ///disposed.
  ///- PersistOn.manualPersist: The state is persisted manually using
  ///[Injected._persistState] method.
  final PersistOn persistOn;

  ///The throttle delay in milliseconds. The state is persisted once at the
  ///end of the given delay.
  final int throttleDelay;
  final bool debugPrintOperations;

  final bool catchPersistError;
  final IPersistStore persistStateProvider;

  Timer _throttleTimer;
  T _valueForThrottle;

  ///State persistence setting.
  PersistState({
    @required this.key,
    @required this.toJson,
    @required this.fromJson,
    this.persistOn,
    this.throttleDelay,
    this.catchPersistError = false,
    this.debugPrintOperations = false,
    this.persistStateProvider,
  });

  IPersistStore get _persistState {
    persistStateSingleton ??= persistStateGlobalTest;
    persistStateSingleton ??= (persistStateProvider ?? persistStateGlobal);

    assert(persistStateSingleton != null, '''
No implementation of `IPersistStore` is provided.
Pleas implementation the `IPersistStore` interface and Initialize it in the main 
method.

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  await RM.localStorageInitializer(YouImplementation());
  runApp(_MyApp());
}

If you are testing the app use:

await RM.localStorageInitializerMock();


''');
    return persistStateSingleton;
  }

  IPersistStore persistStateSingleton;
  bool _isInitialized = false;

  ///Get the persisted state
  Object read() {
    final persistState = _persistState;
    if (persistStateProvider != null && !_isInitialized) {
      _isInitialized = true;
      return persistState.init().then(
            (_) => () => read(),
          );
    }

    try {
      final dynamic r = persistState.read(key) as dynamic;
      if (r == null) {
        return null;
      }
      if (r is Future) {
        return r.then((value) => () => _fromJsonHandler(key, value));
      }

      return _fromJsonHandler(key, r);
    } catch (e, s) {
      if (catchPersistError) {
        StatesRebuilerLogger.log('Read form localStorage error', e, s);
        return null;
      }
      rethrow;
    }
  }

  Object _fromJsonHandler(String key, String json) {
    if (debugPrintOperations) {
      StatesRebuilerLogger.log(
        'PersistState: read($key) :$json',
      );
    }
    return fromJson(json);
  }

  ///persist the state
  Future<void> write(T value) async {
    final persistState = _persistState;
    // try {
    if (throttleDelay != null) {
      _valueForThrottle = value;
      if (_throttleTimer != null) {
        return null;
      }
      _throttleTimer = Timer(Duration(milliseconds: throttleDelay), () async {
        _throttleTimer = null;
        final r =
            await persistState.write<String>(key, toJson(_valueForThrottle));
        _valueForThrottle = null;
        if (debugPrintOperations) {
          StatesRebuilerLogger.log(
            'PersistState: write(${key}, $_valueForThrottle)',
          );
        }
        return r;
      });
      return null;
    }
    final json = toJson(value);
    final r = await persistState.write<String>(key, json);
    if (debugPrintOperations) {
      StatesRebuilerLogger.log(
        'PersistState: write(${key}, $json)',
      );
    }
    return r;
    // } catch (e, s) {
    //   if (onPersistError != null) {
    //     var undo;
    //     final r = onPersistError(e, s);
    //     if (r is Future) {
    //       undo = await r;
    //     } else {
    //       undo = r;
    //     }
    //     if ((undo ?? true) == false) {
    //       return null;
    //     }
    //   } else {
    //     StatesRebuilerLogger.log('Write to localStorage error', e);
    //   }
    //   rethrow;
    // }
  }

  ///Delete the persisted state
  Future<void> delete() async {
    final persistState = _persistState;
    try {
      final r = await persistState.delete(key);
      StatesRebuilerLogger.log('PersistState: delete(${key})');
      return r;
    } catch (e, s) {
      if (catchPersistError) {
        StatesRebuilerLogger.log('Delete from localStorage error', e, s);
        return null;
      }
      rethrow;
    }
  }

  ///Delete all data in localStorage
  Future<void> deleteAll() async {
    final persistState = _persistState;
    try {
      final r = await persistState.deleteAll();
      StatesRebuilerLogger.log('PersistState: deleteAll');
      return r;
    } catch (e, s) {
      if (catchPersistError) {
        StatesRebuilerLogger.log('Delete all from localStorage error', e, s);
        return null;
      }
      rethrow;
    }
  }
  //TODO
  // void dispose() {
  //   persistStateSingleton = null;
  // }
}

///Enums {disposed, manualPersist}
enum PersistOn {
  ///The state is persisted one time when the state is disposed.
  disposed,

  ///The state is persisted manually using
  manualPersist,
}

// class _PersistenceException implements Exception {
//   final dynamic error;
//   _PersistenceException(this.error);
// }
