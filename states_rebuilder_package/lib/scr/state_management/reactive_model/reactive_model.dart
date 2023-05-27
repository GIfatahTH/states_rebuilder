part of '../rm.dart';

/// Observable state interface
abstract class IObservable<T> {
  ///The state is initialized and never mutated.
  bool get isIdle;

  ///The state is waiting for and asynchronous task to end.
  bool get isWaiting;

  ///The state is mutated successfully.
  bool get hasData;

  ///The stats has error
  bool get hasError;

  ///The state is mutated using a stream and the stream is done.
  bool get isDone;

  ///Custom status of the state. Set manually to mark the state with a particular
  ///tag to be used in your logic.
  Object? customStatus;

  ///The error
  dynamic get error;

  ///A snap representation of the state
  SnapState<T> get snapState;
  final _listeners = <ObserveReactiveModel>[];
  final _listenersForSideEffects = <ObserveReactiveModel>[];
  final _dependentListeners = <ObserveReactiveModel>[];
  final _cleaners = <VoidCallback>[];

  /// Whether the state has listeners or not
  bool get hasObservers =>
      _listeners.isNotEmpty || _dependentListeners.isNotEmpty;

  /// Add observer to this state.
  ///
  /// The observer callback is invoked each time the state is notified.
  ///
  /// If [shouldAutoClean] is true, when the observer is removed and if the
  /// state has no other observer, then the state is disposed of.
  ///
  /// If [isSideEffects] is true, then the observer is considered as side
  /// effects and is not used to dispose the state.
  ///
  /// the return callback must be consumed to remove the observer.
  @useResult
  VoidCallback addObserver({
    required ObserveReactiveModel listener,
    bool shouldAutoClean = false,
    bool isSideEffects = true,
  }) {
    if (isSideEffects) {
      _listenersForSideEffects.add(listener);
    } else {
      _listeners.add(listener);
    }
    return () {
      if (isSideEffects) {
        _listenersForSideEffects.remove(listener);
      } else {
        _listeners.remove(listener);
      }

      if (shouldAutoClean && !hasObservers) {
        cleanState();
      }
    };
  }

  @useResult
  VoidCallback _addDependentObserver({
    required ObserveReactiveModel listener,
    required bool shouldAutoClean,
  }) {
    _dependentListeners.add(listener);
    return () {
      _dependentListeners.remove(listener);
      if (shouldAutoClean && !hasObservers) {
        cleanState();
      }
    };
  }

  /// Add a callback to be executed when the state is disposed of.
  ///
  /// the return callback must be consumed to remove the callback from the list.
  @useResult
  VoidCallback addCleaner(VoidCallback listener) {
    _cleaners.add(listener);
    return () {
      _cleaners.remove(listener);
    };
  }

  /// Clean the state
  void cleanState() {
    for (final cleaner in [..._cleaners]) {
      cleaner();
    }
  }

  void _clearObservers() {
    _listeners.clear();
    _listenersForSideEffects.clear();
    _dependentListeners.clear();
    _cleaners.clear();
  }

  /// Notify observers
  void notify();

  /// Dispose the state
  void dispose();
}

///A lightweight version of [Injected]
abstract class ReactiveModel<T> with IObservable<T> {
  ///A lightweight version of [Injected]
  ReactiveModel();

  /// Create a ReactiveModel
  factory ReactiveModel.create({
    required Object? Function() creator,
    T? initialState,
    bool? autoDisposeWhenNotUsed,
  }) {
    return ReactiveModelImp<T>(
      creator: creator,
      initialState: initialState,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed ?? true,
      stateInterceptorGlobal: null,
    );
  }

  /// The current state
  T get state;

  // Whether the state has been initialized or not
  bool get isStateInitialized;

  /// Sync state mutation.
  ///
  /// Use setState for more options
  ///
  /// See: [stateAsync] for async state mutation
  set state(T value);

  /// The current Async state
  Future<T> get stateAsync;

  /// Async state mutation.
  ///
  /// User setState for mor options
  ///
  /// See: [state] for sync state mutation
  set stateAsync(Future<T> value);
  // ignore: cancel_subscriptions
  ///It is not null if the state is waiting for a Future or is subscribed to a
  ///Stream
  StreamSubscription? subscription;
  @override
  dynamic get error => snapState.snapError?.error;
  @override
  dispose() {
    subscription?.cancel();
  }

