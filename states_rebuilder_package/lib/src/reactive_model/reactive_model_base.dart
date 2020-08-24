part of '../reactive_model.dart';

///Remove custom added listener using [ReactiveModel.listenToRM]
typedef Disposer = void Function();
const _deepEquality = DeepCollectionEquality();

abstract class ReactiveModel<T> with StatesRebuilder<T> {
  ReactiveModel._(this.inject) {
    _isGlobal = inject?.isGlobal == true;
    if (!_isGlobal) {
      cleaner(() {
        inject?.cleanInject();
        inject = null;
        _debounceTimer?.cancel();
        _contextSet.clear();
        _listenToRMSet.clear();
      });
    }
  }

  ///Create a ReactiveModel for primitive values, enums and immutable objects
  ///
  ///You can use the shortcut [RM.create]:
  ///```dart
  ///RM.create<T>(T model);
  ///```
  factory ReactiveModel.create(T model) {
    var inject = Inject<T>(() => model);
    var rm = inject.getReactive();
    return rm;
  }

  ///Create a ReactiveModel form stream
  ///
  ///You can use the shortcut [RM.stream]:
  ///```dart
  ///RM.stream<T>(Stream<T> stream);
  ///```
  ///Use [unsubscribe] to dispose of the stream.
  factory ReactiveModel.stream(
    Stream<T> stream, {
    dynamic name,
    T initialValue,
    List<dynamic> filterTags,
    Object Function(T) watch,
  }) {
    final inject = Inject<T>.stream(
      () => stream,
      initialValue: initialValue,
      name: name,
      filterTags: filterTags,
      watch: watch,
    );
    return inject.getReactive();
  }

  ///Create a ReactiveModel form future
  ///
  ///You can use the shortcut [RM.future]:
  ///```dart
  ///RM.future<T>(future<T> future);
  ///```
  factory ReactiveModel.future(
    Future<T> future, {
    dynamic name,
    T initialValue,
    List<dynamic> filterTags,
  }) {
    final inject = Inject<T>.future(
      () => future,
      initialValue: initialValue,
      name: name,
      filterTags: filterTags,
    );
    return inject.getReactive();
  }

  ///Get the singleton [ReactiveModel] instance of a model registered with [Injector].
  ///
  /// ou can use the shortcut [RM.get]:
  ///```dart
  ///RM.get<T>(;
  ///```
  ///
  ///
  factory ReactiveModel({dynamic name, bool silent = false}) {
    return Injector.getAsReactive<T>(name: name, silent: silent);
  }

  bool _isGlobal = false;
  T _state;

  ///The state of the injected model.
  T get state {
    return _state;
  }

  set state(T data) {
    setState((_) => data);
  }

  ///Get the state as future
  ///
  ///You can await for it when the [ConnectionState] is awaiting
  Future<T> get stateAsync {
    return _completer?.future?.catchError((dynamic e) => throw (e)) ??
        Future.value(_state);
  }

  AsyncSnapshot<T> _snapshot;

  ///A representation of the most recent state (instance) of the injected model.
  AsyncSnapshot<T> get snapshot => _snapshot;
  set snapshot(AsyncSnapshot<T> snap) {
    _state = snap.data ?? _state;
    _snapshot = snap;
    inject.reactiveSingleton?._state = _state;
    inject.singleton = _state;
  }

  ///inject associated with this ReactiveModel
  Inject<T> inject;

  ///The latest error object received by the asynchronous computation.
  dynamic get error => snapshot.error;

  ///Current state of connection to the asynchronous computation.
  ///
  ///The initial state is [ConnectionState.none].
  ///
  ///If the an asynchronous event is mutating the state,
  ///the connection state is set to [ConnectionState.waiting] and listeners are notified.
  ///
  ///When the asynchronous task resolves
  ///the connection state is set to [ConnectionState.none] and listeners are notified.
  ///
  ///If the state is mutated by a non synchronous event, the connection state remains [ConnectionState.none].
  ConnectionState get connectionState => snapshot.connectionState;

