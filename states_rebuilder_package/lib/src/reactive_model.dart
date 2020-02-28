import 'dart:async';

import 'package:flutter/material.dart';

import 'assertions.dart';
import 'inject.dart';
import 'injector.dart';
import 'states_rebuilder.dart';

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
///* To join reactive singleton with new singletons: [joinSingletonToNewData].
abstract class ReactiveModel<T> extends StatesRebuilder {
  ///An abstract class that defines the reactive environment.
  ReactiveModel.inj(this._inject, [this.isNewReactiveInstance = false]) {
    if (!_inject.isAsyncInjected) {
      state = _inject?.getSingleton();
    }
  }

  //Create a ReactiveModel for primitive values, enums and immutable objects
  factory ReactiveModel.create(T model) {
    final inject = Inject<T>(() => model);
    return inject.getReactive();
  }

  factory ReactiveModel.stream(Stream<T> stream,
      {dynamic name, T initialValue, List<dynamic> filterTags}) {
    final inject = Inject<T>.stream(
      () => stream,
      initialValue: initialValue,
      name: name,
      filterTags: filterTags,
    );
    return inject.getReactive();
  }

  factory ReactiveModel.future(Future<T> future,
      {dynamic name, T initialValue, List<dynamic> filterTags}) {
    final inject = Inject<T>.future(
      () => future,
      initialValue: initialValue,
      name: name,
      filterTags: filterTags,
    );
    return inject.getReactive();
  }

  // static ReactiveModel<T> get<T>(
  //     {BuildContext context, dynamic name, bool silent = false}) {
  //   return Injector.getAsReactive<T>(
  //       name: name, context: context, silent: silent);
  // }

  ///Get the singleton [ReactiveModel] instance of a model registered with [Injector].
  factory ReactiveModel(
      {BuildContext context, dynamic name, bool silent = false}) {
    return Injector.getAsReactive<T>(
        name: name, context: context, silent: silent);
  }

  final Inject<T> _inject;
  Inject<T> get inject => _inject;
  final bool isNewReactiveInstance;
  T _state;

  /// A representation of the most recent state (instance) of the injected model.
  AsyncSnapshot<T> _snapshot;
  AsyncSnapshot<T> get snapshot => _snapshot;

  ///The state of the injected model.
  T get state => _state;

