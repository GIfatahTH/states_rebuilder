part of '../reactive_model.dart';

typedef Disposer = void Function();

abstract class ReactiveModel<T> extends ReactiveModelUndoRedoState<T> {
  ReactiveModel(
    T? nullState,
    T? initialState, [
    void Function(T s)? onInitialized,
  ]) {
    _onInitialized = onInitialized;
    assert('$T' != 'void'); //TODO add assertion log
    assert(T != dynamic);
    assert(T != Object);
    _coreRM = ReactiveModelCore<T>(
      notifyListeners: _notifyListeners,
      persistState: persistState,
      addToUndoQueue: _addToUndoQueue,
    );
    _initialState = initialState;
    _nullState = nullState ?? _getPrimitiveNullState<T>();
    _nullState ??= _initialState;
    _state = _initialState ?? _nullState;

    // RM._printAllInitDispose = true;
  }
  factory ReactiveModel.create(T m) {
    return ReactiveModelImp(creator: (_) => m, nullState: m);
  }

  String? _debugPrintWhenNotifiedPreMessage;

  SnapState<T> get snapState => _coreRM.snapState;
  set snapState(SnapState<T> snap) {
    _coreRM.snapState = snap;
    _state = snap.data;
  }

  ///Get the current state.
  ///
  ///If the state is not initialized before, it will be initialized.
  ///
  ///**Null safety note:**
  ///If you use [RM.injectFuture] or [RM.injectStream] and you try to get the
  ///state while it is waiting and you do not define an initial state, it will
  ///throw an Argument Error. So, make sure to define an initial state, or
  ///to wait until the Future or Stream has data.
  ///
  T get state {
    _initialize();

    if (_nullState == null) {
      final m = _debugPrintWhenNotifiedPreMessage?.isNotEmpty == true
          ? _debugPrintWhenNotifiedPreMessage
          : '$T';
      throw ArgumentError.notNull(
        '\nYou want to get the state of null value!\n'
        'The state of $m has no defined initialState and it '
        '${_snapState.isWaiting ? "is waiting for data" : "has an error"}. '
        'You have to define an initialState '
        'or handle ${_snapState.isWaiting ? "onWaiting" : "onError"} widget\n',
      );
    }
    return _state ??= nullState;
  }

  T get nullState => _coreRM.nullState;

  set state(T s) {
    _previousSnapState = _snapState;
    _initialize();
    _coreRM._setToHasData(s, isSync: true);
  }

  StreamSubscription? get subscription => _subscription;

  Future<T> get stateAsync async {
    _initialize();
    if (_coreRM._completer == null) {
      return _state!;
    }

    await _coreRM._completer?.future;
    return _state!;
  }

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
  ConnectionState get connectionState => _snapState._connectionState;

  ///Where the reactive state is in the initial state
  ///
  ///It is a shortcut of : this.connectionState == ConnectionState.none
  bool get isIdle {
    _initialize();
    return _snapState.isIdle;
  }

  ///Where the reactive state is in the waiting for an asynchronous task to resolve
  ///
  ///It is a shortcut of : this.connectionState == ConnectionState.waiting
  bool get isWaiting {
    _initialize();
    return _snapState.isWaiting;
  }

  ///Returns whether this state contains a non-null [error] value.
  bool get hasError {
    _initialize();
    return _snapState.hasError;
  }

  ///The latest error object received by the asynchronous computation.
  dynamic get error => _snapState.error;
  StackTrace? get stackTrace => _snapState.stackTrace;
  void Function()? get onErrorRefresher => _snapState.onErrorRefresher;

  ///Returns whether this snapshot contains a non-null [AsyncSnapshot.data] value.
  ///Unlike in [AsyncSnapshot], hasData has special meaning here.
  ///It means that the [connectionState] is [ConnectionState.done] with no error.
  bool get hasData {
    _initialize();
    return _snapState.hasData;
  }

  //
  Disposer subscribeToRM(void Function(ReactiveModel<T> rm) fn) {
    _listeners.add(fn);
    return () => () => _listeners.remove(fn);
  }

  bool _whenConnectionState = false;

