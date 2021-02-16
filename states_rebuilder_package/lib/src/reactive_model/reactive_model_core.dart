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
  SnapState<T>? Function(MiddleSnapState<T> middleSnap)? _middleState;

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

  SnapState<T> _snapState = SnapState._nothing(initMessage);
  SnapState<T> get snapState => _snapState;
  set snapState(SnapState<T> snap) {
    _snapState = snap;
    if (_isInitialized) {
      _state = (snap.hasError ? _state : snap.data) ?? _nullState;
    }
  }

  Completer<dynamic>? _completer;
  void _initCompleter() {
    _completer = Completer<dynamic>();
  }

  void _completeCompleter(T? _state) {
    if (_completer?.isCompleted == false) {
      _completer!.complete(_state);
    }
    _completer = null;
  }

  void _completeCompleterError(Object e, StackTrace s) {
    _completer?.completeError(e, s);
    _completer = null;
  }

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
    required String? infoMessage,
  }) {
    _initCompleter();

    final snap = snapState._copyToIsWaiting(
      data: _state,
      infoMessage: infoMessage,
    );
    snapState = _middleState?.call(
          MiddleSnapState(_snapState, snap),
        ) ??
        snap;

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
    bool isSync = false,
  }) {
    if (data is T) {
      final snap = _snapState._copyToHasData(
        data,
        infoMessage: isSync ? '' : null,
      );
      if (_snapState == snap) {
        //the snap state is immutable and not changed.
        return;
      }
      if (_watch != null &&
          deepEquality.equals(_cachedWatch, _cachedWatch = _watch!(data))) {
        return;
      }
      snapState = _middleState?.call(
            MiddleSnapState(_snapState, snap),
          ) ??
          snap;
      addToUndoQueue();
    } else {
      final snap = _snapState._copyToHasData(
        _state,
        infoMessage: isSync ? '' : null,
      );
      snapState = _middleState?.call(
            MiddleSnapState(_snapState, snap),
          ) ??
          snap;
    }

    _completeCompleter(snapState.data);

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
    final snap = snapState._copyToHasError(
      e,
      onErrorRefresher,
      stackTrace: s,
    );

    // assert(() {
    //   _debugError?.call(e, s);
    //   return true;
    // }());

    if (e is Error) {
      _middleState?.call(
        MiddleSnapState(_snapState, snap),
      );
      // StatesRebuilerLogger.log('', e, s);
      throw e;
    }

    snapState = _middleState?.call(
          MiddleSnapState(_snapState, snap),
        ) ??
        snap;

    if (_completer?.isCompleted == false) {
      _completer!.future.catchError((Object _) {});
      _completeCompleterError(e as Object, s);
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
    if (on != null) {
      on!._callForSideEffects(_snapState);
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
    if (on != null) {
      on!._callForSideEffects(_snapState);
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
    if (on != null) {
      on!._callForSideEffects(_snapState);
      return;
    }
    this.onError?.call(e, s);
    //   },
    // );
  }
}
