part of '../rm.dart';

///A Wrapper class that encloses the state of the model we want to Inject. The
///state can be mutable or immutable.
///
///Injected model can be instantiated globally or as a member of classes. They
///can be instantiated inside the build method without losing the state after
///rebuilds.
///
///
///* **Injected instantiation:**
///To instantiate an Injected model, you use [RM.inject], [RM.injectFuture],
///[RM.injectStream] or [RM.injectFlavor].
///
///
///* **Injected lifecycle:**
///The state wrapped by the Injected model has a lifecycle. It is created when
///first used and destroyed when no longer used even if it is declared globally.
///Between the creation and the destruction of the state, it can be listened to
///and mutated to notify its registered listeners.
///
///
///* **Injected state and null safety:**
///The state of an injected model is null safe, that is it can not be null. For
///this reason the initial state will be inferred by the library, and in case
///it is not, it must be defined explicitly. The initial state of primitives is
///inferred as follows: (int: 0, double, 0.0, String:'', and bool: false). For
///other non-primitive objects the initial state will be the first created
///instance.
///
///
///* **Listening to an Injected:**
///To listen to an Injected model you can use one of the following options:
///[ReactiveModelBuilder.listen], [ReactiveModelBuilder.futureBuilder],
///[ReactiveModelBuilder.streamBuilder], [ReactiveModelBuilder.rebuilder],
///[ReactiveModelBuilder.whenRebuilder], and
///[ReactiveModelBuilder.whenRebuilderOr].
///
///
///* **Injected state mutation:**
///To mutate the state and notify listeners, you use [ReactiveModel.state]
///setter, [ReactiveModel.setState], or[ ReactiveModel.toggle] if the state is
///bool.
///You can also notify listeners without changing the state using
///[ReactiveModel.notify]. You can also refresh the state to its initial state
///and reinvoke the creation function then notify listeners using
///[ReactiveModel.refresh].
///
///
///* **Injected state cleaning:**
///When the state is disposed of, its list of listeners is cleared, and if the
///state is waiting for a Future or subscribed to a Stream, it will cancel them
///to free resources.
///
///
///* **State persistence:**
///Injected state can be persisted using [PersistState]. By default the state
///is persisted each time the state is mutated. You can set it to persist
///manually or when the state is disposed. You can also throttle state
///persistence for the time you want.
///
///
///* **Undo redo state mutation:**
///You can undo or redo state mutation by defining the `undoStackLength`
///parameter of [RM.inject] [RM.injectFuture], [RM.injectStream] or
///[RM.injectFlavor]. After state mutation you can redo it using
///[ReactiveModelUndoRedoState.undoState] and redo it using
///[ReactiveModelUndoRedoState.redoState].
///
///
///* **Injected model dependence**
///Injected models can depend on other Injected models and recalculate its
///state and notify its listeners whenever any of its of the Inject model that
///it depends on emits a notification.
///
///
///* **Injected mock for testing:**
///Injected model can be easily mocked to fake implementation in tests using :
///[Injected.injectMock], [Injected.injectFutureMock],
///or [Injected.injectStreamMock].
///
///
abstract class Injected<T> {
  late ReactiveModelBase<T> _reactiveModelState;

  ///Get the current state.
  ///
  ///If the state is not initialized before, it will be initialized.
  ///
  ///**Null safety note:**
  ///If the state is non nullable, and you use [RM.injectFuture] or
  ///[RM.injectStream] and you try to get the state while it is waiting and you
  ///do not define an initial state, it will throw an Argument Error. So,
  ///make sure to define an initial state, or to wait until the Future or
  ///Stream has data.
  T get state {
    final s = _reactiveModelState.snapState.data;
    if (!snapState._isNullable && s == null) {
      if (this is InjectedImp) {
        final inj = this as InjectedImp;
        final m = inj.debugPrintWhenNotifiedPreMessage?.isNotEmpty == true
            ? inj.debugPrintWhenNotifiedPreMessage
            : '$T';
        throw ArgumentError.notNull(
          '\nNON-NULLABLE STATE IS NULL!\n'
          'The state of $m has no defined initialState and it '
          '${snapState.isWaiting ? "is waiting for data" : "has an error"}. '
          'You have to define an initialState '
          'or handle ${snapState.isWaiting ? "onWaiting" : "onError"} widget\n',
        );
      }
      throw ArgumentError();
    }
    return s as T;
  }

  T? get _nullableState => _reactiveModelState._snapState.data;