  ///Mutate the state of the model and notify observers.
  ///
  ///* **Required parameters:**
  ///  * The mutation function. It takes the current state fo the model.
  /// The function can have any type of return including Future and Stream.
  ///* **Optional parameters:**
  ///  * **sideEffects**: Used to handle side effects resulting from calling
  /// this method. It takes [SideEffects] object. Notice that [SideEffects.initState]
  /// and [SideEffects.dispose] are never called here.
  ///  * **shouldOverrideDefaultSideEffects**: used to decide when to override
  /// the default side effects defined in [RM.inject] and other equivalent methods.
  ///  * **debounceDelay**: time in milliseconds to debounce the execution of
  /// [setState].
  ///  * **throttleDelay**: time in milliseconds to throttle the execution of
  /// [setState].
  Future<T?> setState(
    Object? Function(T s) mutator, {
    SideEffects<T>? sideEffects,
    StateInterceptor<T>? stateInterceptor,
    bool Function(SnapState<T> snap)? shouldOverrideDefaultSideEffects,
    int debounceDelay = 0,
    int throttleDelay = 0,
  });

  /// Set the state to the idle status
  void setToIsIdle();

  /// Set the state to the waiting status
  void setToIsWaiting();

  /// Set the state to the data status
  void setToHasData(dynamic data);

  /// Set the state to the error status
  void setToHasError(
    dynamic error, {
    StackTrace? stackTrace,
    VoidCallback? refresher,
  });

  /// Dispose the state if it has no listener
  void disposeIfNotUsed();

  ///Refresh the [Injected] state. Refreshing the state means reinitialize
  ///it and reinvoke its creation function and notify its listeners.
  Future<T?> refresh();

  /// Initialize the state
  FutureOr<T?> initializeState() {
    final data = snapState.data;
    if (isWaiting) {
      return stateAsync;
    }
    return data;
  }

  /// {@template injected.rebuild.onOr}
  ///Listen to the injected Model and rebuild when it emits a notification.
  ///
  /// * Required parameters:
  ///     * [builder] Default callback (called in replacement of any non
  /// defined optional parameters [onIdle], [onWaiting], [onError] and
  /// [onData]).
  /// * Optional parameters:
  ///     * [onIdle] : callback to be executed when injected model is in its
  /// initial state.
  ///     * [onWaiting] : callback to be executed when injected model is in
  /// waiting state.
  ///     * [onError] : callback to be executed when injected model has error.
  ///     * [onData] : callback to be executed when injected model has data.
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * [watch] : callback to be executed before notifying listeners.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  ///    * [onSetState] :For side effects before rebuilding the widget tree.
  ///    * [onAfterBuild] :For side effects after rebuilding the widget tree.
  ///    * [debugPrintWhenRebuild] : Print state transition log.
  /// {@endtemplate}
  R onOrElse<R>({
    R Function()? onIdle,
    R Function()? onWaiting,
    R Function(dynamic error, VoidCallback refreshError)? onError,
    R Function(T data)? onData,
    required R Function(T data) orElse,
  }) {
    ReactiveStatelessWidget.addToObs?.call(this as ReactiveModelImp);
    return snapState.onOrElse<R>(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      orElse: orElse,
    );
  }

  /// {@template injected.rebuild.onAll}
  ///Listen to the injected Model and rebuild when it emits a notification.
  ///
  /// * Required parameters:
  ///     * [onIdle] : callback to be executed when injected model is in its
  /// initial state.
  ///     * [onWaiting] : callback to be executed when injected model is in
  /// waiting state.
  ///     * [onError] : callback to be executed when injected model has error.
  ///     * [onData] : callback to be executed when injected model has data.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///    * [onSetState] :For side effects before rebuilding the widget tree.
  ///    * [onAfterBuild] :For side effects after rebuilding the widget tree.
  ///    * [debugPrintWhenRebuild] : Print state transition log.
  /// {@endtemplate}
  R onAll<R>({
    R Function()? onIdle,
    required R Function()? onWaiting,
    required R Function(dynamic error, VoidCallback refreshError)? onError,
    required R Function(T data) onData,
  }) {
    ReactiveStatelessWidget.addToObs?.call(this as ReactiveModelImp);
    return snapState.onAll<R>(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
    );
  }

  @Deprecated('Use SnapState.status')
  // ignore: public_member_api_docs
  ConnectionState get connectionState {
    if (isWaiting) {
      return ConnectionState.waiting;
    }
    if (hasError || hasData) {
      return ConnectionState.done;
    }
    return ConnectionState.none;
  }

  @Deprecated('Use onAll instead')
  // ignore: public_member_api_docs
  R whenConnectionState<R>({
    R Function()? onIdle,
    required R Function()? onWaiting,
    required R Function(dynamic error)? onError,
    required R Function(T data) onData,
  }) {
    return onAll<R>(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError != null ? (_, __) => onError(_) : null,
      onData: onData,
    );
  }
}
