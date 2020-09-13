part of '../injected.dart';

///PersistStore Interface to implementation.
///
///You don't have to use try-catch, as it is done by the library.
abstract class IPersistStore {
  ///Initialize the localStorage service
  Future<void> init();

  ///Read from localStorage
  T read<T>(String key);

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
  Map<dynamic, dynamic> store;

  @override
  Future<void> init() {
    store = <dynamic, dynamic>{};
    return Future.value();
  }

  @override
  Future<void> delete(String key) {
    store.remove(key);
    return Future.value();
  }

  @override
  Future<void> deleteAll() {
    store.clear();
    return Future.value();
  }

  @override
  T read<T>(String key) {
    return store[key] as T;
  }

  @override
  Future<void> write<T>(String key, T value) {
    store[key] = value;
    return Future.value();
  }
}

///State persistence setting.
class PersistState<T> {
  ///String identifer to be use to store the state
  final String key;

  ///Callback that exposes the String representation of the state and returns
  ///the parsed state.
  final T Function(String json) fromJson;

  ///Callback that exposes the current state and returns a String representation
  ///of the state.
  final String Function(T s) toJson;

  ///Enum to determine when to persist the state:
  ///- null: the state is persisted on each change. This is the default case.
  ///- PersistOn.disposed: The state is persisted one time when the state is
  ///disposed.
  ///- PersistOn.manualPersist: The state is persisted manually using
  ///[Injected.persistState] method.
  final PersistOn persistOn;

  ///The throttle delay in milliseconds. The state is persisted once at the
  ///end of the given delay.
  final int throttleDelay;
  Timer _throttleTimer;
  T _valueForThrottle;

  ///State persistence setting.
  PersistState({
    @required this.key,
    @required this.fromJson,
    @required this.toJson,
    this.persistOn,
    this.throttleDelay,
  });

  IPersistStore get _persistState {
    assert(persistState != null, '''
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
    return persistState;
  }

  ///Get the persisted state
  T read() {
    final persistState = _persistState;
    try {
      final result = persistState.read<String>(key);
      if (result == null) {
        return null;
      }
      return fromJson(result);
    } catch (e) {
      StatesRebuilerLogger.log(
        'Read form localStorage error',
        e,
      );
      return null;
    }
  }

  ///persist the state
  Future<void> write(T value) {
    final persistState = _persistState;

    try {
      if (throttleDelay != null) {
        _valueForThrottle = value;
        if (_throttleTimer != null) {
          return null;
        }
        _throttleTimer = Timer(Duration(milliseconds: throttleDelay), () {
          _throttleTimer = null;
          final r = persistState.write<String>(key, toJson(_valueForThrottle));
          _valueForThrottle = null;
          return r;
        });
        return null;
      }
      return persistState.write<String>(key, toJson(value));
    } catch (e) {
      StatesRebuilerLogger.log(
        'Write to localStorage error',
        e,
      );

      return null;
    }
  }

  ///Delete the persisted state
  Future<void> delete() {
    final persistState = _persistState;

    try {
      return persistState.delete(key);
    } catch (e) {
      StatesRebuilerLogger.log(
        'Delete from localStorage error',
        e,
      );
      return null;
    }
  }

  ///Delete all data in localStorage
  Future<void> deleteAll() {
    final persistState = _persistState;

    try {
      return persistState.deleteAll();
    } catch (e) {
      StatesRebuilerLogger.log(
        'Delete all from localStorage error',
        e,
      );
      return null;
    }
  }
}

///Enums {disposed, manualPersist}
enum PersistOn {
  ///The state is persisted one time when the state is disposed.
  disposed,

  ///The state is persisted manually using
  manualPersist,
}

///States_Rebuilder logger
class StatesRebuilerLogger {
  ///Set to true to avoid printing in test mode
  static bool isTestMode = false;

  ///The current printed message
  static String message;

  ///Console log the error
  static void log(String m, [dynamic e, StackTrace s]) {
    String errorMessage;
    try {
      errorMessage = e?.message as String;
    } catch (e) {
      errorMessage = '$e';
    }
    errorMessage ??= '';

    message = '[states_rebuilder]: $m: $errorMessage';
    if (!isTestMode) print(message);
  }
}