  ///Where the reactive state is in the initial state
  ///
  ///It is a shortcut of : this.connectionState == ConnectionState.none
  bool get isIdle => connectionState == ConnectionState.none;

  ///Where the reactive state is in the waiting for an asynchronous task to resolve
  ///
  ///It is a shortcut of : this.connectionState == ConnectionState.waiting
  bool get isWaiting => connectionState == ConnectionState.waiting;

  ///Returns whether this state contains a non-null [error] value.
  bool get hasError => snapshot?.hasError;

  ///onError cashed handler
  void Function(BuildContext context, dynamic error) _onErrorHandler;

  ///The global error event handler of this ReactiveModel.
  ///
  ///The  exposed BuildContext if of the last add observer widget.
  ///If not observer is registered yet, the BuildContext is null.
  ///
  ///You can override this error handling to use a specific handling in response to particular events
  ///using the onError callback of [setState] or [setValue].
  void onError(
    void Function(BuildContext context, dynamic error) errorHandler,
  ) {
    _onErrorHandler = errorHandler;
  }

  void Function(T data) _onData;

  ///The global data event handler of this ReactiveModel.
  ///
  void onData(void Function(T data) fn) {
    _onData = fn;
  }

  ///Returns whether this snapshot contains a non-null [AsyncSnapshot.data] value.
  ///Unlike in [AsyncSnapshot], hasData has special meaning here.
  ///It means that the [connectionState] is [ConnectionState.done] with no error.
  bool get hasData =>
      !hasError &&
      (connectionState == ConnectionState.done ||
          connectionState == ConnectionState.active);

  ///true if the stream is done
  bool isStreamDone;

  ///The stream (or Future) subscription of the state
  StreamSubscription<dynamic> subscription;

  void unsubscribe() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  final _listenToRMSet = <void Function(ReactiveModel<T>)>{};

  ///Get the set of this ReactiveModel  custom listeners.
  Set get listenToRMSet {
    return {..._listenToRMSet};
  }

  void _listenToRMCall() => listenToRMSet.forEach((fn) => fn(this));

  ///Listen to a ReactiveModel
  ///
  ///By default,
  ///
  ///It returns a callback for unsubscription
  Disposer listenToRM(
    void Function(ReactiveModel<T> rm) fn, {
    bool listenToOnDataOnly = true,
  }) {
    final listener = (ReactiveModel<T> s) {
      if (listenToOnDataOnly) {
        if (hasData) {
          fn(s);
        }
      } else {
        fn(s);
      }
    };
    _listenToRMSet.add(listener);

    return () {
      _listenToRMSet.remove(listener);
      if (_listenToRMSet.isEmpty && !hasObservers) {
        statesRebuilderCleaner(this);
      }
    };
  }

  ///Exhaustively switch over all the possible statuses of [connectionState].
  ///Used mostly to return [Widget]s.
  R whenConnectionState<R>({
    @required R Function() onIdle,
    @required R Function() onWaiting,
    @required R Function(T state) onData,
    @required R Function(dynamic error) onError,
    bool catchError = true,
  }) {
    if (!_whenConnectionState) {
      _whenConnectionState = catchError;
    }
    if (isIdle) {
      return onIdle?.call();
    }
    if (hasError) {
      return onError?.call(error);
    }
    if (isWaiting) {
      return onWaiting?.call();
    }
    return onData?.call(state);
  }

  bool _whenConnectionState = false;

  dynamic _joinSingletonToNewData;

  dynamic _seed;

  ///Return a new reactive instance.
  ///
  ///The [seed] parameter is used to unsure to always obtain the same new reactive
  ///instance after widget tree reconstruction.
  ///
  ///[seed] is optional and if not provided a default seed is used.
  ReactiveModel<T> asNew([dynamic seed = 'defaultReactiveSeed']) {
    ReactiveModel<T> rm = inject.newReactiveMapFromSeed[seed.toString()];
    if (rm != null) {
      return rm;
    }
    rm = inject.getReactive(true);
    inject.newReactiveMapFromSeed['$seed'] = rm;

    rm
      .._seed = '$seed'
      ..cleaner(() {
        inject?.newReactiveMapFromSeed?.remove('${rm._seed}');
      });

    return rm;
  }

