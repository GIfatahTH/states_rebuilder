part of '../rm.dart';

abstract class InjectedBase<T> extends InjectedBaseState<T> {
  @override
  set state(T s) {
    setState((_) => s);
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
}
