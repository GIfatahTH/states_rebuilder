part of '../reactive_model.dart';

class InjectedImp<T> extends ReactiveModelImp<T> with Injected<T> {
  // final PersistState<T> Function() _persistCallback;

  InjectedImp({
    required dynamic Function(ReactiveModel<T> rm) creator,
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
    bool isLazy = true,
  }) : super._(
          nullState: nullState,
          initialState: initialValue,
        ) {
    if (persist == null) {
      _creator = creator;
    } else {
      late FutureOr<T> Function(ReactiveModel<T> rm) c;
      _creator = (rm) {
        if (!_isFirstInitialized) {
          //_isFirstInitialized is set to false fro each unit test
          _coreRM.persistanceProvider = persist();
          var result = _coreRM.persistanceProvider!.read();
          if (result is Future) {
            c = (rm) async {
              var innerResult = await (result as Future?);
              result = null;
              if (innerResult is Function) {
                innerResult = await innerResult();
                if (innerResult is Function) {
                  innerResult = await innerResult();
                }
              }
              _isStateInitiallyPersisted = innerResult != null;
              return innerResult ?? creator(rm);
            };
          } else {
            c = (rm) {
              _isStateInitiallyPersisted = result != null;
              var r = result;
              result = null;
              return r ?? creator(rm);
            };
          }
        }
        return c(rm);
      };
    }

    _autoDisposeWhenNotUsed = autoDisposeWhenNotUsed;
    _onInitialized = onInitialized;
    _onDisposed = onDisposed;
    _watch = watch;
    _undoStackLength = undoStackLength;
    _dependsOn = dependsOn != null ? dependsOn as DependsOn<T> : null;
    _debugPrintWhenNotifiedPreMessage = debugPrintWhenNotifiedPreMessage;
    //
    _coreRM
      ..onWaiting = onWaiting
      ..onError = onError
      ..onData = onData
      ..on = on;

    if (_debugPrintWhenNotifiedPreMessage != null) {
      listenToRM((rm) {
        final post = rm._snapState.isIdle ? '- Refreshed' : '';
        print('states_rebuilder:: $rm $post');
      });
    }

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
      if (e is Error) {
        rethrow;
      }
      _persistHasError = true;

      //SetState to oldState and set all completed
      if (_coreRM._previousSnapState?.data != null) {
        setState(
          (s) => _coreRM._previousSnapState?.data,
          //Set to has error
          onRebuildState: () => setState(
            (s) => throw e,
            catchError: _coreRM.onError != null,
          ),
        );
      }
      if (_coreRM.persistanceProvider?.debugPrintOperations ?? false) {
        StatesRebuilerLogger.log('PersistState Write ERROR', e, stackTrace);
      }
      _persistHasError = false;
    }
  }

  @override
  String toString() {
    final pre = _debugPrintWhenNotifiedPreMessage ?? '';
    final status = '$snapState';
    return '$pre Injected<$T>(${status.isEmpty ? _state : status})';
  }
}
