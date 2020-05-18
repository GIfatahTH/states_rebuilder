import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../states_rebuilder.dart';

///An implementation of [ReactiveModel]
class ReactiveModelImp<T> extends StatesRebuilder<T>
    implements ReactiveModel<T> {
  ///An abstract class that defines the reactive environment.
  ReactiveModelImp(this.inject, [this.isNewReactiveInstance = false])
      : assert(inject != null) {
    _isGlobal = inject.isGlobal;
    if (!inject.isAsyncInjected) {
      _state = inject?.getSingleton();
      stateAsync = Future.value(_state);
      snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _state);
    } else if (inject.isFutureType) {
      _state = inject.initialValue;
      stateAsync = Future.value(_state);
      setState(
        (s) => inject.creationFutureFunction(),
        catchError: true,
        silent: true,
        filterTags: inject.filterTags,
      );
    } else {
      _state = inject.initialValue;
      stateAsync = Future.value(_state);
      setState(
        (s) => inject.creationStreamFunction(),
        catchError: true,
        silent: true,
        filterTags: inject.filterTags,
        watch: inject.watch,
      );
    }
    if (!_isGlobal) {
      cleaner(() {
        inject.cleanInject();
        inject = null;
        _debounceTimer?.cancel();
      });
    }
  }
  bool _isGlobal = false;

  @override
  Inject<T> inject;

  T _state;

  ///The value the ReactiveModel holds. It is the same as [state]
  ///
  ///value is more suitable fro immutable objects,
  ///
  ///value when set it automatically notify observers. You do not have to explicitly use [setValue]
  @override
  T get state => isNewReactiveInstance ? inject.getReactive().state : _state;

  @override
  set state(T data) {
    setState((_) => data);
  }

  @override
  Future<T> stateAsync;
  @override
  AsyncSnapshot<T> snapshot;
  final bool isNewReactiveInstance;
  @override
  dynamic get error => snapshot.error;
  @override
  ConnectionState get connectionState => snapshot.connectionState;
  @override
  bool get isIdle => connectionState == ConnectionState.none;
  @override
  bool get isWaiting => connectionState == ConnectionState.waiting;
  @override
  bool get hasError => snapshot?.hasError;

  ///onError cashed handler
  void Function(BuildContext context, dynamic error) onErrorHandler;

  @override
  void onError(
    void Function(BuildContext context, dynamic error) errorHandler,
  ) {
    onErrorHandler = errorHandler;
  }

  void Function(T data) _onData;
  @override
  void onData(void Function(T data) fn) {
    _onData = fn;
  }

  @override
  bool get hasData =>
      !hasError &&
      (connectionState == ConnectionState.done ||
          connectionState == ConnectionState.active);

  ///true if the stream is done
  bool isStreamDone;

  @override
  StreamSubscription<dynamic> subscription;

  @override
  void unsubscribe() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  @override
  void Function() listenToRM(void Function(ReactiveModel<T> rm) fn) {
    final observer = _ReactiveModelSubscriber(fn: fn, rm: this);
    final tag = '_ReactiveModelSubscriber';
    addObserver(
      observer: observer,
      tag: tag,
    );

    return () => removeObserver(
          observer: observer,
          tag: tag,
        );
  }

  @override
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
  @override
  ReactiveModel<T> asNew([dynamic seed = 'defaultReactiveSeed']) {
    if (isNewReactiveInstance) {
      return inject.getReactive().asNew(seed);
    }
    ReactiveModelImp<T> rm =
        inject.newReactiveMapFromSeed[seed.toString()] as ReactiveModelImp<T>;
    if (rm != null) {
      return rm;
    }
    rm = inject.getReactive(true) as ReactiveModelImp<T>;
    inject.newReactiveMapFromSeed['$seed'] = rm;

    rm
      .._seed = '$seed'
      ..cleaner(() {
        inject?.newReactiveMapFromSeed?.remove('${rm._seed}');
      });

    return rm;
  }

  @override
  void resetToIdle() {
    snapshot = AsyncSnapshot.withData(ConnectionState.none, state);
  }

  @override
  void resetToHasData() {
    snapshot = AsyncSnapshot.withData(ConnectionState.done, state);
  }

  @override
  dynamic get joinSingletonToNewData => _joinSingletonToNewData;
  Timer _debounceTimer;
  @override
  Future<void> setState(
    Function(T s) fn, {
    bool catchError,
    Object Function(T state) watch,
    List<dynamic> filterTags,
    List<dynamic> seeds,
    bool shouldAwait = false,
    int debounceDelay,
    int throttleDelay,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context, T model) onData,
    dynamic Function() joinSingletonToNewData,
    bool joinSingleton = false,
    bool notifyAllReactiveInstances = false,
    bool silent = false,
  }) async {
    void Function(dynamic Function(T) fn) setStateCallBack =
        (dynamic Function(T) fn) {
      setState(
        fn,
        catchError: catchError,
        watch: watch,
        filterTags: filterTags,
        seeds: seeds,
        onSetState: onSetState,
        onRebuildState: onRebuildState,
        onData: onData,
        onError: onError,
        joinSingletonToNewData: joinSingletonToNewData,
        joinSingleton: joinSingleton,
        notifyAllReactiveInstances: notifyAllReactiveInstances,
        silent: silent,
      );
    };
    if (debounceDelay != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: debounceDelay), () {
        setStateCallBack(fn);
        _debounceTimer = null;
      });
      return;
    } else if (throttleDelay != null) {
      if (_debounceTimer != null) {
        return;
      }
      _debounceTimer = Timer(Duration(milliseconds: throttleDelay), () {
        _debounceTimer = null;
      });
    } else if (shouldAwait) {
      stateAsync.then(
        (_) => setStateCallBack(fn),
      );
      return;
    }

    void _rebuildStates({bool canRebuild = true}) {
      if (silent && !hasObservers) {
        if (hasData) {
          _onData?.call(state);
        }
        if (hasError) {
          onErrorHandler?.call(null, error);
        }
        return;
      }
      if (canRebuild) {
        rebuildStates(
          filterTags,
          (BuildContext context) {
            if (hasError) {
              if (onError != null) {
                onError(context, error);
              } else {
                onErrorHandler?.call(context, error);
              }
            }

            if (hasData) {
              if (onData != null) {
                onData(context, state);
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
              onSetState(context);
            }

            if (onRebuildState != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => onRebuildState(context),
              );
            }
          },
        );
        if (notifyAllReactiveInstances == true) {
          _notifyAll();
        } else if (isNewReactiveInstance) {
          final reactiveSingleton = inject.getReactive() as ReactiveModelImp<T>;
          if (joinSingletonToNewData != null) {
            reactiveSingleton._joinSingletonToNewData =
                joinSingletonToNewData();
          }

          if (inject.joinSingleton == JoinSingleton.withNewReactiveInstance ||
              joinSingleton == true) {
            reactiveSingleton
              ..snapshot = snapshot
              ..rebuildStates();
          } else if (inject.joinSingleton ==
              JoinSingleton.withCombinedReactiveInstances) {
            reactiveSingleton
              ..snapshot = _combinedSnapshotState
              ..rebuildStates();
          }
        }
      }
    }

    dynamic watchBefore = watch?.call(state);
    bool canRebuild() {
      if (watch == null) {
        return true;
      }
      bool canRebuild;
      dynamic watchAfter = watch?.call(state);
      canRebuild =
          !(const DeepCollectionEquality()).equals(watchAfter, watchBefore);

      watchBefore = watchAfter;
      return canRebuild;
    }

    final Completer<T> _completer = Completer<T>();
    stateAsync = _completer.future.catchError((dynamic _) {});

    void _onWaitingCallback() {
      snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, state);
      _rebuildStates(canRebuild: canRebuild());
    }

    bool _onDataCallback(dynamic data) {
      if (data is T) {
        if (!hasError && !isWaiting && inject.getReactive().state == data) {
          return false;
        }
        _state = data;
        snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, _state);
        (inject.reactiveSingleton as ReactiveModelImp<T>)._state = _state;
        inject.singleton = _state;
        return true;
      }

      snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, _state);
      return true;
    }

    void _onErrorCallBack(dynamic error) {
      snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, error);
      _rebuildStates(canRebuild: true); //TODO
      bool _cathError = catchError ??
          false ||
              _whenConnectionState ||
              onError != null ||
              inject.hasOnSetStateListener ||
              onErrorHandler != null;
      _whenConnectionState = false;

      if (_cathError == false) {
        throw error;
      }
    }

    try {
      if (fn == null) {
        snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
        _rebuildStates(canRebuild: true);
        return;
      }
      final dynamic _result = fn(state) as dynamic;

      if (_result is Future) {
        silent = true;
        subscription = Stream<dynamic>.fromFuture(_result).listen(
          (dynamic d) {
            final isStateModified = _onDataCallback(d);
            _completer.complete(state);
            if (isStateModified) {
              _rebuildStates(canRebuild: canRebuild());
            }
          },
          onError: (dynamic e, StackTrace s) {
            _completer.completeError(e, s);
            _onErrorCallBack(e);
          },
          onDone: () {
            cleaner(unsubscribe, true);
          },
        );
        cleaner(unsubscribe);
        _onWaitingCallback();
      } else if (_result is Stream) {
        silent = true;
        subscription = _result.listen(
          (dynamic d) {
            if (_onDataCallback(d)) {
              _rebuildStates(canRebuild: canRebuild());
            }
          },
          onError: _onErrorCallBack,
          onDone: () {
            isStreamDone = true;
            cleaner(unsubscribe, true);
          },
          cancelOnError: false,
        );
        if (!_isGlobal) {
          cleaner(unsubscribe);
        }
        _onWaitingCallback();
      } else {
        if (_onDataCallback(_result)) {
          _rebuildStates(canRebuild: canRebuild());
        }
      }
    } catch (e) {
      _onErrorCallBack(e);
    }
  }

  @override
  ReactiveModel<S> stream<S>(
    Stream<S> Function(T s, StreamSubscription<dynamic> subscription) stream, {
    S initialValue,
    Object Function(S s) watch,
  }) {
    return RM.stream(
      stream(inject.getReactive().state, subscription),
      initialValue: initialValue,
      watch: watch,
    );
  }

  @override
  ReactiveModel<F> future<F>(
    Future<F> Function(T f, Future<T> stateAsync) future, {
    F initialValue,
    int debounceDelay,
  }) {
    return RM.future(
      future(inject.getReactive().state, stateAsync),
      initialValue: initialValue,
    );
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
        onError: (dynamic e) {
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
    (inject.getReactive() as ReactiveModelImp<T>).rebuildStates();
  }

  @override
  bool isA<T>() {
    if (inject.isAsyncInjected) {
      if (inject.isFutureType) {
        return inject.creationFutureFunction is T Function();
      }
      return inject.creationStreamFunction is T Function();
    }
    return inject.creationFunction is T Function();
  }

  // ReactiveModel<T> as<R>() {
  //   assert(state is R);
  //   return this.asNew(R);
  // }
  @override
  String type() {
    String type = inject.isAsyncInjected
        ? inject.isFutureType ? 'Future of ' : 'Stream of '
        : '';
    type += '<$T>';
    return type;
  }

  @override
  String toString() {
    String rm =
        '${type()} ${!isNewReactiveInstance ? 'RM' : 'RM (new seed: "$_seed")'}'
        ' (#Code $hashCode)';
    int num = 0;
    observers().values.toSet().forEach((o) {
      if (!'$o'.contains('$Injector')) {
        num++;
      }
    });

    return '$rm | ${whenConnectionState<String>(
      onIdle: () => 'isIdle ($state)',
      onWaiting: () => 'isWaiting ($state)',
      onData: (data) => 'hasData : ($data)',
      onError: (dynamic e) => 'hasError : ($e)',
    )} | $num observing widgets';
  }
}

class _ReactiveModelSubscriber<T> implements ObserverOfStatesRebuilder {
  final void Function(ReactiveModel<T> rm) fn;
  final ReactiveModel<T> rm;

  _ReactiveModelSubscriber({this.fn, this.rm});

  @override
  bool update([Function(BuildContext p1) onSetState, dynamic message]) {
    fn?.call(rm);
    return true;
  }
}