  ///Rest the async connection state to [hasData]
  void resetToIdle([T state]) {
    snapshot =
        AsyncSnapshot.withData(ConnectionState.none, state ?? this.state);
  }

  ///Rest the async connection state to [hasData]
  void resetToHasData([T state]) {
    snapshot =
        AsyncSnapshot.withData(ConnectionState.done, state ?? this.state);
  }

  ///Rest the async connection state to [isWaiting]
  void resetToIsWaiting([T state]) {
    snapshot =
        AsyncSnapshot.withData(ConnectionState.waiting, state ?? this.state);
  }

  ///Rest the async connection state to [hasError]
  void resetToHasError(dynamic e) {
    snapshot = AsyncSnapshot.withError(ConnectionState.done, e);
  }

  ///Holds data to be sent between reactive singleton and reactive new instances.
  dynamic get joinSingletonToNewData => _joinSingletonToNewData;
  Timer _debounceTimer;

  Completer<T> _completer;

  ///Mutate the state of the model and notify observers.
  ///
  ///* Required parameters:
  ///  * The mutation function. It takes the current state fo the model.
  /// The function can have any type of return including Future and Stream.
  ///* Optional parameters:
  ///  * [onData]: The callback to execute when the state is successfully mutated
  /// with data. If defined this [onData] will override any other onData for this particular call.
  ///  * [onError]: The callback to execute when the state has error. If defined
  /// this [onError] will override any other onData for this particular call.
  ///  * [onSetState] and [onRebuildState]: for more general side effects to
  /// execute before and after rebuilding observers.
  ///  * [catchError]: automatically catch errors. It defaults to false, but if
  /// [onError] is defined then it will be true.
  ///  * [skipWaiting]: Wether to notify observers on the waiting state.
  ///  * [debounceDelay]: time in seconds to debounce the execution of [setState].
  ///  * [throttleDelay]: time in seconds to throttle the execution of [setState].
  ///  * [shouldAwait]: Wether to await of any existing async call.
  ///  * [silent]: Whether to silent the error of no observers is found.
  ///  * [watch]: parameters to watch, and only emits notification if they changes.
  ///  * [filterTags]: List of tags to notify.
  ///  * [seeds]: List of seeds to notify.
  ///  * [context]: The [BuildContext] to be used for side effects (Navigation, SnackBar).
  /// If not defined a default [BuildContext] obtained from the last added [StateBuilder] will be used.
  ///  * [joinSingleton]:  used to define how new reactive instances will notify and modify the state of the reactive singleton.
  ///  * [notifyAllReactiveInstances]: Whether to notify all reactive instances created from the same [Inject]
  Future<void> setState(
    Function(T s) fn, {
    bool catchError,
    Object Function(T state) watch,
    List<dynamic> filterTags,
    List<dynamic> seeds,
    bool shouldAwait = false,
    int debounceDelay,
    int throttleDelay,
    bool skipWaiting = false,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context, T model) onData,
    dynamic Function() joinSingletonToNewData,
    bool joinSingleton = false,
    bool notifyAllReactiveInstances = false,
    bool silent = false,
    BuildContext context,
  }) async {
    return _SetState<T>(
      fn,
      rm: this,
      catchError: catchError,
      watch: watch,
      filterTags: filterTags,
      seeds: seeds,
      shouldAwait: shouldAwait,
      debounceDelay: debounceDelay,
      throttleDelay: throttleDelay,
      skipWaiting: skipWaiting,
      onSetState: onSetState,
      onRebuildState: onRebuildState,
      onData: onData,
      onError: onError,
      joinSingletonToNewData: joinSingletonToNewData,
      joinSingleton: joinSingleton,
      notifyAllReactiveInstances: notifyAllReactiveInstances,
      silent: silent,
      context: context,
    ).call();
  }

  ///Get a stream from the state and subscribe to it and
  ///notify observing widget of this [ReactiveModel]
  ///whenever the stream emits data
  ///
  ///The callback exposes the current state and stream subscription.
  ///
  ///If all observer widget are removed from the widget tree,
  ///the stream of local ReactiveModel will be canceled.
  ///
  ///For global ReactiveModel the stream is not canceled unless
  ///the [Injector] widget that creates the stream is disposed.
  ///
  /// See
  ///* [Inject.stream]: Stream injected using [Inject.stream] can be consumed with [RM.get].
  ReactiveModel<S> stream<S>(
    Stream<S> Function(T s, StreamSubscription<dynamic> subscription) stream, {
    S initialValue,
    Object Function(S s) watch,
  }) {
    final s = inject.getReactive().state;

    if (S != dynamic && this is ReactiveModelImp<S>) {
      final rm = Inject<S>.stream(
        () => stream(s, subscription),
        initialValue: initialValue ?? (s as S),
        watch: watch,
      ).getReactive();
      final disposer = rm.listenToRM(
        (r) {
          if (r.hasData) {
            snapshot = AsyncSnapshot<T>.withData(
              ConnectionState.done,
              r.state as T,
            );
          }
        },
      );
      rm.cleaner(disposer);
      return rm;
    }

    return Inject<S>.stream(
      () => stream(s, subscription),
      initialValue: initialValue,
      watch: watch,
    ).getReactive();
  }

  ///Get a Future from the state and subscribe to it and
  ///notify observing widget of this [ReactiveModel]
  ///when the future completes
  ///
  ///The callback exposes the current state and async state as parameter.
  ///
  ///The future is automatically canceled when this [ReactiveModel] is disposed.
  ///
  ///
  ///See:
  ///* [Inject.future].
  ReactiveModel<F> future<F>(
    Future<F> Function(T f, Future<T> stateAsync) future, {
    F initialValue,
    int debounceDelay,
  }) {
    final s = inject.getReactive().state;

    if (F != dynamic && this is ReactiveModelImp<F>) {
      final rm = Inject<F>.future(
        () => future(s, stateAsync),
        initialValue: initialValue ?? (s as F),
      ).getReactive();
      Disposer disposer;
      disposer = rm.listenToRM(
        (r) {
          if (r.hasData) {
            if (r.state is! T) {
              disposer();
              return;
            }
            snapshot = AsyncSnapshot<T>.withData(
              ConnectionState.done,
              r.state as T,
            );
          }
        },
      );
      rm.cleaner(() {
        disposer();
      });
      return rm;
    }

    return Inject<F>.future(
      () => future(s, stateAsync),
      initialValue: initialValue,
    ).getReactive();
  }

  void _joinSingleton(
    bool joinSingleton,
    dynamic Function() joinSingletonToNewData,
  ) {}

  ///Error stackTrace
  StackTrace _stackTrace;

  AsyncSnapshot<T> get _combinedSnapshotState {
    bool isIdle = false;
    bool isWaiting = false;
    bool hasError = false;
    dynamic error;
    T data;
    for (ReactiveModel<T> rm in inject.newReactiveInstanceList) {
      rm.whenConnectionState<bool>(
        onIdle: () {
          data = rm.state;
          return isIdle = true;
        },
        onWaiting: () {
          data = rm.state;
          return isWaiting = true;
        },
        onData: (d) {
          data = d;
          return true;
        },
        onError: (dynamic e) {
          error = e;
          _stackTrace = rm._stackTrace;
          return hasError = true;
        },
      );
    }

    if (isWaiting) {
      return AsyncSnapshot.withData(ConnectionState.waiting, data);
    }
    if (hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, error);
    }
    if (isIdle) {
      return AsyncSnapshot.withData(ConnectionState.none, data);
    }

    return AsyncSnapshot.withData(ConnectionState.done, data);
  }

  void _notifyAll() {
    for (ReactiveModel<T> rm in inject.newReactiveInstanceList) {
      if (rm.hasObservers) {
        rm.rebuildStates();
      }
    }
    final singletonRM = inject.getReactive();
    if (singletonRM.hasObservers) {
      singletonRM.rebuildStates();
    }
  }

  ///Check the type of the state of the [ReactiveModel]
  bool isA<T>();

  // ReactiveModel<T> as<R>() {
  //   assert(state is R);
  //   return this.asNew(R);
  // }

  ///Return the type of the state of the [ReactiveModel]
  String type([bool detailed = true]);

  ///Wether [setState] is called with a defined onError callback.
  bool _setStateHasOnErrorCallback = false;

  /// Notify registered observers to rebuild.
  void notify([List<dynamic> tags]) {
    if (_listenToRMSet.isNotEmpty) {
      _setStateHasOnErrorCallback = onError != null;
      _listenToRMCall();
      _setStateHasOnErrorCallback = false;
    }
    if (hasObservers) {
      rebuildStates(tags);
    }
  }

  /// Refresh the [ReactiveModel] state.
  ///
  /// Reset the ReactiveModel to its initial state by reinvoking its creation function.
  Future<T> refresh({void Function() onInitRefresh});

  final Set<BuildContext> _contextSet = {};

  ///Add a [BuildContext] to the subscription set
  void contextSubscription(BuildContext context) {
    if (_contextSet.add(context)) {
      if (!InjectorState.contextSet.contains(context)) {
        InjectorState.contextSet.add(context);
      }
      Disposer disposer;
      disposer = listenToRM(
        (rm) {
          if (context.findRenderObject()?.attached == true) {
            (context as Element).markNeedsBuild();
          } else {
            _contextSet.remove(context);
            InjectorState.contextSet.add(context);
            disposer();
          }
        },
        listenToOnDataOnly: false,
      );
    }
  }

  String toString() {
    String rm = '${type()} RM'
        ' (#Code $hashCode)';
    int num = 0;
    observers().forEach((key, value) {
      if (key != '_ReactiveModelSubscriber') {
        if (!'$value'.contains('$Injector')) {
          num++;
        }
      }
    });

    return '$rm | ${whenConnectionState<String>(
      onIdle: () => 'isIdle ($state)',
      onWaiting: () => 'isWaiting ($state)',
      onData: (data) => 'hasData : ($data)',
      onError: (dynamic e) => 'hasError : ($e)',
      catchError: false,
    )} | $num observing widgets';
  }

  final Queue<AsyncSnapshot<T>> _undoQueue = ListQueue();
  final Queue<AsyncSnapshot<T>> _redoQueue = ListQueue();
  int _undoStackLength = 0;

  ///Whether the state can be redone.
  bool get canRedoState => _redoQueue.isNotEmpty;

  ///Whether the state can be done
  bool get canUndoState => _undoQueue.isNotEmpty;

  ///Clear undoStack;
  void clearUndoStack() {
    _undoQueue.clear();
    _redoQueue.clear();
  }

  ///redo to the next valid state (isWaiting and hasError are ignored)
  ReactiveModel<T> redoState() {
    if (!canRedoState) {
      return null;
    }
    _undoQueue.add(snapshot);
    final oldSnapShot = _redoQueue.removeLast();
    snapshot = oldSnapShot;
    _state = snapshot.data;
    notify();
    return this;
  }

  ///undo to the last valid state (isWaiting and hasError are ignored)
  ReactiveModel<T> undoState() {
    if (!canUndoState) {
      return null;
    }
    _redoQueue.add(snapshot);
    final oldSnapShot = _undoQueue.removeLast();
    snapshot = oldSnapShot;
    notify();

    return this;
  }

  void _addToUndoQueue() {
    if (_undoStackLength < 1) {
      return;
    }
    _undoQueue.add(snapshot.inState(ConnectionState.done));
    _redoQueue.clear();

    if (_undoQueue.length > _undoStackLength) {
      _undoQueue.removeFirst();
    }
  }

  ///Set the undo/redo stack length
  set undoStackLength(int length) {
    _undoStackLength = length;
  }
}

