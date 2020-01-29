import 'dart:async';

import 'package:flutter/material.dart';
import 'inject.dart';
import 'states_rebuilder.dart';

import 'assertions.dart';

///An abstract class that defines the reactive environment.
///
///With `states_rebuilder` you can use pure dart class for your business logic,
///and reactivity is implicitly add by `states_rebuilder` using [Injector.getAsReactive] method.
///
///[ReactiveModel] adds the following getters and methods:
///
///* To trigger an event : [setState]
///
///* To get the current state : [state]
///
///* For streams and futures: [subscription],  [snapshot].
///
///* Far asynchronous tasks :[connectionState], [hasError], [error], [hasData].
///
///* For defining custom state status other than [connectionState] : [customStateStatus].
///
///* To join reactive singleton with new singletons: [joinSingletonToNewData].
abstract class ReactiveModel<T> extends StatesRebuilder {
  ///An abstract class that defines the reactive environment.
  ReactiveModel([this._inject, this.isNewReactiveInstance = false]) {
    if (!_inject.isAsyncInjected) {
      state = _inject?.getSingleton();
    }
  }

  final Inject<T> _inject;
  Inject<T> get inject => _inject;
  final isNewReactiveInstance;
  T _state;

  /// A representation of the most recent state (instance) of the injected model.
  AsyncSnapshot<T> _snapshot;
  AsyncSnapshot<T> get snapshot => _snapshot;

  ///The state of the injected model.
  T get state => _snapshot?.data ?? _state;

  set state(T data) {
    _state = data;
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _state);
  }

  ///The latest error object received by the asynchronous computation.
  dynamic get error => _snapshot.error;

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

  ///Returns whether this snapshot contains a non-null [AsyncSnapshot.data] value.
  ///Unlike in [AsyncSnapshot], hasData has special meaning here.
  ///It means that the [connectionState] is [ConnectionState.done] with no error.
  bool get hasData =>
      !hasError && connectionState == ConnectionState.done ||
      connectionState == ConnectionState.active;
  bool _isStreamDone;
  bool get isStreamDone => inject == null ? _isStreamDone : null;

  ///The stream subscription. It is not null for injected streams or futures.
  StreamSubscription<T> get subscription => null;

  ///Exhaustively switch over all the possible statuses of [connectionState].
  ///Used mostly to return [Widget]s.
  R whenConnectionState<R>({
    @required R Function() onIdle,
    @required R Function() onWaiting,
    @required R Function(T state) onData,
    @required R Function(dynamic error) onError,
  }) {
    _whenConnectionState = true;
    if (this.isIdle) {
      return onIdle();
    }
    if (this.hasError) {
      return onError(this.error);
    }
    if (this.isWaiting) {
      return onWaiting();
    }
    return onData(this.state);
  }

  bool _whenConnectionState = false;

  BuildContext _onSetStateContextFromGet;

  Future<void> setState(
    Object Function(T) fn, {
    bool catchError,
    Object Function(T state) watch,
    List<dynamic> filterTags,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context, T model) onData,
    // dynamic joinSingletonToNewData,//TODO
    bool joinSingleton: false,
    bool notifyAllReactiveInstances = false,
  }) async {
    assert(() {
      if (inject.isAsyncInjected == true) {
        throw Exception(AssertMessage.setStateCalledOnAsyncInjectedModel());
      }
      return true;
    }());

    final String watchBefore = watch != null ? watch(state).toString() : null;

    void _rebuildStates({bool canRebuild = true}) {
      if (hasObservers && canRebuild) {
        rebuildStates(
          filterTags,
          (BuildContext context) {
            assert((_onSetStateContextFromGet ?? context) != null);
            if (onSetState != null) {
              onSetState(_onSetStateContextFromGet ?? context);
            }

            if (onRebuildState != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => onRebuildState(_onSetStateContextFromGet ?? context),
              );
            }

            if (onData != null && hasData) {
              onData(_onSetStateContextFromGet ?? context, state);
            }

            if (onError != null && hasError) {
              onError(_onSetStateContextFromGet ?? context, error);
            }
            _onSetStateContextFromGet = null;
          },
        );
        if (notifyAllReactiveInstances) {
          _notifyAll();
        } else if (isNewReactiveInstance) {
          if (inject.joinSingleton == JoinSingleton.withNewReactiveInstance ||
              joinSingleton) {
            final reactiveSingleton = inject.getReactive();
            reactiveSingleton._snapshot = _snapshot;
            reactiveSingleton.rebuildStates();
          } else if (inject.joinSingleton ==
              JoinSingleton.withCombinedReactiveInstances) {
            final reactiveSingleton = inject.getReactive();

            reactiveSingleton._snapshot = _combinedSnapshotState;
            reactiveSingleton.rebuildStates();
          }
        }
      }
    }

    try {
      final dynamic result = fn != null ? fn(state) as dynamic : null;
      if (result is Future) {
        _snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, state);
        //Do need to call setState during the build of the widget.
        try {
          _rebuildStates(canRebuild: watch == null);
        } catch (e) {
          if (e is! FlutterError) {
            rethrow;
          }
        }
        await result;
      }
    } catch (e) {
      _snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
      _rebuildStates(canRebuild: watch == null);
      bool _cathError = catchError ??
          false ||
              _whenConnectionState ||
              onError != null ||
              inject.hasOnSetStateListener;
      if (_cathError == false) {
        rethrow;
      }
      _whenConnectionState = false;
      return;
    }
    final String watchAfter = watch != null ? watch(state).toString() : null;

    bool
        canRebuild = //watch for async tasks will rebuild only if the watched parameter changed
        watch == null || watchBefore.hashCode != watchAfter.hashCode;
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);

    _rebuildStates(canRebuild: canRebuild);
  }

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
        onError: (e) {
          error = e;
          return hasError = true;
        },
      );
    }

    if (isWaiting) {
      return AsyncSnapshot.withData(ConnectionState.waiting, data);
    }
    if (hasError) {
      //TODO what about catching the error
      return AsyncSnapshot.withError(ConnectionState.done, error);
    }
    if (isIdle) {
      return AsyncSnapshot.withData(ConnectionState.none, data);
    }

    return AsyncSnapshot.withData(ConnectionState.done, data);
  }

  void _notifyAll() {
    for (ReactiveModel<T> rm in inject.newReactiveInstanceList) {
      rm._snapshot = _snapshot;
      rm.rebuildStates();
    }
    final rs = inject.getReactive();
    rs._snapshot = _snapshot;
    rs.rebuildStates();
  }
}

