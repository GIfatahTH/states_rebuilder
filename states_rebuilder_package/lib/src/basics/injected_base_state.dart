part of '../rm.dart';

abstract class InjectedBaseState<T> {
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

  set state(T s) {
    snapState = snapState.copyToHasData(s);
    notify();
  }

  T? get _nullableState => _reactiveModelState._snapState.data;

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
    _reactiveModelState._setSnapStateAndRebuild = snap;
  }

  ///Notify observers
  void notify() {
    _reactiveModelState.listeners.rebuildState(snapState);
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
}

class InjectedBaseBaseImp<T> extends InjectedBaseState<T> {
  InjectedBaseBaseImp({
    required T Function() creator,
    bool autoDisposeWhenNotUsed = true,
  }) {
    _reactiveModelState = ReactiveModelBase<T>(
      creator: creator,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      initializer: () {
        if (_reactiveModelState._isInitialized) {
          return;
        }
        _reactiveModelState
          .._isInitialized = true
          .._isDisposed = false
          .._snapState = SnapState._nothing(
            _reactiveModelState._initialState,
            kInitMessage,
            _reactiveModelState.debugPrintWhenNotifiedPreMessage,
          );

        _reactiveModelState._setInitialStateCreator(
          middleCreator: (crt) {
            return crt();
          },
          middleState: (snap) {
            snap = snap._copyToIsIdle();
            _reactiveModelState._snapState = snap;
            return null; //Return null so do not rebuild
          },
          onDone: (snap) {
            return snap;
          },
        );
        _reactiveModelState._initialStateCreator!();
      },
    );
    _reactiveModelState.initializer();
  }
  int get observerLength => _reactiveModelState.listeners.observerLength;

  ReactiveModelBase<T> get reactiveModelState => _reactiveModelState;
}

extension InjectedBaseX<T> on InjectedBaseState<T> {
  void setReactiveModelState(ReactiveModelBase<T> rm) {
    _reactiveModelState = rm;
  }
}