  set state(T data) {
    _state = data;
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _state);
  }

  ///The value the ReactiveModel holds. It is the same as [state]
  T get value {
    return inject.getReactive().state;
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

  bool get isStreamDone => _isStreamDone;

  StreamSubscription<T> _subscription;

  ///The stream subscription. It is not null for injected streams or futures.
  StreamSubscription<T> get subscription => _subscription;

  ///Exhaustively switch over all the possible statuses of [connectionState].
  ///Used mostly to return [Widget]s.
  R whenConnectionState<R>({
    @required R Function() onIdle,
    @required R Function() onWaiting,
    @required R Function(T state) onData,
    @required R Function(dynamic error) onError,
    bool catchError = true,
  }) {
    _whenConnectionState = catchError;
    if (isIdle) {
      return onIdle();
    }
    if (hasError) {
      return onError(error);
    }
    if (isWaiting) {
      return onWaiting();
    }
    return onData(state);
  }

  bool _whenConnectionState = false;

  BuildContext _onSetStateContextFromGet;

  @deprecated
  dynamic customStateStatus;

  dynamic _joinSingletonToNewData;

  dynamic _seed;

  ///Return a new reactive instance.
  ///
  ///The [seed] parameter is used to unsure to always obtain the same new reactive
  ///instance after widget tree reconstruction.
  ///
  ///[seed] is optional and if not provided a default seed is used.
  ReactiveModel<T> asNew([dynamic seed = 'defaultReactiveSeed']) {
    if (isNewReactiveInstance) {
      return inject.getReactive().asNew(seed);
    }

    ReactiveModel<T> rm = inject.newReactiveMapFromSeed[seed.toString()];
    if (rm != null) {
      return rm;
    }

    rm = inject.getReactive(true);
    rm._seed = seed.toString();
    inject.newReactiveMapFromSeed[rm._seed] = rm;

    return rm;
  }

  ///Rest the async connection state to [isIdle]
  void resetToIdle() {
    _snapshot = AsyncSnapshot.withData(ConnectionState.none, state);
  }

  ///Rest the async connection state to [hasData]
  void resetToHasData() {
    _snapshot = AsyncSnapshot.withData(ConnectionState.done, state);
  }

  ///Holds data to be sent between reactive singleton and reactive new instances.
  dynamic get joinSingletonToNewData => _joinSingletonToNewData;

  /// Mutate the value of a Reactive Model and notify observers.
  ///
  /// Equivalent to [setState] but very convenient for primitives and immutable objects
  Future<void> setValue(
    FutureOr<T> Function() fn, {
    List<dynamic> filterTags,
    List<dynamic> seeds,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context, T data) onData,
    bool catchError = false,
    bool notifyAllReactiveInstances = false,
    bool joinSingleton,
  }) async {
    await setState(
      (_) => fn(),
      filterTags: filterTags,
      seeds: seeds,
      onSetState: onSetState,
      onRebuildState: onRebuildState,
      onData: onData,
      onError: onError,
      catchError: catchError,
      notifyAllReactiveInstances: notifyAllReactiveInstances,
      joinSingleton: joinSingleton,
      joinSingletonToNewData: joinSingletonToNewData,
      setValue: true,
    );
  }

  /// Mutate the state of the model and notify observers.
  ///
  /// [fn] takes the current state as argument. You can optionally define
  /// a list of [StateBuilder] [filterTags] to be notified after state mutation.
  ///
  /// To limit the rebuild process to a particular set of model instance variables use [watch].
  ///
  /// If you want to catch error define [catchError] to be true
  ///
  /// With [onSetState] you can define callBacks to be executed after mutating the state such as Navigation,
  /// show dialog or SnackBar.
  ///
  /// [onRebuildState] is similar to [onSetState] except that it is executed after
  /// the rebuilding process is completed.
  ///
  ///[onData] callback to be executed when ReactiveModel has data.
  ///
  ///[onError] callback to be executed when ReactiveModel has data.
  ///
  /// [watch] is a function that returns a single model instance variable or a list of
  /// them. The rebuild process will be triggered if at least one of
  /// the return variable changes. Returned variable must be either a primitive variable,
  /// a List, a Map or a Set.To use a custom type, you should override the `toString` method to reflect
  /// a unique identity of each instance.
  /// If it is not defined all listener will be notified when a new state is available.
  ///
  /// To notify all reactive instances created from the same [Inject] set [notifyAllReactiveInstances] true.
  ///
  /// [joinSingleton] used to define how new reactive instances will notify and modify the state of the reactive singleton
  /// TODO note on context
  Future<void> setState(
    Object Function(T) fn, {
    bool catchError,
    Object Function(T state) watch,
    List<dynamic> filterTags,
    List<dynamic> seeds,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context, T model) onData,
    dynamic Function() joinSingletonToNewData,
    bool joinSingleton = false,
    bool notifyAllReactiveInstances = false,
    bool setValue = false,
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
            if (onError != null && hasError) {
              onError(_onSetStateContextFromGet ?? context, error);
            }

            if (hasData) {
              if (onData != null) {
                onData(_onSetStateContextFromGet ?? context, state);
              }
              if (seeds != null) {
                for (var seed in seeds) {
                  final rm = inject.newReactiveMapFromSeed['$seed'];
                  rm?.rebuildStates();
                }
              }
            }

            if (onSetState != null) {
              onSetState(_onSetStateContextFromGet ?? context);
            }

            if (onRebuildState != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => onRebuildState(_onSetStateContextFromGet ?? context),
              );
            }

            _onSetStateContextFromGet = null;
          },
        );
        if (notifyAllReactiveInstances == true) {
          _notifyAll();
        } else if (isNewReactiveInstance) {
          final reactiveSingleton = inject.getReactive();
          if (joinSingletonToNewData != null) {
            reactiveSingleton._joinSingletonToNewData =
                joinSingletonToNewData();
          }

          if (inject.joinSingleton == JoinSingleton.withNewReactiveInstance ||
              joinSingleton == true) {
            reactiveSingleton
              .._snapshot = _snapshot
              ..rebuildStates();
          } else if (inject.joinSingleton ==
              JoinSingleton.withCombinedReactiveInstances) {
            reactiveSingleton
              .._snapshot = _combinedSnapshotState
              ..rebuildStates();
          }
        }
      }
    }

    dynamic result;
    try {
      if (fn == null) {
        _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
        _rebuildStates(canRebuild: true);
        return;
      }
      result = fn(state) as dynamic;
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
        result = await result;
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

    if (setValue == true) {
      if (!hasError && inject.getReactive().state == result) {
        return;
      }
      _state = result;
      _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, _state);
      inject.getReactive()._state = _state;
      _rebuildStates(canRebuild: true);
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
      return AsyncSnapshot.withError(ConnectionState.done, error);
    }
    if (isIdle) {
      return AsyncSnapshot.withData(ConnectionState.none, data);
    }

    return AsyncSnapshot.withData(ConnectionState.done, data);
  }

  void _notifyAll() {
    for (ReactiveModel<T> rm in inject.newReactiveInstanceList) {
      rm.rebuildStates();
    }
    inject.getReactive().rebuildStates();
  }

  @override
  String toString() {
    final String rm = '$runtimeType'
            .replaceAll('ReactiveStatesRebuilder', '')
            .replaceAll('StreamStatesRebuilder',
                inject.isFutureType ? 'Future of ' : 'Stream of ') +
        ' ${!isNewReactiveInstance ? 'singleton reactive model' : 'new reactive model seed: "$_seed"'}' +
        ' (#Code $hashCode)';
    return whenConnectionState<String>(
        onIdle: () => '$rm => isIdle',
        onWaiting: () => '$rm => isWaiting',
        onData: (data) => '$rm => hasData : $data',
        onError: (e) => '$rm => hasError : $e');
  }
}