///
abstract class RM {
  ///Create a [ReactiveModel] from primitives or any object
  static ReactiveModel<T> create<T>(T model) {
    final T _model = model;
    return ReactiveModel<T>.create(_model);
  }

  ///Create a [ReactiveModel] from callback. It's like [create] with the difference
  ///that when [ReactiveModel.refresh] is called, an updated value is obtained.
  ///
  ///Useful with [ReactiveModel.refresh] method.
  static ReactiveModel<T> createFromCallback<T>(T Function() creationFunction) {
    return Inject<T>(creationFunction).getReactive();
  }

  ///Functional injection of a primitive, enum or object.
  ///
  ///* Required parameters:
  ///  * [creationFunction]:  (positional parameter) a callback that
  /// creates an instance of the injected object
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [onError]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  static Injected<T> inject<T>(
    T Function() creationFunction, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
  }) {
    return InjectedImp<T>(
      creationFunction,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      undoStackLength: undoStackLength,
    );
  }

  ///Functional injection of a [Future].
  ///
  ///* Required parameters:
  ///  * [creationFunction]:  (positional parameter) a callback that return a [Future].
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily invoke the Future. Default value is true.
  static Injected<T> injectFuture<T>(
    Future<T> Function() creationFunction, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
    T initialValue,
    bool isLazy = true,
  }) {
    return InjectedFuture<T>(
      creationFunction,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      isLazy: isLazy,
      initialValue: initialValue,
      undoStackLength: undoStackLength,
    );
  }

  ///Functional injection of a [Stream].
  ///
  ///* Required parameters:
  ///  * [creationFunction]:  (positional parameter) a callback that return a [Stream].
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily invoke the Future. Default value is true.
  ///   * [watch]: callback to determine the parameter to watch and do not emit a notification
  /// unless they changed.
  static Injected<T> injectStream<T>(
    Stream<T> Function() creationFunction, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
    T initialValue,
    bool isLazy = true,
    Function(T s) watch,
  }) {
    return InjectedStream<T>(
      creationFunction,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      isLazy: isLazy,
      watch: watch,
      initialValue: initialValue,
      undoStackLength: undoStackLength,
    );
  }

  ///Functional injection of flavors (environments).
  ///
  ///* Required parameters:
  ///  * [impl]:  (positional parameter) Map of the implementations of the interface.
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily execute the impl callback. Default value is true.
  static Injected<T> injectFlavor<T>(
    Map<dynamic, FutureOr<T> Function()> impl, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
    T initialValue,
    bool isLazy = true,
  }) {
    return InjectedInterface<T>(
      impl,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      initialValue: initialValue,
      undoStackLength: undoStackLength,
      isLazy: isLazy,
    );
  }

  ///Functional injection of a computed model.
  ///
  ///The model
  ///
  ///* Required parameters:
  ///  * [impl]:  (positional parameter) Map of the implementations of the interface.
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily execute the compute method. Default value is true.
  static Injected<T> injectComputed<T>({
    T Function(T s) compute,
    List<Injected<dynamic>> asyncDependsOn,
    Stream<T> Function(T s) computeAsync,
    bool autoDisposeWhenNotUsed = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    T initialState,
    bool Function(T s) shouldCompute,
    int undoStackLength,
    bool isLazy = true,
  }) {
    return InjectedComputed<T>(
      compute: compute,
      computeAsync: computeAsync,
      asyncDependsOn: asyncDependsOn,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      initialState: initialState,
      shouldCompute: shouldCompute,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      undoStackLength: undoStackLength,
      isLazy: isLazy,
    );
  }

  ///Clean and dispose all Injected model;
  ///
  ///Although Injected models are auto cleaned, sometimes, we need to
  ///manually clean the Injected models especially in tests.
  static void disposeAll() {
    cleanInjector();
  }

  ///Create a [ReactiveModel] from future.
  static ReactiveModel<T> future<T>(
    Future<T> future, {
    dynamic name,
    T initialValue,
    List<dynamic> filterTags,
  }) {
    return ReactiveModel<T>.future(
      future,
      name: name,
      initialValue: initialValue,
      filterTags: filterTags,
    );
  }

  ///Create a [Stream] from future.
  static ReactiveModel<T> stream<T>(
    Stream<T> stream, {
    dynamic name,
    T initialValue,
    List<dynamic> filterTags,
    Object Function(T) watch,
  }) {
    return ReactiveModel<T>.stream(
      stream,
      name: name,
      initialValue: initialValue,
      filterTags: filterTags,
      watch: watch,
    );
  }

  ///Get the [ReactiveModel] singleton of an injected model.
  static ReactiveModel<T> get<T>({
    dynamic name,
    bool silent,
    BuildContext context,
  }) {
    final rm = Injector.getAsReactive<T>(
      name: name,
      silent: silent,
    );
    if (rm != null && context != null) {
      rm.contextSubscription(context);
    }
    return rm;
  }

  ///get the model that is sending the notification
  static ReactiveModel get notified =>
      StatesRebuilderInternal.getNotifiedModel();

  static BuildContext _context;

  ///Get an active [BuildContext].
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static BuildContext get context {
    if (_context != null) {
      return _context;
    }
    // assert(
    //   InjectorState.contextSet.isNotEmpty,
    //   'No `BuildContext` is found. To get a valid `BuildContext` you have to '
    //   'use at least one of the following widgets under the the `MaterialApp` widget:\n'
    //   '`UseInjected`, `StateBuilder`, `WhenRebuilder`, `WhenRebuilderOR` or `Injector`',
    // );
    if (InjectorState.contextSet.isEmpty) {
      return null;
    }
    if (InjectorState.contextSet.last?.findRenderObject()?.attached != true) {
      InjectorState.contextSet.removeLast();
      return context;
    }

    return context = InjectorState.contextSet.last;
  }

  static set context(BuildContext context) {
    _context = context;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        return _context = null;
      },
    );
  }

  ///get The state for a [Navigator] widget.
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static NavigatorState get navigator {
    try {
      return Navigator.of(context);
    } catch (e) {
      rethrow;
    }
  }

  ///Get the [ScaffoldState]
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static ScaffoldState get scaffold {
    return Scaffold.of(context);
  }

  ///A callBack that exposes an active [BuildContext]
  ///
  ///  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static dynamic show(void Function(BuildContext context) fn) {
    return fn(context);
  }

  ///if true, An informative message is printed in the consol,
  ///showing the model being sending the Notification,
  ///
  ///See : [debugWidgetsRebuild], [debugError] and [debugErrorWithStackTrace]

  static bool debugPrintActiveRM = false;

  ///Consol log information about the widgets that have just rebuild
  ///
  ///See : [debugPrintActiveRM], [debugError] and [debugErrorWithStackTrace]
  static bool debugWidgetsRebuild = false;

  ///If true , print error message
  ///
  ///As states_rebuilder can catches errors, bu using [debugError]
  ///you can console log them.
  ///
  ///Default value is false
  ///
  ///See : [debugPrintActiveRM], [debugWidgetsRebuild] and [debugErrorWithStackTrace]
  static bool debugError = false;

  ///If true (default), print error message and stack trace
  ///
  ///Default value is false
  ///
  ///See : [debugPrintActiveRM], [debugWidgetsRebuild] and [debugError]
  static bool debugErrorWithStackTrace = false;

  static void Function(dynamic e, StackTrace s) errorLog;
}