  set state(T s) {
    setState((_) => s);
  }

  ///A snap representation of the state
  SnapState<T> get snapState => _reactiveModelState._snapState;
  set snapState(SnapState<T> snap) => _reactiveModelState._snapState = snap;

  ///It is a future of the state. The future is active if the state is on the
  ///isWaiting status.
  Future<T> get stateAsync async {
    final snap = await _reactiveModelState.snapStateAsync;
    // assert(snap.data != null);
    return snap.data as T;
  }

  ///The state is initialized and never mutated.
  bool get isIdle => _reactiveModelState._snapState.isIdle;

  ///The state is waiting for and asynchronous task to end.
  bool get isWaiting => _reactiveModelState._snapState.isWaiting;

  ///The state is mutated successfully.
  bool get hasData => _reactiveModelState._snapState.hasData;

  ///The state is mutated using a stream and the stream is done.
  bool get isDone => _reactiveModelState._snapState.isDone;

  ///The stats has error
  bool get hasError => _reactiveModelState._snapState.hasError;

  ///The state is Active
  bool get isActive => _reactiveModelState._snapState.isActive;

  ///The error
  dynamic get error => _reactiveModelState._snapState.error;

  ///It is not null if the state is waiting for a Future or is subscribed to a
  ///Stream
  StreamSubscription? get subscription => _reactiveModelState.subscription;

  ///Custom status of the state. Set manually to mark the state with a particular
  ///tag to be used in your logic.
  Object? customStatus;

  ///Refresh the [Injected] state. Refreshing the state means reinitialize
  ///it and reinvoke its creation function and notify its listeners.
  ///
  ///If the state is persisted using [PersistState], the state is deleted from
  ///the store and the new recalculated state is stored instead.
  ///
  ///If the Injected model has [Injected.inherited] injected models, they will
  ///be refreshed also.
  Future<T?> refresh() async {
    _reactiveModelState._refresh();
    try {
      return await stateAsync;
    } catch (_) {
      return state;
    }
  }

  SnapState<T>? _middleSnap(
    SnapState<T> s, {
    On<void>? onSetState,
    void Function(T)? onData,
    void Function(dynamic)? onError,
  });
  Timer? _debounceTimer;
  String? debugMessage;

  ///Mutate the state of the model and notify observers.
  ///
  ///* **Required parameters:**
  ///  * The mutation function. It takes the current state fo the model.
  /// The function can have any type of return including Future and Stream.
  ///* **Optional parameters:**
  ///  * **onData**: The callback to execute when the state is successfully
  /// mutated with data. If defined this [onData] will override any other
  /// onData for this particular call.
  ///  * **onError**: The callback to execute when the state has error. If
  /// defined this [onError] will override any other onData for this particular
  /// call.
  ///  * **catchError**: automatically catch errors. It defaults to false, but
  /// if [onError] is defined then it will be true.
  ///  * **onSetState** and **onRebuildState**: for more general side effects to
  /// execute before and after rebuilding observers.
  ///  * **debounceDelay**: time in milliseconds to debounce the execution of
  /// [setState].
  ///  * **throttleDelay**: time in milliseconds to throttle the execution of
  /// [setState].
  ///  * **skipWaiting**: Wether to notify observers on the waiting state.
  ///  * **shouldAwait**: Wether to await of any existing async call.
  ///  * **silent**: Whether to silent the error of no observers is found.
  ///  * **context**: The [BuildContext] to be used for side effects
  /// (Navigation, SnackBar). If not defined a default [BuildContext]
  /// obtained from the last added [StateBuilder] will be used.
  Future<T> setState(
    dynamic Function(T s) fn, {
    void Function(T data)? onData,
    void Function(dynamic? error)? onError,
    On<void>? onSetState,
    void Function()? onRebuildState,
    int debounceDelay = 0,
    int throttleDelay = 0,
    bool shouldAwait = false,
    // bool silent = false,
    bool skipWaiting = false,
    BuildContext? context,
  }) async {
    final debugMessage = this.debugMessage;
    this.debugMessage = null;
    final call = _reactiveModelState.setStateFn(
      (s) {
        // assert(s != null);

        return fn(s as T);
      },
      middleState: (s) {
        final snap = _middleSnap(
          s,
          onError: onError,
          onData: onData,
          onSetState: onSetState,
        );
        if (skipWaiting && snap != null && snap.isWaiting) {
          return null;
        }
        if (onRebuildState != null && snap != null && snap.hasData) {
          WidgetsBinding.instance?.addPostFrameCallback(
            (_) => onRebuildState(),
          );
        }
        return snap;
      },
      onDone: (s) {
        return s;
      },
      debugMessage: debugMessage,
    );
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
      return Future.value(state);
    } else if (throttleDelay > 0) {
      if (_debounceTimer != null) {
        return Future.value(state);
      }
      _debounceTimer = Timer(
        Duration(milliseconds: throttleDelay),
        () {
          _debounceTimer = null;
        },
      );
    }

