part of '../reactive_model.dart';

typedef Disposer = void Function();
const _deepEquality = DeepCollectionEquality();

///ReactiveModel wrapper of model T
///
abstract class ReactiveModel<T> with StatesRebuilder<T> {
  ReactiveModel._(this.inject) {
    _isGlobal = inject?.isGlobal == true;
    if (!_isGlobal) {
      cleaner(() {
        unsubscribe();
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
  ///using the onError callback of [setState].
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

  ///unsubscribe and cancel the current future or stream
  void unsubscribe() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  final _listenToRMSet = <_ListenToRM>{};

  ///Get the set of this ReactiveModel  custom listeners.
  Set<_ListenToRM> get listenToRMSet {
    return <_ListenToRM>{..._listenToRMSet};
  }

  void _listenToRMCall() {
    for (var listenToRM in listenToRMSet) {
      listenToRM();
    }
  }

  ///Listen to a ReactiveModel
  ///
  ///By default,
  ///
  ///It returns a callback for unsubscription
  Disposer listenToRM(
    void Function(ReactiveModel<T> rm) fn, {
    bool listenToOnDataOnly = true,
  }) =>
      _listenToRM(
        fn,
        listenToOnDataOnly: listenToOnDataOnly,
        debugListener: 'User defined',
      );

  //Called internally
  Disposer _listenToRM(
    void Function(ReactiveModel<T> rm) fn, {
    bool listenToOnDataOnly = true,
    //isWidget and isInjectedModel are used in toString override
    bool isWidget = false,
    bool isInjectedModel = false,
    String debugListener,
  }) {
    final listener = _ListenToRM(
      fn,
      rm: this,
      listenToOnDataOnly: listenToOnDataOnly,
      isWidget: isWidget,
      isInjectedModel: isInjectedModel,
      debugListener: debugListener,
    );

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
    subscription?.cancel();
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
    subscription?.cancel();
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

    final rm = Inject<S>.stream(
      () => stream(s, subscription),
      initialValue: initialValue ?? (T == S ? (s as S) : null),
      watch: watch,
    ).getReactive();

    if (rm.isA<Stream<T>>()) {
      final disposer = rm._listenToRM(
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
    }

    return rm;
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

    final rm = Inject<F>.future(
      () => future(s, stateAsync),
      initialValue: initialValue ?? (T == F ? (s as F) : null),
    ).getReactive();

    if (rm.isA<Future<T>>()) {
      Disposer disposer;
      disposer = rm._listenToRM(
        (r) {
          if (r.hasData) {
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
    }
    return rm;
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
  List<bool> _setStateHasOnErrorCallback = List<bool>.filled(
    2,
    false,
    growable: false,
  );

  /// Notify registered observers to rebuild.
  void notify([List<dynamic> tags]) {
    if (_listenToRMSet.isNotEmpty) {
      // _setStateHasOnErrorCallback = onError != null;
      _listenToRMCall();
      // _setStateHasOnErrorCallback = false;
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
      disposer = _listenToRM(
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
        isWidget: true,
      );
    }
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

  @override
  String toString() {
    int numOfWidget = 0;
    int numOfModels = 0;
    String _status;
    String _state;
    observers().forEach((key, value) {
      if (!'$value'.contains('$Injector')) {
        numOfWidget++;
      }
    });
    for (var listenToRM in _listenToRMSet) {
      if (listenToRM.isWidget) {
        numOfWidget++;
      } else if (listenToRM.isInjectedModel) {
        numOfModels++;
      }
    }

    whenConnectionState<void>(
      onIdle: () {
        _status = 'isIdle';
        _state = 'state: ($state)';
      },
      onWaiting: () {
        _status = 'isWaiting';
        _state = 'state: ($state)';
      },
      onData: (data) {
        _status = 'hasData';
        _state = 'state: ($data)';
      },
      onError: (dynamic e) {
        _status = 'hasError';
        _state = 'error: ($e)';
      },
      catchError: false,
    );

    return 'RM${type()}-[$_status] | Observers($numOfWidget widgets, $numOfModels models) | '
        '(#C $hashCode) | $_state';
  }
}

class _ListenToRM<T> {
  final void Function(ReactiveModel<T>) fn;
  final ReactiveModel<T> rm;
  final bool listenToOnDataOnly;
  final bool isWidget;
  final bool isInjectedModel;
  final String debugListener;
  _ListenToRM(
    this.fn, {
    this.rm,
    this.listenToOnDataOnly,
    this.isWidget,
    this.isInjectedModel,
    this.debugListener,
  });
  FutureOr<void> call() {
    if (listenToOnDataOnly) {
      if (rm.hasData) {
        fn(rm);
      }
    } else {
      fn(rm);
    }
  }

  @override
  String toString() =>
      '$debugListener :_ListenToRM<$T>(isWidget: $isWidget, isInjectedModel: $isInjectedModel)';
}
