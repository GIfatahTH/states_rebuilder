part of '../../rm.dart';

IPersistStore? _persistStateGlobal;

///State persistence setting.
class PersistState<T> {
  ///String identifer to be use to store the state
  final String key;

  ///Optional callback that exposes the String representation of the state and returns
  ///the parsed state.
  ///
  ///**If it is not defined,it will be inferred form primitive:**
  ///* int: (String json)=> int.parse(json);
  ///* double: (String json)=> double.parse(json);
  ///* String: (String json)=> json;
  ///* bool: (String json)=> json =='1';
  ///
  ///If it is not defined and the model is not primitive, **it will throw and
  ///ArgumentError**.
  FutureOr<T> Function(String json)? fromJson;

  ///Callback that exposes the current state and returns a String representation
  ///of the state.
  ///
  ///**If it is not defined,it will be inferred form primitive:**
  ///* int: (int s)=> '$s';
  ///* double: (double s)=> '$s';
  ///* String: (String s)=> '$s';
  ///* bool: (bool s)=> s? '1' : '0';
  ///
  ///If it is not defined and the model is not primitive, **it will throw and
  ///ArgumentError**.
  String Function(T s)? toJson;

  ///Enum to determine when to persist the state:
  ///- null: the state is persisted on each change. This is the default case.
  ///- PersistOn.disposed: The state is persisted one time when the state is
  ///disposed.
  ///- PersistOn.manualPersist: The state is persisted manually using
  ///[Injected.persistState] method.
  PersistOn? persistOn;

  ///The throttle delay in milliseconds. The state is persisted once at the
  ///end of the given delay.
  final int? throttleDelay;

  ///Debug print an informative message on the Read, Write, Delete operations
  final bool debugPrintOperations;

  ///Whether to catch error of read, delete and deleteAll methods.
  final bool catchPersistError;

  ///Determines whether the state builder function should be invoked after the
  ///persistant state has been loaded or not.
  ///
  ///If no persistant state has been found, the builder function is re-invoked
  ///in any case. Upon completing to load the persistant state, the states
  ///`isWaiting` value is `true` which indicates that the builder function is
  ///re-invoked and the state waits for data. Use `hasData` to verify if
  ///persistant data exists.
  ///
  ///The default value is `false` except for [RM.injectedStream] which is `true`.
  ///
  ///Re-invoking the builder function upon loading the persistant state is
  ///especially useful for async states. Imagine you are developing an IoT app:
  ///You have a state that streams data from the IoT devices and displays them
  ///in the app. The streamed state should be persistant to show previous data
  ///of the IoT devices upon re-opening the app (re-initializing the state).
  ///The persistant state ensures that the user does not see "no data" from the
  ///devices or a loading spinner until the current data has ben retrieved.
  ///However, after loading the persistant state, the stream (builder function)
  ///should be re-invoked to start listening to the current data from the IoT devices.
  final bool? shouldRecreateTheState;

  ///Persistance provider that will be used to persist this state instead of
  ///the default persistance provider defined with [RM.storageInitializer].
  final IPersistStore? persistStateProvider;
  IPersistStore? _persistStateSingleton;
  bool _isInitialized = false;

  Timer? _throttleTimer;
  T? _valueForThrottle;
  String? cachedJson;

  ///State persistence setting.
  PersistState({
    required this.key,
    this.toJson,
    this.fromJson,
    this.persistOn,
    this.throttleDelay,
    this.catchPersistError = false,
    this.debugPrintOperations = false,
    this.persistStateProvider,
    this.shouldRecreateTheState,
  }) {
    fromJson ??= _getFromJsonOfPrimitive<T>();
    toJson ??= _getToJsonOfPrimitive<T>();
  }

  void setPersistStateSingleton() {
    _persistStateSingleton = (persistStateProvider ?? _persistStateGlobalTest);
    _persistStateSingleton ??= _persistStateGlobal;
    assert(_persistStateSingleton != null, '''
No implementation of `IPersistStore` is provided.
Pleas implementation the `IPersistStore` interface and Initialize it in the main 
method.

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  await RM.storageInitializer(YouImplementation());
  runApp(_MyApp());
}

If you are testing the app use:

await RM.storageInitializerMock();\n\n


''');
  }