    if (shouldAwait && isWaiting) {
      return stateAsync.then(
        (_) async {
          final snap = await call();
          return snap.data!;
        },
      );
    }

    final snap = await call();
    return snap.data as T;
  }

  ///If the state is bool, toggle it and notify listeners
  ///
  ///This is a shortcut of:
  ///
  ///If the state is not bool, it will throw an assertion error.
  void toggle() {
    assert(T == bool);
    final snap =
        _reactiveModelState.snapState._copyToHasData(!(state as bool) as T);
    _reactiveModelState._setSnapStateAndRebuild = snap;
  }

  ///Notify observers
  void notify() {
    _reactiveModelState.listeners.rebuildState(snapState);
  }

  Future<F?> Function() future<F>(Future<F> Function(T s) future) {
    return () async {
      late F data;
      await future(state).then((d) {
        if (d is T) {
          snapState = snapState.copyToHasData(d);
        }
        data = d;
      }).catchError(
        (e, StackTrace s) {
          snapState = snapState._copyToHasError(
            e,
            () => this.future(future),
            stackTrace: s,
          );

          throw e;
        },
      );
      return data;
    };
  }

  ///IF the state is in the hasError status, The last callback that causes the
  ///error can be reinvoked.
  void onErrorRefresher() {
    _reactiveModelState._snapState.onErrorRefresher?.call();
  }

  ///Subscribe to the state
  VoidCallback subscribeToRM(void Function(SnapState<T>? snap) fn) {
    _reactiveModelState.listeners._sideEffectListeners.add(fn);
    return () =>
        () => _reactiveModelState.listeners._sideEffectListeners.remove(fn);
  }

  ///Whether the state has observers
  bool get hasObservers => _reactiveModelState.listeners._listeners.isNotEmpty;

  ///Dispose the state.
  void dispose() {
    _reactiveModelState.dispose();
  }

  ///Inject a fake implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake creation function
  void injectMock(T Function() fakeCreator);

  ///Inject a fake future implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake future
  void injectFutureMock(Future<T> Function() fakeCreator);

  ///Inject a fake stream implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake stream
  void injectStreamMock(Stream<T> Function() fakeCreator);

  ///Undo to the last valid state (isWaiting and hasError are ignored)
  void undoState();

  ///Redo to the next valid state (isWaiting and hasError are ignored)
  void redoState();

  ///Clear undoStack;
  void clearUndoStack();

  ///Whether the state can be redone.
  bool get canRedoState;

  ///Whether the state can be done
  bool get canUndoState;

  ///Persist the state
  void persistState();

  ///Delete the state form the persistence store
  void deletePersistState();

  ///
  Future<Injected<T>> catchError(
    void Function(dynamic error, StackTrace s) onError,
  ) async {
    try {
      await _reactiveModelState._endStreamCompleter?.future;
      if (hasError) {
        onError(error, snapState.stackTrace!);
      }
    } catch (e, s) {
      onError(e, s);
    }
    return this;
  }

  ///{@template inherited}
  ///Provide the injected model using an [InheritedWidget] that wraps its state.
  ///
  ///By default the [InheritedWidget] holds the state of the injected model,
  ///but this can be overridden using the [stateOverride] parameter.
  ///
  ///Child widgets can obtain the wrapped state using `.of(context)` or
  ///`.call(context)` methods.
  ///
  ///* `myModel.of(context)` looks up in the widget tree to find the state of
  ///`myModel` and register  the `BuildContext` to rebuild when `myModel` is
  ///notified.
  ///
  ///* `myModel.call(context) or myModel(context)` looks up in the widget tree
  ///to find the injected model `myModel` without registering the `BuildContext`.
  ///
  ///ex:
  ///
  ///```dart
  ///final counter1 = RM.inject<int>(()=> 0);
  ///final counter2 = RM.inject<int>(()=> 0);
  ///
  ///class MyApp extends StatelessWidget{
  ///
  /// Widget build(context){
  ///  counter1.inherited(
  ///   builder: (context):{
  ///     return counter2.inherited(
  ///       builder: (context){
  ///         //Getting the counters state using `of` will
  ///         //resister this BuildContext
  ///         final int counter1State = counter1.of(context);
  ///         //Although both counters are of the same type we get
  ///         //the right state
  ///         final int counter2State = counter2.of(context);
  ///
  ///
  ///         //Getting the counters using the `call` method will
  ///         //not register this BuildContext
  ///          final Injected<int> counter1 = counter1(context);
  ///          final Injected<int> counter2 = counter2(context);
  ///       }
  ///     )
  ///   }
  ///  )
  /// }
  ///}
  ///```
  ///
  /// * **Required parameters**:
  ///     * **builder**: Callback to be rendered. It exposed the [BuildContext].
  /// * Optional parameters:
  ///     * **stateOverride**: CallBack to override the exposed state.
  ///     * **connectWithGlobal**: If state is overridden, whether to mutate the
  /// global
  ///     * **debugPrintWhenNotifiedPreMessage**: if not null, print an
  /// informative message when this model is notified in the debug mode.The
  /// entered message will pré-append the debug message. Useful if the type
  /// of the injected
  /// model is primitive to distinguish
  /// {@endtemplate}
  Widget inherited({
    required Widget Function(BuildContext) builder,
    Key? key,
    FutureOr<T> Function()? stateOverride,
    bool connectWithGlobal = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  });

  ///Provide the Injected model to another widget tree branch.
  Widget reInherited({
    Key? key,
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    // String? debugPrintWhenNotifiedPreMessage,
    // String Function(T?)? toDebugString,
  });

  ///Obtain the state from the nearest [InheritedWidget] inserted using [inherited].
  ///
  ///The [BuildContext] used, will be registered so that when this Injected model emits
  ///a notification, the [Element] related the the [BuildContext] will rebuild.
  ///
  ///If you want to obtain the state without registering use the [call] method.
  ///
  ///```dart
  ///myModel.of(context); // Will return the state and register the BuildContext.
  ///myModel(context); // Will return the Injected model and do not register the BuildContext.
  ///```
  ///
  T? of(BuildContext context, {bool defaultToGlobal = false}) {
    final _inheritedInjected =
        context.dependOnInheritedWidgetOfExactType<_InheritedInjected<T>>();

    if (_inheritedInjected != null) {
      if (_inheritedInjected.globalInjected == this) {
        return _inheritedInjected.injected.state;
      } else {
        return of(
          _inheritedInjected.context,
          defaultToGlobal: defaultToGlobal,
        );
      }
    }
    if (defaultToGlobal) {
      return state;
    }
    return null;
  }

  ///Obtain the Injected model from the nearest [InheritedWidget] inserted using [inherited].
  ///
  ///The [BuildContext] used, will not be registered.
  ///
  ///If you want to obtain the state and  register it use the [of] method.
  ///
  ///```dart
  ///myModel.of(context); // Will return the state and register the BuildContext.
  ///myModel(context); // Will return the Injected model and do not register the BuildContext.
  ///```
  ///
  Injected<T>? call(BuildContext context, {bool defaultToGlobal = false}) {
    final _inheritedInjected = context
        .getElementForInheritedWidgetOfExactType<_InheritedInjected<T>>()
        ?.widget as _InheritedInjected<T>?;

    if (_inheritedInjected != null) {
      if (_inheritedInjected.globalInjected == this) {
        return _inheritedInjected.injected;
      } else {
        return call(
          _inheritedInjected.context,
          defaultToGlobal: defaultToGlobal,
        );
      }
    }
    if (defaultToGlobal) {
      return this;
    }
    return null;
  }
}

extension InjectedX1<T> on Injected<T> {
  ///Add observer for rebuild
  VoidCallback observeForRebuild(void Function(Injected<T>? rm) fn) {
    return _reactiveModelState.listeners.addListener((_) => fn(this));
  }

  ///Add callback to be executed when model is disposed
  void addCleaner(VoidCallback fn) {
    _reactiveModelState.listeners.addCleaner(fn);
  }
}

class NullWidget extends Widget {
  final List<Injected> injects;
  NullWidget({
    required this.injects,
  });
  @override
  Element createElement() {
    throw UnimplementedError();
  }
}
