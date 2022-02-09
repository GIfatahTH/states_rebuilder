part of '../rm.dart';

class ReactiveModelImp<T> extends ReactiveModel<T> {
  ReactiveModelImp({
    required this.creator,
    required this.initialState,
    required this.autoDisposeWhenNotUsed,
    required this.stateInterceptorGlobal,
  }) : super() {
    resetDefaultState();
  }
  // Final fields
  final Object? Function() creator;
  T? initialState;
  final bool autoDisposeWhenNotUsed;
  final StateInterceptor<T>? stateInterceptorGlobal;
  late SnapState<T> _snapState;
  late bool isInitialized;
  late VoidCallback? removeFromReactiveModel;
  late Completer? completer;
  late Timer? _debounceTimer;
  late Timer? _dependentDebounceTimer;
  late bool _isDone;
  // This flag is used to indicate that the state when first created, it starts
  // by waiting for an async task.
  //
  // Used in
  late bool isWaitingToInitialize;

  // var fields. they deed to reset to default value after state disposing off
  // _resetDefaultState is used to reset var fields to default initial values
  VoidCallback get resetDefaultState => () {
        _clearObservers();
        _snapState = initialSnapState;
        isInitialized = false;
        removeFromReactiveModel = null;
        subscription?.cancel();
        subscription = null;
        completer = null;
        _debounceTimer = null;
        _dependentDebounceTimer = null;
        _isDone = false;
        isWaitingToInitialize = false;
        customStatus = null;
      };

  // Overridden methods
  @override
  T get state {
    return snapState.state;
  }

  @override
  set state(T value) {
    isInitialized = true;
    setStateNullable(
      (_) => value,
      middleSetState: middleSetState,
    );
  }

  @override
  Future<T> get stateAsync async {
    initialize();
    await completer?.future;
    if (_snapState.hasError) {
      final completer = Completer<T>();
      completer.completeError(
        _snapState.snapError!.error,
        _snapState.snapError!.stackTrace,
      );
      return completer.future;
    }
    return state;
  }

  @override
  set stateAsync(Future<T> value) {
    isInitialized = true;
    setStateNullable(
      (_) => value,
      middleSetState: middleSetState,
    );
  }

  int get observerLength => _listeners.length;