  ///Exhaustively switch over all the possible statuses of [connectionState].
  ///Used mostly to return [Widget]s.
  R whenConnectionState<R>({
    required R Function() onIdle,
    required R Function() onWaiting,
    required R Function(T state) onData,
    required R Function(dynamic? error) onError,
    bool catchError = true,
  }) {
    if (_whenConnectionState != true) {
      _whenConnectionState = catchError;
    }
    if (_snapState.isIdle) {
      return onIdle.call();
    }
    if (_snapState.hasError) {
      return onError.call(error);
    }
    if (_snapState.isWaiting) {
      return onWaiting.call();
    }
    return onData.call(_state!);
  }

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
  Future<T?> setState(
    dynamic Function(T s)? fn, {
    void Function(T data)? onData,
    void Function(dynamic? error)? onError,
    // bool catchError = false,
    On<void>? onSetState,
    void Function()? onRebuildState,
    int debounceDelay = 0,
    int throttleDelay = 0,
    bool shouldAwait = false,
    bool silent = false,
    bool skipWaiting = false,
    BuildContext? context,
    // Object Function(T? state)? watch,
    // List<dynamic>? filterTags,
  }) async {
    RM.context = context;

    Future<T?> call() async {
      Completer<T>? completer;
      try {
        final dynamic result = fn?.call(state);
        _previousSnapState = _snapState;
        Stream<dynamic>? asyncResult;

        if (result is Future) {
          asyncResult = result.asStream();
        } else if (result is Stream) {
          asyncResult = result;
        }
        if (asyncResult != null) {
          completer = Completer<T>();
          RM.context = context;
          if (!skipWaiting) {
            _coreRM._setToIsWaiting(
              onSetState: onSetState,
              context: context,
              infoMessage: result is Future ? 'Future' : 'Stream',
            );
          }
          isDone = false;
          _handleAsyncSubscription(
            asyncResult,
            onErrorRefresher: () => call(),
            onSetState: onSetState,
            onData: onData,
            onError: onError,
            onRebuildState: onRebuildState,
            context: context,
            onDane: () => completer?.complete(_state),
          );
        } else {
          _coreRM._setToHasData(
            result,
            onData: onData,
            onSetState: onSetState,
            onRebuildState: onRebuildState,
            context: context,
            isSync: true,
          );
        }
      } catch (e, s) {
        _coreRM._setToHasError(
          e,
          s,
          onErrorRefresher: () => call(),
          onSetState: onSetState,
          onError: onError,
          context: context,
        );

        // final shouldCatchError = catchError ||
        //     _whenConnectionState ||
        //     _onHasErrorCallback ||
        //     (onError != null) ||
        //     _coreRM.onError != null;

        // _whenConnectionState = false;
        // _onHasErrorCallback = false;
        // if (!shouldCatchError) {
        //   rethrow;
        // }
      }
      return completer?.future ?? Future.value(_state);
    }

    if (debounceDelay > 0) {
      _subscription?.cancel();
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        Duration(milliseconds: debounceDelay),
        () {
          call();
          _debounceTimer = null;
        },
      );
      return Future.value(_state);
    } else if (throttleDelay > 0) {
      if (_debounceTimer != null) {
        return Future.value(_state);
      }
      _debounceTimer = Timer(
        Duration(milliseconds: throttleDelay),
        () {
          _debounceTimer = null;
        },
      );
    }

    if (shouldAwait) {
      return stateAsync.then(
        (_) => call(),
      );
    }

    return call();
  }

  Future<F?> Function() future<F>(Future<F> Function(T s) future) {
    return () async {
      late F data;
      await future(state).then((d) {
        if (d is T) {
          snapState = snapState.copyToHasData(d);
          _coreRM.on?._call(snapState);
          _coreRM.onData?.call(state);
        }
        data = d;
      }).catchError((e, StackTrace s) {
        snapState = snapState._copyToHasError(
          e,
          () => this.future(future),
          stackTrace: s,
        );
        _coreRM.on?._call(snapState);
        _coreRM.onError?.call(e, s);
        throw e;
      });
      return data;
    };
  }

  ///used to prevent rebuild of global inherited,
  ///while refreshing. See in [Injected._addToInheritedInjects]
  bool _isRefreshing = false;

  ///Refresh the [Injected] state. Refreshing the state means reinitialize
  ///it and reinvoke its creation function and notify its listeners.
  ///
  ///If the state is persisted using [PersistState], the state is deleted from
  ///the store and the new recalculated state is stored instead.
  ///
  ///If the Injected model has [Injected.inherited] injected models, they will
  ///be refreshed also.
  Future<T> refresh([bool toHasData = false]) async {
    if (_inheritedInjects.isNotEmpty) {
      _isRefreshing = true;
      //while refreshing from global do change state
      //and do not rebuild
      for (var inherited in _inheritedInjects) {
        inherited.refresh(toHasData);
      }
      _isRefreshing = false;
      //This is the global for inherited. Do not refresh
      return stateAsync;
    }
    final beforeRefreshState = _snapState;
    _isInitialized = false;
    _coreRM._completeCompleter(_state);

    if (toHasData) {
      _initialConnectionState = ConnectionState.done;
    } else {
      _initialConnectionState = ConnectionState.none;
      _state = _nullState;
    }

    _snapState = _snapState._copyToIsIdle(
      infoMessage: refreshMessage + (beforeRefreshState._infoMessage ?? ''),
    );

    _initialize();
    if (_toRefresh.isNotEmpty) {
      _refreshListeners();
    }
    if (!_isAsyncReactiveModel && _snapState != beforeRefreshState) {
      if (toHasData) {
        _coreRM._callOnData();
      }
      _notifyListeners();
    }
    try {
      return await stateAsync;
    } catch (e) {
      return state;
    }
  }

  List<void Function()> _toRefresh = [];
  Disposer addToRefresh(void Function() fn) {
    _toRefresh.add(fn);
    return () => () => _toRefresh.remove(fn);
  }

  void _refreshListeners() => _toRefresh.forEach((e) => e());

  void persistState() {}

  void deletePersistState() {}
  void deleteAllPersistState() {}

  ///If the state is bool, toggle it and notify listeners
  ///
  ///This is a shortcut of:
  ///
  ///If the state is not bool, it will throw an assertion error.
  void toggle() {
    assert(T == bool);
    _coreRM._setToHasData(!(state as bool), isSync: true);
  }

  ///Notify listeners to rebuild without changing the state
  void notify() {
    _notifyListeners();
  }

  R stateAs<R>() {
    return state as R;
  }

  String type() => '$T';

  @override
  int get hashCode => _cachedHash;
  int _cachedHash = _nextHashCode = (_nextHashCode + 1) % 0xffffff;
  static int _nextHashCode = 1;

  @override
  bool operator ==(o) => o.hashCode == hashCode;
}