///A package private class used to add reactive environment to models
class ReactiveStatesRebuilder<T> extends ReactiveModel<T> {
  ///A package private class used to add reactive environment to models
  ReactiveStatesRebuilder(Inject<T> inject,
      [bool isNewReactiveInstance = false])
      : assert(inject != null),
        super.inj(inject, isNewReactiveInstance);
}

///A package private class used to add reactive environment to Stream and future
class StreamStatesRebuilder<T> extends ReactiveModel<T> {
  StreamStatesRebuilder(Inject<T> injectAsync,
      [bool isNewReactiveInstance = false])
      : super.inj(injectAsync, isNewReactiveInstance) {
    _injectAsync = injectAsync;
    if (injectAsync.isFutureType) {
      _stream = injectAsync.creationFutureFunction().asStream();
    } else {
      _stream = injectAsync.creationStreamFunction();
    }
    assert(_stream != null);

    _state = injectAsync.initialValue;
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _state);

    _watch = injectAsync.watch;
    _watchCached = _watch != null ? _watch(_snapshot.data).toString() : null;
    _subscribe();
    cleaner(_unsubscribe);
  }
  Inject<T> _injectAsync;
  Object Function(T) _watch;
  Stream<T> _stream;
  ReactiveModel get reactiveModel => _injectAsync.getReactive();

  String _watchCached = '';
  String _watchActual = '';
  void _subscribe() {
    _subscription = _stream.listen(
      (data) {
        _watchActual = _watch != null ? _watch(data).toString() : null;
        _state = data;
        _snapshot = AsyncSnapshot<T>.withData(ConnectionState.active, _state);
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
    rm._onSetStateContextFromGet = ctx;
  }
}
