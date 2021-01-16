part of '../reactive_model.dart';

class ReactiveModelCore<T> {
  final void Function([List<dynamic>? tags]) notifyListeners;
  final void Function() persistState;
  final void Function() addToUndoQueue;
  void Function()? onWaiting;
  void Function(T s)? onData;
  On<void>? on;
  void Function(dynamic e, StackTrace? s)? onError;
  PersistState<T>? persistanceProvider;

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
    required bool skipWaiting,
    bool shouldNotify = true,
    On<void>? onSetState,
    BuildContext? context,
  }) {
    if (skipWaiting) {
      return;
    }
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
      addToUndoQueue();
      snapState = snap;
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
    On<void>? onSetState,
    Function(dynamic? error)? onError,
    BuildContext? context,
  }) {
    if (e is Error) {
      StatesRebuilerLogger.log('', e, s);
    }
    snapState = SnapState<T>._withError(
      ConnectionState.done,
      snapState.data,
      e,
      s,
    );
    if (_completer?.isCompleted == false) {
      _completer!
        ..future.catchError((dynamic _) => {})
        ..completeError(e, s);
    }
    RM.context = context;
    _callOnError(e, s, onSetState, onError);
    notifyListeners();
  }

  void _callOnData([On<void>? onSetState, dynamic Function(T)? onData]) {
    if (onSetState != null && onSetState._hasOnData) {
      onSetState.call(isIdle: false, isWaiting: false);
      return;
    }
    if (onData != null) {
      onData.call(_state!);
      return;
    }
    if (on != null && on!._hasOnData) {
      on!.call(isIdle: false, isWaiting: false);
      return;
    }
    this.onData?.call(_state!);
  }

  void _callOnWaiting(
    On<void>? onSetState,
  ) {
    if (onSetState != null && onSetState._hasOnWaiting) {
      onSetState.call(isIdle: false, isWaiting: true);
      return;
    }
    if (on != null && on!._hasOnWaiting) {
      on!.call(isIdle: false, isWaiting: true);
      return;
    }
    onWaiting?.call();
  }

  void _callOnError(
    dynamic e,
    StackTrace? s, [
    On<void>? onSetState,
    void Function(dynamic)? onError,
  ]) {
    if (onSetState != null && onSetState._hasOnError) {
      onSetState(isIdle: false, isWaiting: false, error: e);
      return;
    }
    if (onError != null) {
      onError.call(e);
      return;
    }
    if (on != null && on!._hasOnError) {
      on!.call(isIdle: false, isWaiting: false, error: e);
      return;
    }
    this.onError?.call(e, s);
  }
}
