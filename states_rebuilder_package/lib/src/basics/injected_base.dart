part of '../rm.dart';

class _Rebuild<T> {
  final InjectedBase<T> _injected;
  _Rebuild(this._injected);

  Widget call(
    Widget Function() builder, {
    On<void>? onSetState,
    On<void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    bool Function(SnapState<T>? snapState)? shouldRebuild,
    Object? Function()? watch,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return On(builder).listenTo(
      _injected,
      onSetState: onSetState,
      onAfterBuild: onAfterBuild,
      initState: initState,
      dispose: dispose,
      shouldRebuild: shouldRebuild,
      watch: watch,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }

  Widget onData(
    Widget Function() builder, {
    On<void>? onSetState,
    On<void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    bool Function(SnapState<T>? snapState)? shouldRebuild,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return On.data(builder).listenTo(
      _injected,
      onSetState: onSetState,
      onAfterBuild: onAfterBuild,
      initState: initState,
      dispose: dispose,
      shouldRebuild: shouldRebuild,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }

  Widget onAll({
    required Widget Function() onIdle,
    required Widget Function() onWaiting,
    required Widget Function(dynamic, void Function()) onError,
    required Widget Function() onData,
    On<void>? onSetState,
    On<void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    bool Function(SnapState<T>? snapState)? shouldRebuild,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return On.all(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
    ).listenTo(
      _injected,
      onSetState: onSetState,
      onAfterBuild: onAfterBuild,
      initState: initState,
      dispose: dispose,
      shouldRebuild: shouldRebuild,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }

  Widget onOr({
    Widget Function()? onIdle,
    Widget Function()? onWaiting,
    Widget Function(dynamic, void Function())? onError,
    Widget Function()? onData,
    required Widget Function() or,
    On<void>? onSetState,
    On<void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    // void Function(_StateBuilder)? didUpdateWidget,
    bool Function(SnapState<T>? snapState)? shouldRebuild,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return On.or(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
      or: or,
    ).listenTo(
      _injected,
      onSetState: onSetState,
      onAfterBuild: onAfterBuild,
      initState: initState,
      dispose: dispose,
      shouldRebuild: shouldRebuild,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }

  Widget onFuture<F>({
    required Future<F> Function() future,
    required Widget Function() onWaiting,
    required Widget Function(dynamic, void Function()) onError,
    required Widget Function(F, void Function()) onData,
    On<void>? onSetState,
    On<void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    // void Function(_StateBuilder)? didUpdateWidget,
    bool Function(SnapState<T>? snapState)? shouldRebuild,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return On.future<F>(
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
    ).future(
      future,
      onSetState: onSetState,
      initState: initState,
      dispose: dispose,
      key: key,
    );
  }

  Widget onAuth({
    Widget Function()? onInitialWaiting,
    Widget Function()? onWaiting,
    required Widget Function() onUnsigned,
    required Widget Function() onSigned,
    bool useRouteNavigation = false,
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return On.auth(
      onInitialWaiting: onInitialWaiting,
      onWaiting: onWaiting,
      onUnsigned: onUnsigned,
      onSigned: onSigned,
    ).listenTo(
      _injected as InjectedAuth,
      useRouteNavigation: useRouteNavigation,
      onSetState: onSetState,
      dispose: dispose,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }

  Widget onCRUD({
    required Widget Function()? onWaiting,
    required Widget Function(dynamic err, void Function() refresh)? onError,
    required Widget Function(dynamic data) onResult,
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return On.crud(
      onWaiting: onWaiting,
      onError: onError,
      onResult: onResult,
    ).listenTo(
      _injected as InjectedCRUD,
      onSetState: onSetState,
      dispose: dispose,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }
}

abstract class InjectedBase<T> extends InjectedBaseState<T> {
  set state(T s) {
    setState((_) => s);
  }

  ///It is not null if the state is waiting for a Future or is subscribed to a
  ///Stream
  StreamSubscription? get subscription => _reactiveModelState.subscription;
  bool get autoDisposeWhenNotUsed => _reactiveModelState.autoDisposeWhenNotUsed;

  ///Custom status of the state. Set manually to mark the state with a particular
  ///tag to be used in your logic.
  Object? customStatus;

  ///If the state is bool, toggle it and notify listeners
  ///
  ///This is a shortcut of:
  ///
  ///If the state is not bool, it will throw an assertion error.
  void toggle() {
    assert(T == bool);
    final snap =
        _reactiveModelState.snapState._copyToHasData(!(state as bool) as T);
    _reactiveModelState.setSnapStateAndRebuild = snap;
  }

  ///Subscribe to the state
  VoidCallback subscribeToRM(void Function(SnapState<T>? snap) fn) {
    _reactiveModelState.listeners._sideEffectListeners.add(fn);
    return () =>
        () => _reactiveModelState.listeners._sideEffectListeners.remove(fn);
  }

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
    void Function(dynamic error)? onError,
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
          return snap.data as T;
        },
      );
    }

    final snap = await call();
    return snap.data as T;
  }

  ///IF the state is in the hasError status, The last callback that causes the
  ///error can be reinvoked.
  void onErrorRefresher() {
    _reactiveModelState._snapState.onErrorRefresher?.call();
  }

  ///
  Future<InjectedBase<T>> catchError(
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

  @override
  String toString() {
    return '$hashCode: $snapState';
  }
}