///A package private class used to add reactive environment to models
class ReactiveStatesRebuilder<T> extends ReactiveModel<T> {
  ///A package private class used to add reactive environment to models
  ReactiveStatesRebuilder(Inject<T> inject,
      [bool isNewReactiveInstance = false])
      : assert(inject != null),
        super(inject, isNewReactiveInstance);
}

///A package private class used to add reactive environment to Stream and future
class StreamStatesRebuilder<T> extends ReactiveModel<T> {
  StreamStatesRebuilder(Inject<T> injectAsync,
      [bool isNewReactiveInstance = false])
      : super(injectAsync, isNewReactiveInstance) {
    _injectAsync = injectAsync;
    if (injectAsync.isFutureType) {
      _stream = injectAsync.creationFutureFunction().asStream();
    } else {
      _stream = injectAsync.creationStreamFunction();
    }
    assert(_stream != null);

    _snapshot = AsyncSnapshot<T>.withData(
        ConnectionState.none, injectAsync.initialValue);

    _watch = injectAsync.watch;
    _watchCached = _watch != null ? _watch(_snapshot.data).toString() : null;
    _subscribe();
    cleaner(_unsubscribe);
  }
  Inject<T> _injectAsync;
  Object Function(T) _watch;
  Stream<T> _stream;
  ReactiveModel get reactiveModel => _injectAsync.getReactive();

  StreamSubscription<T> _subscription;
  @override
  StreamSubscription<T> get subscription => _subscription;
  String _watchCached = '';
  String _watchActual = '';
  void _subscribe() {
    _subscription = _stream.listen(
      (data) {
        _watchActual = _watch != null ? _watch(data).toString() : null;
        _snapshot = AsyncSnapshot<T>.withData(ConnectionState.active, data);
        if (_watch == null || _watchCached.hashCode != _watchActual.hashCode) {
          if (reactiveModel.hasObservers) {
            reactiveModel.rebuildStates(_injectAsync.filterTags);
          }
          _watchCached = _watchActual;
        }
      },
      onError: (e) {
        _snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
        if (reactiveModel.hasObservers) {
          reactiveModel.rebuildStates(_injectAsync.filterTags);
        }
      },
      onDone: () {
        _isStreamDone = true;
        _snapshot = _snapshot.inState(ConnectionState.done);
        if (reactiveModel.hasObservers) {
          reactiveModel.rebuildStates(_injectAsync.filterTags);
        }
      },
      cancelOnError: false,
    );
    _snapshot = snapshot.inState(ConnectionState.waiting);
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}

class ReactiveModelInternal {
  static setOnSetStateContext(ReactiveModel rm, BuildContext ctx) {
    print('setOnSetStateContext ${ctx.hashCode}');
    rm._onSetStateContextFromGet = ctx;
  }
}
