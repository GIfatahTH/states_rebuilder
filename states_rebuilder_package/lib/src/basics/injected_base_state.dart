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
      var m = '$T';
      if (this is InjectedImp) {
        final inj = this as InjectedImp;
        if (inj.debugPrintWhenNotifiedPreMessage?.isNotEmpty == true) {
          m = inj.debugPrintWhenNotifiedPreMessage!;
        }
      }
      throw ArgumentError.notNull(
        '\n[$m] is NON-NULLABLE STATE!\n'
        'The non-nullable state [$m] has null value which is not accepted\n'
        'To fix:\n'
        '1- Define an initial value to injected state.\n'
        '2- Handle onWaiting or onError state.\n'
        '3- Make the state nullable. ($T?).\n',
      );
    }
    return s as T;
  }

  T? get _nullableState => _reactiveModelState._snapState.data;

  ///A snap representation of the state
  SnapState<T> get snapState => _reactiveModelState._snapState;
  SnapState<T> get oldSnapState => _reactiveModelState._oldSnapState;
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

  ///Whether the state has observers
  bool get hasObservers => _reactiveModelState.listeners._listeners.isNotEmpty;

  ///Notify observers
  void notify() {
    _reactiveModelState.listeners.rebuildState(snapState);
  }

  ///Dispose the state.
  void dispose() {
    _reactiveModelState.dispose();
  }
}

extension InjectedBaseX<T> on InjectedBaseState<T> {
  // void setReactiveModelState(ReactiveModelBase<T> rm) {
  //   _reactiveModelState = rm;
  // }

  ///Subscribe to the state
  VoidCallback subscribeToRM(void Function(SnapState<T>? snap) fn) {
    _reactiveModelState.listeners._sideEffectListeners.add(fn);
    return () =>
        () => _reactiveModelState.listeners._sideEffectListeners.remove(fn);
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

  // int get observerLength => _reactiveModelState.listeners.observerLength;

  ReactiveModelBase<T> get reactiveModelState => _reactiveModelState;
}
