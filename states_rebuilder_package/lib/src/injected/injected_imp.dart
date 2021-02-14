part of '../reactive_model.dart';

class InjectedImp<T> extends ReactiveModelImp<T> with Injected<T> {
  // final PersistState<T> Function() _persistCallback;
  dynamic Function(ReactiveModel<T> rm) creator;
  InjectedImp({
    required this.creator,
    T? nullState,
    T? initialValue,
    bool autoDisposeWhenNotUsed = true,
    void Function(T s)? onData,
    void Function(dynamic e, StackTrace? s)? onError,
    void Function()? onWaiting,
    On<void>? on,
    void Function(T s)? onInitialized,
    void Function(T s)? onDisposed,
    Object? Function(T? s)? watch,
    DependsOn? dependsOn,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    String? debugPrintWhenNotifiedPreMessage,
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    void Function(SnapState snapState)? debugNotification,
    bool isLazy = true,
  }) : super._(
          nullState: nullState,
          initialState: initialValue,
        ) {
    if (persist == null) {
      _creator = creator;
    } else {
      _stateIsPersisted = true;
      late FutureOr<T> Function(ReactiveModel<T> rm) c;
      _creator = (rm) {
        if (!_isFirstInitialized) {
          //_isFirstInitialized is set to false fro each unit test
          _coreRM.persistanceProvider = persist();
          if (this is InjectedAuth) {
            _coreRM.persistanceProvider!.persistOn = PersistOn.manualPersist;
          }
          var result = _coreRM.persistanceProvider!.read();
          if (result is Future) {
            c = (rm) async {
              dynamic innerResult = await (result as Future?);
              result = null;
              if (innerResult is Function) {
                innerResult = await innerResult();
                if (innerResult is Function) {
                  innerResult = await innerResult();
                }
              }
              _shouldPersistStateOnInit =
                  innerResult == null && innerResult != initialValue;
              return (innerResult ?? creator(rm)) as FutureOr<T>;
            };
          } else {
            c = (rm) {
              _shouldPersistStateOnInit =
                  result == null && this is! InjectedAuth;
              var r = result;
              result = null;
              return (r ?? creator(rm)) as FutureOr<T>;
            };
          }
        }
        return c(rm);
      };
    }

    _autoDisposeWhenNotUsed = autoDisposeWhenNotUsed;
    _onInitialized = onInitialized;
    _onDisposed = onDisposed;
    _coreRM._watch = watch;
    _undoStackLength = undoStackLength;
    _dependsOn = dependsOn != null ? dependsOn as DependsOn<T> : null;
    _debugPrintWhenNotifiedPreMessage = debugPrintWhenNotifiedPreMessage;
    ;
    //
    _coreRM
      ..onWaiting = onWaiting
      ..onError = onError
      ..onData = onData
      .._debugError = debugError
      .._debugNotification = debugNotification
      ..on = on;

    if (!isLazy) {
      _initialize();
    }
  }

  bool _persistHasError = false;

  ///Save the current state to localStorage.
  @override
  Future<void> persistState() async {
    try {
      if (!_persistHasError) {
        await _coreRM.persistanceProvider?.write(state);
      }
    } catch (e) {
      final _previousSnapState = _coreRM._previousSnapState;
      setState(
        (s) async* {
          _persistHasError = true;
          if (_previousSnapState != null) {
            snapState = _previousSnapState;
          }
          _persistHasError = false;
          throw e;
        },
      );
    }
  }

  ///Delete the saved instance of this state form localStorage.
  @override
  void deletePersistState() => _coreRM.persistanceProvider?.delete();

  ///Clear localStorage
  @override
  void deleteAllPersistState() => _coreRM.persistanceProvider?.deleteAll();

  @override
  String toString() {
    final pre = _debugPrintWhenNotifiedPreMessage ?? '';
    final status = '$snapState';
    return '$pre Injected<$T>(${status.isEmpty ? _state : status})';
  }
}
