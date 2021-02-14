part of '../reactive_model.dart';

class ReactiveModelCore<T> {
  final void Function([List<dynamic>? tags]) notifyListeners;
  final void Function() persistState;
  final void Function() addToUndoQueue;
  void Function()? onWaiting;
  void Function(T s)? onData;
  On<void>? on;
  Object? Function(T? s)? _watch;
  Object? _cachedWatch;

  void Function(dynamic e, StackTrace? s)? onError;
  PersistState<T>? persistanceProvider;
  void Function(dynamic error, StackTrace stackTrace)? _debugError;
  void Function(SnapState snapSate)? _debugNotification;

  ReactiveModelCore({
    required this.notifyListeners,
    required this.persistState,
    required this.addToUndoQueue,
    this.onWaiting,
    this.onData,
    this.onError,
    this.persistanceProvider,
  });

  T? _nullState;
  T get nullState => _nullState!;
  bool _isInitialized = false;
  T? _state;
  SnapState<T>? _previousSnapState;

  SnapState<T> _snapState = SnapState._nothing();
  SnapState<T> get snapState => _snapState;
  set snapState(SnapState<T> snap) {
    _snapState = snap;
    if (_isInitialized) {
      _state = (snap.hasError ? _state : snap.data) ?? _nullState;
    }
  }

  Completer<dynamic>? _completer;

  // void _setToIsIdle() {
  //   if (_completer?.isCompleted == false) {
  //     _completer!.complete(_state);
  //   }
  //   if (_isInitialized) {
  //     snapState = SnapState._withData(
  //       ConnectionState.none,
  //       _state!,
  //       snapState.isImmutable,
  //     );
  //   }
  // }

  void _setToIsWaiting({
    bool shouldNotify = true,
    On<void>? onSetState,
    BuildContext? context,
  }) {
    _completer = Completer<dynamic>();
    snapState = SnapState._waiting(_state);

    if (shouldNotify) {
      RM.context = context;
      _callOnWaiting(onSetState);

      notifyListeners();
    }
  }

  void _setToHasData(
    dynamic data, {
    Function(T data)? onData,
    On<void>? onSetState,
    void Function()? onRebuildState,
    BuildContext? context,
  }) {
    if (data is T) {
      final snap = SnapState<T>._withData(ConnectionState.done, data, true);
      if (_snapState == snap) {
        //the snap state is immutable and not changed.
        return;
      }
      if (_watch != null &&
          deepEquality.equals(_cachedWatch, _cachedWatch = _watch!(data))) {
        return;
      }
      snapState = snap;
      addToUndoQueue();
    } else {
      snapState = SnapState<T>._withData(ConnectionState.done, _state!, false);
    }

    if (_completer?.isCompleted == false) {
      _completer!.complete(_state);
    }

    RM.context = context;
    //onData of setState override onData of injected
    _callOnData(onSetState, onData);

    notifyListeners();
    if (onRebuildState != null) {
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) => onRebuildState(),
      );
    }
    if (persistanceProvider != null && persistanceProvider!.persistOn == null) {
      persistState();
    }
  }

  void _setToHasError(
    dynamic e,
    StackTrace s, {
    required void Function() onErrorRefresher,
    On<void>? onSetState,
    Function(dynamic? error)? onError,
    BuildContext? context,
  }) {
    assert(() {
      _debugError?.call(e, s);
      return true;
    }());

    if (e is Error) {
      StatesRebuilerLogger.log('', e, s);
      throw e;
    }

    snapState = SnapState<T>._withError(
      ConnectionState.done,
      snapState.data,
      e,
      onErrorRefresher,
      s,
    );

    if (_completer?.isCompleted == false) {
      _completer!
        ..future.catchError((Object _) {})
        ..completeError(e as Object, s);
    }
    RM.context = context;
    _callOnError(e, s, onSetState, onError);
    notifyListeners();
  }

  void _callOnData([On<void>? onSetState, dynamic Function(T)? onData]) {
    // SchedulerBinding.instance?.scheduleFrameCallback(
    //   (_) {
    if (onSetState != null && onSetState._hasOnData) {
      onSetState._call(_snapState);
      return;
    }
    if (onData != null) {
      onData.call(_state!);
      return;
    }
    if (on != null && on!._hasOnData) {
      on!._call(_snapState);
      return;
    }
    this.onData?.call(_state!);
    //   },
    // );
  }

  void _callOnWaiting(
    On<void>? onSetState,
  ) {
    // SchedulerBinding.instance?.scheduleFrameCallback(
    //   (_) {
    if (onSetState != null && onSetState._hasOnWaiting) {
      onSetState._call(_snapState);
      return;
    }
    if (on != null && on!._hasOnWaiting) {
      on!._call(_snapState);
      return;
    }
    onWaiting?.call();
    //   },
    // );
  }

  void _callOnError(
    dynamic e,
    StackTrace? s, [
    On<void>? onSetState,
    void Function(dynamic)? onError,
  ]) {
    // SchedulerBinding.instance?.scheduleFrameCallback(
    //   (_) {
    if (onSetState != null && onSetState._hasOnError) {
      onSetState._call(_snapState);
      return;
    }
    if (onError != null) {
      onError.call(e);
      return;
    }
    if (on != null && on!._hasOnError) {
      on!._call(_snapState);
      return;
    }
    this.onError?.call(e, s);
    //   },
    // );
  }
}
