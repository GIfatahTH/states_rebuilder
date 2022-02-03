part of '../rm.dart';

abstract class IObservable {
  final _listeners = <ObserveReactiveModel>[];
  final _dependentListeners = <ObserveReactiveModel>[];
  final _cleaners = <VoidCallback>[];
  bool get hasObservers =>
      _listeners.isNotEmpty || _dependentListeners.isNotEmpty;

  VoidCallback addObserver({
    required ObserveReactiveModel listener,
    required bool shouldAutoClean,
  }) {
    _listeners.add(listener);
    return () {
      _listeners.remove(listener);
      if (shouldAutoClean && !hasObservers) {
        cleanState();
      }
    };
  }

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

  VoidCallback addCleaner(VoidCallback listener) {
    _cleaners.add(listener);
    return () {
      _cleaners.remove(listener);
    };
  }

  void cleanState() {
    for (final cleaner in [..._cleaners]) {
      cleaner();
    }
  }

  void _clearObservers() {
    _listeners.clear();
    _dependentListeners.clear();
    _cleaners.clear();
  }
}

abstract class ReactiveModel<T> with IObservable {
  ReactiveModel();
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
  T get state;
  set state(T value);
  SnapState<T> get snapState;
  Future<T> get stateAsync;
  set stateAsync(Future<T> value);
  bool get isIdle;
  bool get isWaiting;
  bool get hasData;
  bool get hasError;
  bool get isDone;
  Object? customStatus;
  dynamic get error => snapState.snapError?.error;
  // ignore: cancel_subscriptions
  StreamSubscription? subscription;

  Future<T?> setState(
    Object? Function(T s) mutator, {
    SideEffects<T>? sideEffects,
    StateInterceptor<T>? stateInterceptor,
    bool Function(SnapState<T> snap)? shouldOverrideDefaultSideEffects,
    int debounceDelay = 0,
    int throttleDelay = 0,
  });

  void setToIsIdle();
  void setToIsWaiting();
  void setToHasData(dynamic data);
  void setToHasError(
    dynamic error, {
    StackTrace? stackTrace,
    VoidCallback? refresher,
  });
  void notify();
  void disposeIfNotUsed();
  void dispose();

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
}