  ///Get the persisted state
  Object? read() {
    setPersistStateSingleton();
    if (persistStateProvider != null && !_isInitialized) {
      _isInitialized = true;
      return _persistStateSingleton!.init().then(
            (_) => () => read(),
          );
    }

    try {
      final dynamic r =
          cachedJson ?? _persistStateSingleton!.read(key) as dynamic;
      if (r == null) {
        return null;
      }
      if (r is Future) {
        return r.then(
          (dynamic value) {
            cachedJson = value as String?;
            return () => _fromJsonHandler(
                  key,
                  cachedJson,
                );
          },
        );
      }
      cachedJson = r as String?;
      return _fromJsonHandler(key, cachedJson);
    } catch (e, s) {
      if (catchPersistError) {
        StatesRebuilerLogger.log('Read form localStorage error', e, s);
        return null;
      } else if (debugPrintOperations) {
        StatesRebuilerLogger.log(
          'PersistState: Read Error ($key) :$e',
        );
      }
      rethrow;
    }
  }

  FutureOr<T?> _fromJsonHandler(String key, String? json) {
    if (json == null) {
      return null;
    }
    if (debugPrintOperations) {
      StatesRebuilerLogger.log(
        'PersistState: read($key) :$json',
      );
    }
    return fromJson!(json);
  }

  ///persist the state
  Future<void> write(T value) async {
    setPersistStateSingleton();
    // try {
    if (throttleDelay != null) {
      _valueForThrottle = value;
      if (_throttleTimer != null) {
        return null;
      }
      _throttleTimer = Timer(Duration(milliseconds: throttleDelay!), () async {
        _throttleTimer = null;
        final r = await _persistStateSingleton!
            .write<String>(key, toJson!(_valueForThrottle!));
        if (debugPrintOperations) {
          StatesRebuilerLogger.log(
            'PersistState: write($key, $_valueForThrottle)',
          );
        }
        _valueForThrottle = null;
        return r;
      });
      return null;
    }
    final json = toJson!(value);
    if (json == cachedJson) {
      return;
    }
    cachedJson = json;
    await _persistStateSingleton!.write<String>(key, json);
    if (debugPrintOperations) {
      StatesRebuilerLogger.log(
        'PersistState: write($key, $json)',
      );
    }
  }

  ///Delete the persisted state
  Future<void> delete() async {
    setPersistStateSingleton();
    try {
      final r = await _persistStateSingleton!.delete(key);
      cachedJson = null;
      if (debugPrintOperations) {
        StatesRebuilerLogger.log('PersistState: delete($key)');
      }
      return r;
    } catch (e, s) {
      if (catchPersistError) {
        StatesRebuilerLogger.log('Delete from localStorage error', e, s);
        return null;
      }
      if (debugPrintOperations) {
        StatesRebuilerLogger.log(
          'PersistState: Delete Error ($key) :$e',
        );
      }
      rethrow;
    }
  }

  // ///Delete all data in localStorage
  // Future<void> deleteAll() async {
  //   final persistState = _persistState;
  //   try {
  //     final r = await persistState.deleteAll();
  //     StatesRebuilerLogger.log('PersistState: deleteAll');
  //     return r;
  //   } catch (e, s) {
  //     if (catchPersistError) {
  //       StatesRebuilerLogger.log('Delete all from localStorage error', e, s);
  //       return null;
  //     }
  //     rethrow;
  //   }
  // }
}

///Enums {disposed, manualPersist}
enum PersistOn {
  ///The state is persisted one time when the state is disposed.
  disposed,

  ///The state is persisted manually using
  manualPersist,
}

T Function(String) _getFromJsonOfPrimitive<T>() {
  String? nullableString = '';
  if (nullableString is T) {
    return (json) => json as T;
  }
  int? nullableInt = 0;
  if (nullableInt is T) {
    return (json) => int.parse(json) as T;
  }
  bool? nullableBool = false;
  if (nullableBool is T) {
    return (json) => (json == '1') as T;
  }
  double? nullableDouble = 0.0;
  if (nullableDouble is T) {
    return (json) => double.parse(json) as T;
  }
  throw ArgumentError(
    'Type is not primitive. '
    'You have to define fromJson parameter of PersistState',
  );
}

String Function(T) _getToJsonOfPrimitive<T>() {
  String? nullableString = '';
  if (nullableString is T) {
    return (T s) => s as String;
  }
  int? nullableInt = 0;
  if (nullableInt is T) {
    return (T s) => '$s';
  }
  bool? nullableBool = false;
  if (nullableBool is T) {
    return (T s) => (s as bool) ? '1' : '0';
  }
  double? nullableDouble = 0.0;
  if (nullableDouble is T) {
    return (T s) => '$s';
  }
  throw ArgumentError(
    'Type is not primitive. '
    'You have to define fromJson parameter of PersistState',
  );
}
