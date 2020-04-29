import 'dart:async';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'assertions.dart';
import 'inject.dart';
import 'injector.dart';
import 'states_rebuilder.dart';

///An abstract class that defines the reactive environment.
///
///`states_rebuilder` is based on the concept of [ReactiveModel].
///
///Pure dart models (or Blocs, or Stores) can be injected globally using the [Injector].
///To obtained the injected ReactiveModel singleton, you use :
///```dart
/// final modelRM = Injector.getAsReactive<T>();
/// //or more concisely:
/// final modelRM = ReactiveModel<T>();
/// // or even more concisely (since 1.15.0 release):
/// final modelRM = RM.get<T>();
///```
///
///In another hand, [ReactiveModel] can can be created locally.
///```dart
/////creating a reactive model form integer
///final counterRM = ReactiveModel<int>.create(0);
///// or more concisely (since 1.15.0 release)
///final counterRM = RM.create<int>(0);
///```
///
///with `states_rebuilder` we can locally create `ReactiveModel` from primitive values, objects, futures or streams.
///
///To consume the created `ReactiveModel`, we use one of the available widget observers : [StateBuilder], [WhenRebuilder], [WhenRebuilderOr] or [OnSetStateListener].
///
///
///[ReactiveModel] adds the following getters and methods:
///
///* To trigger an event : [setState], [setValue]
///
///* To get the current state : [state],[value]
///
///* For streams and futures: [subscription],  [snapshot].
///
///* Far asynchronous tasks :[connectionState], [hasError], [error], [hasData].
///
///and many more...
abstract class ReactiveModel<T> extends StatesRebuilder<T> {
  ///An abstract class that defines the reactive environment.
  ReactiveModel.inj(this._inject, [this.isNewReactiveInstance = false]) {
    if (!_inject.isAsyncInjected) {
      _state = _inject?.getSingleton();
      _snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _state);
    }
  }

  ///Create a ReactiveModel for primitive values, enums and immutable objects
  ///
  ///You can use the shortcut [RM.create]:
  ///```dart
  ///RM.create<T>(T model);
  ///```
  factory ReactiveModel.create(T model) {
    final inject = Inject<T>(() => model);
    return inject.getReactive();
  }

  ///Create a ReactiveModel form stream
  ///
  ///You can use the shortcut [RM.stream]:
  ///```dart
  ///RM.stream<T>(Stream<T> stream);
  ///```
  ///Use [unsubscribe] to dispose of the stream.
  factory ReactiveModel.stream(Stream<T> stream,
      {dynamic name,
      T initialValue,
      List<dynamic> filterTags,
      Object Function(T) watch}) {
    final inject = Inject<T>.stream(
      () => stream,
      initialValue: initialValue,
      name: name,
      filterTags: filterTags,
      watch: watch,
    );
    return inject.getReactive();
  }

  ///Get a stream from the state and subscribe to it and
  ///notify observing widget of this [ReactiveModel]
  ///
  ///The callback exposes the current state as parameter.
  ///
  ///The stream is automatically disposed of when this [ReactiveModel] is disposed.
  ///
  ///Works well for immutable objects
  ReactiveModel<S> stream<S>(Stream<S> Function(T) stream, {T initialValue}) {
    final rm = ReactiveModel<S>.stream(stream(state));

    final _callBack = () {
      rm.unsubscribe();
    };
    cleaner(_callBack);
    rm.subscription
      ..onData((data) {
        if (data is T) {
          value = data;
        } else {
          _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, _state);
          if (hasObservers) {
            rebuildStates();
          }
        }
      })
      ..onError((e) {
        _snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
        if (hasObservers) {
          rebuildStates(null, (context) {
            rm._onError?.call(_activeCtx(context), e);
          });
        }
      })
      ..onDone(() {
        cleaner(_callBack, true);
      });

    return rm;
  }

  ///Create a ReactiveModel form future
  ///
  ///You can use the shortcut [RM.future]:
  ///```dart
  ///RM.future<T>(future<T> future);
  ///```
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

  ///Get a Future from the state and subscribe to it and
  ///notify observing widget of this [ReactiveModel]
  ///
  ///The callback exposes the current state as parameter.
  ///
  ///The future is automatically canceled when this [ReactiveModel] is disposed.
  ///
  ///Works well for immutable objects
  ReactiveModel<F> future<F>(Future<F> Function(T) future, {T initialValue}) {
    final rm = stream<F>((s) => future(s).asStream());
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, _state);
    //Do need to call setState during the build of the widget.
    try {
      if (hasObservers) {
        rebuildStates();
      }
    } catch (e) {
      if (e is! FlutterError) {
        rethrow;
      }
    }
    return rm;
  }

  ///Get the singleton [ReactiveModel] instance of a model registered with [Injector].
  ///
  /// ou can use the shortcut [RM.get]:
  ///```dart
  ///RM.get<T>(;
  ///```
  ///
  ///
  factory ReactiveModel(
      {BuildContext context, dynamic name, bool silent = false}) {
    return Injector.getAsReactive<T>(
        name: name, context: context, silent: silent);
  }

  final Inject<T> _inject;
  Inject<T> get inject => _inject;

  ///whether this is a new ReactiveModel instance
  final bool isNewReactiveInstance;

  T _state;

  AsyncSnapshot<T> _snapshot;

  /// A representation of the most recent state (instance) of the injected model.
  AsyncSnapshot<T> get snapshot => _snapshot;

  ///The state of the injected model.
  T get state => _state;

  ///The state of the injected model.
  // set state(T data) {
  //   _state = data;
  //   _snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _state);
  // }

  ///The value the ReactiveModel holds. It is the same as [state]
  ///
  ///value is more suitable fro immutable objects,
  ///
  ///value when set it automatically notify observers. You do not have to explicitly use [setValue]
  T get value {
    return inject.getReactive().state;
  }

  set value(T data) {
    setValue(() => data);
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

  void Function(BuildContext context, dynamic error) _onError;

  ///The global error event handler of this ReactiveModel.
  ///
  ///You can override this error handling to use a specific handling in response to particular events
  ///using the onError callback of [setState] or [setValue].
  void onError(
      void Function(BuildContext context, dynamic error) errorHandler) {
    _onError = errorHandler;
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

  bool _isStreamDone;

  bool get isStreamDone => _isStreamDone;

  StreamSubscription<T> _subscription;

  ///unsubscribe form the stream.
  ///It works for injected streams or futures.
  void unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  ///The stream (or Future) subscription. It works only for injected streams or futures.
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

  BuildContext _onSetStateContextFromGet;
  BuildContext _ctx;

  //active context is the context of the latest add widget observer
  BuildContext _activeCtx(BuildContext context) {
    if (_onSetStateContextFromGet != null &&
        _onSetStateContextFromGet.findRenderObject().attached) {
      if (context.widget is StateBuilder<Injector>) {
        return _onSetStateContextFromGet;
      }
      //Due to the way hashCode of context is implemented, the higher hashCode is the latter the widget is add
      return _ctx ??= context.hashCode > _onSetStateContextFromGet.hashCode
          ? context
          : _onSetStateContextFromGet;
    }
    if (context.widget is StateBuilder<Injector>) {
      return null;
    }
    return _ctx ??= context;
  }

  dynamic _result;

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
  Future<void> setState(
    Function(T) fn, {
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

    void _rebuildStates({bool canRebuild = true}) {
      if (hasObservers && canRebuild) {
        rebuildStates(
          filterTags,
          (BuildContext context) {
            _ctx = null;
            final exposedContext = _activeCtx(context);
            if (exposedContext == null) {
              assert(observers().length > 1, '''
***No observer is subscribed yet***
| There is no observer subscribed to this observable $runtimeType model.
| To subscribe a widget you use:
| 1- StateRebuilder for an already defined:
|   ex:
|   StatesRebuilder(
|     observer: () => ${runtimeType}instance,
|     builder : ....
|   )
| 2- Injector.get<$runtimeType>(context : context). for explicit reactivity.
| 3- RM.get<$runtimeType>(context : context). for implicit reactivity.
| 4- StateRebuilder for new reactive environment:
|   ex:
|   StatesRebuilder<$runtimeType>(
|     builder : ....
|   )
| 5 - WhenRebuilder, WhenRebuilderOr, OnSetStateListener, StatesWithMixinBuilder are similar to StateBuilder.
|
''');
              return;
            }
            if (onError != null && hasError) {
              onError(exposedContext, error);
            } else if (this._onError != null && hasError) {
              this._onError(exposedContext, error);
            }

            if (hasData) {
              if (onData != null) {
                onData(exposedContext, state);
              }
              _onData?.call(state);
              if (seeds != null) {
                for (var seed in seeds) {
                  final rm = inject.newReactiveMapFromSeed['$seed'];
                  rm?.rebuildStates();
                }
              }
            }

            if (onSetState != null) {
              onSetState(exposedContext);
            }

            if (onRebuildState != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => onRebuildState(exposedContext),
              );
            }
          },
        );
        _onSetStateContextFromGet = null;
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

    String watchBefore = watch != null ? watch(state).toString() : null;
    bool canRebuild() {
      final String watchAfter = watch != null ? watch(state).toString() : null;
      //watch for async tasks will rebuild only if the watched parameter changed
      bool result =
          watch == null || watchBefore.hashCode != watchAfter.hashCode;
      watchBefore = watchAfter;
      return result;
    }

    try {
      if (fn == null) {
        _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
        _rebuildStates(canRebuild: true);
        return;
      }
      _result = fn(state) as dynamic;
      if (_result is Future) {
        _snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, state);
        //Do need to call setState during the build of the widget.
        try {
          _rebuildStates(canRebuild: canRebuild());
        } catch (e) {
          if (e is! FlutterError) {
            rethrow;
          }
        }
        _result = await _result;
      }
    } catch (e) {
      _snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
      _rebuildStates(canRebuild: canRebuild());
      bool _cathError = catchError ??
          false ||
              _whenConnectionState ||
              onError != null ||
              inject.hasOnSetStateListener ||
              this._onError != null;
      if (_cathError == false) {
        rethrow;
      }
      _whenConnectionState = false;
      return;
    }

    if (setValue == true) {
      if (!hasError && !isWaiting && inject.getReactive().state == _result) {
        return;
      }
      _state = _result;
      _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, _state);
      inject.reactiveSingleton._state = _state;
      inject.singleton = _state;
      _rebuildStates(canRebuild: true);
      return;
    }

    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
    _rebuildStates(canRebuild: canRebuild());
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

  bool isA<T>() {
    if (_inject.isAsyncInjected) {
      if (_inject.isFutureType) {
        return _inject.creationFutureFunction is T Function();
      }
      return _inject.creationStreamFunction is T Function();
    }
    return _inject.creationFunction is T Function();
  }

  // ReactiveModel<T> as<R>() {
  //   assert(_state is R);
  //   return this.asNew(R);
  // }

  // void copyRM(ReactiveModel<T> to) {
  //   to._state = _state;
  //   to._snapshot = _snapshot;
  //   copy(to);
  //   to._onError = _onError;
  // }

  @override
  String toString() {
    String rm = inject.isAsyncInjected
        ? inject.isFutureType ? 'Future of ' : 'Stream of '
        : '';
    rm += '<$T>' +
        ' ${!isNewReactiveInstance ? 'RM' : 'RM (new seed: "$_seed")'}' +
        ' (#Code $hashCode)';
    int num = 0;
    observers().values.toSet().forEach((o) {
      if (!'$o'.contains('$Injector')) {
        num++;
      }
    });

    final int nbrInheritedObserver =
        '$_onSetStateContextFromGet'.split('$T').length - 1;
    final nbrObserver =
        nbrInheritedObserver > 0 ? '$num+I($nbrInheritedObserver)' : '$num';

    return '$rm | ' +
        whenConnectionState<String>(
          onIdle: () => 'isIdle ($state)',
          onWaiting: () => 'isWaiting ($state)',
          onData: (data) => 'hasData : ($data)',
          onError: (e) => 'hasError : ($e)',
        ) +
        ' | $nbrObserver observing widgets';
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
  StreamStatesRebuilder(this.injectAsync, [bool isNewReactiveInstance = false])
      : super.inj(injectAsync, isNewReactiveInstance) {
    subscribe();
    cleaner(_unsubscribe);
  }
  Inject<T> injectAsync;
  Object Function(T) _watch;
  Stream<T> _stream;
  ReactiveModel _reactiveModel;
  ReactiveModel get reactiveModel =>
      _reactiveModel ??= injectAsync.getReactive();

  String _watchCached;
  String _watchActual;
  bool _hasError = false;
  void subscribe() {
    if (injectAsync.isFutureType) {
      _stream = injectAsync.creationFutureFunction().asStream();
    } else {
      _stream = injectAsync.creationStreamFunction();
    }
    assert(_stream != null);

    _state = injectAsync.initialValue;
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _state);

    _watch = injectAsync.watch;
    _watchActual = '';
    _watchCached = _watch != null ? _watch(_snapshot.data).toString() : null;

    _subscription = _stream.listen(
      (data) {
        _watchActual = _watch != null ? _watch(data).toString() : null;
        _state = data;
        _snapshot = AsyncSnapshot<T>.withData(ConnectionState.active, _state);
        if (_hasError ||
            _watch == null ||
            _watchCached.hashCode != _watchActual.hashCode) {
          if (reactiveModel.hasObservers) {
            reactiveModel.rebuildStates(injectAsync.filterTags);
          }
          _watchCached = _watchActual;
          _hasError = false;
        }
      },
      onError: (e) {
        _snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
        _hasError = true;

        if (reactiveModel.hasObservers) {
          reactiveModel.rebuildStates(
            injectAsync.filterTags,
            (context) {
              _onError?.call(_activeCtx(context), e);
            },
          );
        }
      },
      onDone: () {
        _snapshot = _snapshot.inState(ConnectionState.done);
        if (reactiveModel.hasObservers && !injectAsync.isFutureType) {
          _isStreamDone = true;
          reactiveModel.rebuildStates(injectAsync.filterTags);
        }
      },
      cancelOnError: false,
    );
    _snapshot = snapshot.inState(ConnectionState.waiting);
  }

  void _unsubscribe() {
    unsubscribe();
  }
}

class ReactiveModelInternal {
  static setOnSetStateContext(ReactiveModel rm, BuildContext ctx) {
    rm._onSetStateContextFromGet = ctx;
  }

  static void state<T>(ReactiveModel rm, T state) {
    rm._state = state;
  }
}

abstract class RM {
  ///Create a [ReactiveModel] from primitives or any object
  static ReactiveModel<T> create<T>(T model) {
    final T _model = model;
    // assert(T != dynamic);
    return ReactiveModel<T>.create(_model);
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
    BuildContext context,
    bool silent,
  }) {
    return Injector.getAsReactive<T>(
      name: name,
      context: context,
      silent: silent,
    );
  }

  ///get the model T and create a future ReactiveModel.
  ///
  ///Instead of writing:
  ///
  ///```dart
  ///final model = Injector.get<T>();
  ///
  ///final futureRM = RM.future<R>(model.futureMethod());
  ///```
  ///
  ///You can simply use:
  ///```dart
  ///final futureRM = RM.getFuture<T, R>((m)=>m.futureMethod());
  ///```
  static ReactiveModel<R> getFuture<T, R>(
    Future<R> Function(T) future, {
    String name,
    BuildContext context,
    R initialValue,
  }) {
    final m = Injector.get<T>(name: name, context: context);
    return RM.future(
      future(m),
      initialValue: initialValue,
    );
  }

  ///get the model T and create a stream ReactiveModel.
  ///
  ///Instead of writing:
  ///
  ///```dart
  ///final model = Injector.get<T>();
  ///
  ///final streamRM = RM.stream<R>(model.streamMethod());
  ///```
  ///
  ///You can simply use:
  ///```dart
  ///final streamRM = RM.getStream<T, R>((m)=>m.streamMethod());
  ///```
  static ReactiveModel<R> getStream<T, R>(
    Stream<R> Function(T) stream, {
    String name,
    BuildContext context,
    R initialValue,
    Object Function(R) watch,
  }) {
    final m = Injector.get<T>(name: name, context: context);
    return RM.stream(
      stream(m),
      initialValue: initialValue,
      watch: watch,
    );
  }

  ///get the model T and call [setState].
  ///
  ///Instead of writing:
  ///
  ///```dart
  ///RM.get<T>().setState((s)=>...)
  ///```
  ///
  ///You can simply use:
  ///```dart
  ///RM.getSetState<T>((s)=>....);
  ///```
  static Future<void> getSetState<T>(
    Function(T) fn, {
    bool catchError,
    Object Function(T) watch,
    List<dynamic> filterTags,
    List<dynamic> seeds,
    void Function(BuildContext) onSetState,
    void Function(BuildContext) onRebuildState,
    void Function(BuildContext, dynamic) onError,
    void Function(BuildContext, T) onData,
    dynamic Function() joinSingletonToNewData,
    bool joinSingleton,
    bool notifyAllReactiveInstances,
    bool setValue,
  }) {
    return RM.get<T>().setState(
          fn,
          catchError: catchError,
          watch: watch,
          filterTags: filterTags,
          seeds: seeds,
          onSetState: onSetState,
          onRebuildState: onRebuildState,
          onError: onError,
          onData: onData,
          joinSingletonToNewData: joinSingletonToNewData,
          joinSingleton: joinSingleton,
          notifyAllReactiveInstances: notifyAllReactiveInstances,
          setValue: setValue,
        );
  }

  ///if true, An informative message is printed in the consol, showing the model being sending the Notification,
  static bool printActiveRM = false;

  ///get the model that is sending the notification
  static ReactiveModel get notified =>
      StatesRebuilderInternal.getNotifiedModel();
}