  @override
  Future<T?> setState(
    Object? Function(T s) mutator, {
    SideEffects<T>? sideEffects,
    StateInterceptor<T>? stateInterceptor,
    bool Function(SnapState<T> snap)? shouldOverrideDefaultSideEffects,
    int debounceDelay = 0,
    int throttleDelay = 0,
  }) {
    initialize();
    Future<T?> call() {
      final r = setStateNullable(
        (s) {
          return mutator(_snapState.state);
        },
        middleSetState: (status, result) => middleSetState(
          status,
          result,
          sideEffects: sideEffects,
          stateInterceptor: stateInterceptor,
          shouldOverrideDefaultSideEffects: shouldOverrideDefaultSideEffects,
        ),
      );
      if (r is T?) {
        return Future.value(r);
      }
      return r;
    }

    if (debounceDelay > 0) {
      subscription?.cancel();
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        Duration(milliseconds: debounceDelay),
        () {
          call();
          _debounceTimer = null;
        },
      );
      return Future.value(_snapState.state);
    } else if (throttleDelay > 0) {
      if (_debounceTimer != null) {
        return Future.value(_snapState.state);
      }
      _debounceTimer = Timer(
        Duration(milliseconds: throttleDelay),
        () {
          _debounceTimer = null;
        },
      );
    }
    return call();
  }

  FutureOr<T?> setStateNullable(
    Object? Function(T? s) mutator, {
    required void Function(StateStatus, dynamic result) middleSetState,
  }) {
    try {
      var result = mutator(_snapState.data);

      if (result is Future || result is Stream) {
        _handleAsyncState(
          mutator: mutator,
          asyncResult: result!,
          middleSetState: middleSetState,
        );
        return () async {
          try {
            await stateAsync;
          } catch (e) {
            return _snapState.data;
          }
        }();
      }
      if (_snapState.isWaiting && _snapState._infoMessage != kDependsOn) {
        _snapState = _snapState.copyToHasData(result).copyToIsWaiting();
        notify(shouldOverrideDefaultSideEffects: (_) => true);
      } else {
        middleSetState(
          StateStatus.hasData,
          result,
        );
      }
      return SynchronousFuture(_snapState.data);
    } catch (e, s) {
      if (e is Error && e is! UnimplementedError) {
        rethrow;
      }
      middleSetState(
        StateStatus.hasError,
        SnapError(
          error: e,
          stackTrace: s,
          refresher: () =>
              setStateNullable(mutator, middleSetState: middleSetState),
        ),
      );
      return SynchronousFuture(_snapState.data);
    }
  }

  middleSetState(
    StateStatus status,
    Object? result, {
    SideEffects<T>? sideEffects,
    StateInterceptor<T>? stateInterceptor,
    bool Function(SnapState<T>)? shouldOverrideDefaultSideEffects,
  }) {
    if (status == StateStatus.isWaiting) {
      setToIsWaiting(
        sideEffects: sideEffects,
        shouldOverrideDefaultSideEffects: shouldOverrideDefaultSideEffects,
        stateInterceptor: stateInterceptor,
      );
      return;
    }
    if (status == StateStatus.hasError) {
      assert(result is SnapError);
      setToHasError(
        (result as SnapError).error,
        stackTrace: result.stackTrace,
        refresher: result.refresher,
        sideEffects: sideEffects,
        shouldOverrideDefaultSideEffects: shouldOverrideDefaultSideEffects,
        stateInterceptor: stateInterceptor,
      );
      return;
    }
    setToHasData(
      result,
      sideEffects: sideEffects,
      shouldOverrideDefaultSideEffects: shouldOverrideDefaultSideEffects,
      stateInterceptor: stateInterceptor,
    );
  }

  SnapState<T>? interceptState(
    SnapState<T> snap,
    StateInterceptor<T>? stateInterceptor,
  ) {
    var newSnap = stateInterceptor?.call(snap.oldSnapState!, snap);
    newSnap =
        stateInterceptorGlobal?.call(snap.oldSnapState!, newSnap ?? snap) ??
            newSnap;

    newSnap ??= snap;
    // if (snap is SkipSnapState) {
    //   return null;
    // }
    if (newSnap.isWaiting) {
      if (_snapState.isWaiting) {
        return null;
      }
    } else if (newSnap.hasError) {
      if (_snapState.hasError &&
          newSnap.snapError!.error == _snapState.snapError?.error) {
        return null;
      }
    } else if (newSnap.hasData) {
      if (newSnap._isImmutable == true &&
          newSnap == _snapState &&
          _snapState._infoMessage != kRefreshMessage) {
        return null;
      }
    }
    return newSnap;
  }

  @override
  void setToIsIdle([Object? data]) {
    _snapState = _snapState.copyToIsIdle(data: data);
    notify();
  }

  @override
  void setToIsWaiting({
    SideEffects<T>? sideEffects,
    bool Function(SnapState<T>)? shouldOverrideDefaultSideEffects,
    StateInterceptor<T>? stateInterceptor,
  }) {
    _isDone = false;
    notify(
      nextSnap: _snapState.copyToIsWaiting(''),
      sideEffects: sideEffects,
      shouldOverrideDefaultSideEffects: shouldOverrideDefaultSideEffects,
      stateInterceptor: stateInterceptor,
    );
  }

  @override
  void setToHasData(
    dynamic data, {
    SideEffects<T>? sideEffects,
    bool Function(SnapState<T>)? shouldOverrideDefaultSideEffects,
    StateInterceptor<T>? stateInterceptor,
  }) {
    notify(
      nextSnap: _snapState.copyToHasData(data),
      sideEffects: sideEffects,
      shouldOverrideDefaultSideEffects: shouldOverrideDefaultSideEffects,
      stateInterceptor: stateInterceptor,
    );
  }

  @override
  void setToHasError(
    dynamic error, {
    StackTrace? stackTrace,
    VoidCallback? refresher,
    SideEffects<T>? sideEffects,
    bool Function(SnapState<T>)? shouldOverrideDefaultSideEffects,
    StateInterceptor<T>? stateInterceptor,
  }) {
    notify(
      nextSnap: _snapState._copyToHasError(
        SnapError(
          error: error,
          stackTrace: stackTrace,
          refresher: refresher ?? () {},
        ),
      ),
      sideEffects: sideEffects,
      shouldOverrideDefaultSideEffects: shouldOverrideDefaultSideEffects,
      stateInterceptor: stateInterceptor,
    );
  }

  @override
  bool notify({
    SnapState<T>? nextSnap,
    SideEffects<T>? sideEffects,
    bool Function(SnapState<T>)? shouldOverrideDefaultSideEffects,
    StateInterceptor<T>? stateInterceptor,
  }) {
    if (nextSnap != null) {
      final interceptedSnap = interceptState(nextSnap, stateInterceptor);
      if (interceptedSnap == null) {
        return false;
      }
      _snapState = interceptedSnap;
    }
    sideEffects
      ?..onSetState?.call(_snapState)
      .._onAfterBuild?.call();
    rebuildState();
    return true;
  }

  void rebuildState() {
    for (var listener in _listeners) {
      listener(this);
    }
    for (var listener in _dependentListeners) {
      listener(this);
    }
  }

  void _notifyDependentListeners() {
    for (var listener in _dependentListeners) {
      listener(this);
    }
  }

  @override
  void disposeIfNotUsed() {
    if (!hasObservers) {
      dispose();
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    removeFromReactiveModel?.call();
    resetDefaultState();
  }

  // Getter to be overridden by implementors
  Object? Function() get mockableCreator => creator;
  SnapState<T> get initialSnapState => SnapState<T>.none(
        infoMessage: kInitMessage,
        data: initialState,
      );
  void onStateInitialized() {}

  @override
  bool get hasData => snapState.hasData;

  @override
  bool get hasError => snapState.hasError;

  @override
  bool get isIdle => snapState.isIdle;

  @override
  bool get isWaiting => snapState.isWaiting;

  @override
  bool get isDone => _isDone;

  @override
  SnapState<T> get snapState {
    initialize();
    ReactiveStatelessWidget.addToObs?.call(this);
    // TopStatelessWidget.addToObs?.call(this);
    return _snapState;
  }

  SnapState<T> get snapValue {
    initialize();
    // ReactiveStatelessWidget.addToObs?.call(this);
    // TopStatelessWidget.addToObs?.call(this);
    return _snapState;
  }

  set snapValue(SnapState<T> value) {
    _snapState = value;
  }

  ///Refresh the [Injected] state. Refreshing the state means reinitialize
  ///it and reinvoke its creation function and notify its listeners.
  ///
  ///If the state is persisted using [PersistState], the state is deleted from
  ///the store and the new recalculated state is stored instead.
  ///
  ///If the Injected model has [Injected.inherited] injected models, they will
  ///be refreshed also.
  @override
  Future<T?> refresh() async {
    if (!isInitialized) {
      //If refresh is called in non initialized state
      //then just initialize it and return
      initialize();
    } else {
      _snapState = _snapState.copyToIsIdle(
        infoMessage: kRefreshMessage,
        data: initialState,
      );
      _notifyDependentListeners();
      setStateNullable(
        (_) => mockableCreator(),
        middleSetState: middleSetCreator,
      );
      if (!isWaitingToInitialize) {
        notify();
      }
    }

    try {
      return await stateAsync;
    } catch (e) {
      return _snapState.data;
    }
  }

  SnapState<T>? get oldSnapState {
    return _snapState.oldSnapState;
  }

  void initialize() {
    if (isInitialized) return;
    final creator = mockableCreator;
    removeFromReactiveModel = addToActiveReactiveModels(this);
    if (isInitialized) return;
    final cachedObs = ReactiveStatelessWidget.addToObs;
    ReactiveStatelessWidget.addToObs = null;
    isInitialized = true;
    setStateNullable(
      (_) => creator(),
      middleSetState: middleSetCreator,
    );
    onStateInitialized();
    ReactiveStatelessWidget.addToObs = cachedObs;
  }

  void middleSetCreator(StateStatus status, Object? result) {
    if (status == StateStatus.isWaiting) {
      isWaitingToInitialize = true;
      setToIsWaiting();
      return;
    }
    if (status == StateStatus.hasError) {
      assert(result is SnapError);
      if (isWaitingToInitialize) {
        setToHasError(
          (result as SnapError).error,
          stackTrace: result.stackTrace,
          refresher: result.refresher,
        );
      } else {
        _snapState = _snapState._copyToHasError(result as SnapError);
      }
      return;
    }
    if (isWaitingToInitialize) {
      setToHasData(result);
    } else {
      _snapState = _snapState.copyToIsIdle(data: result, infoMessage: '');
    }
  }

  void _handleAsyncState({
    required Object? Function(T? s) mutator,
    required Object asyncResult,
    required void Function(StateStatus, dynamic result) middleSetState,
  }) {
    Stream stream;
    if (asyncResult is Future) {
      stream = asyncResult.asStream();
    } else {
      stream = asyncResult as Stream;
    }
    completer = Completer();
    subscription?.cancel();
    subscription = stream.listen(
      (event) {
        if (event is T Function() || event is Stream) {
          // This is called from async read persisted state.
          // The state is read from local storage asynchronously. So as in
          // InjectedImpRedoPersistState.mockableCreator the creator return
          // a function after awaiting for the future.
          _snapState = _snapState
              .oldSnapState!; // Return to old state without notification.
          setStateNullable(
            (_) => event is T Function() ? event() : event,
            middleSetState: middleSetState,
          );
          return;
        }
        middleSetState(StateStatus.hasData, event);
        if (completer?.isCompleted == false) {
          completer!.complete();
        }
      },
      onError: (e, s) {
        middleSetState(
          StateStatus.hasError,
          SnapError(
            error: e,
            stackTrace: s,
            refresher: () =>
                setStateNullable(mutator, middleSetState: middleSetState),
          ),
        );
        if (completer?.isCompleted == false) {
          completer!.complete();
        }
      },
      onDone: () {
        _isDone = true;
      },
    );
    middleSetState(StateStatus.isWaiting, null);
  }

  @override
  String toString() {
    return '#$hashCode - $_snapState';
  }
}
