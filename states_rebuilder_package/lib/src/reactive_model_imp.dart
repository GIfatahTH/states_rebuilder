import 'dart:async';
import 'package:collection/collection.dart';

import 'package:flutter/widgets.dart';

import '../states_rebuilder.dart';
import 'assertions.dart';

///An implementation of [ReactiveModel]
class ReactiveModelImp<T> extends StatesRebuilder<T>
    implements ReactiveModel<T> {
  ///An abstract class that defines the reactive environment.
  ReactiveModelImp(this.inject, [this.isNewReactiveInstance = false])
      : assert(inject != null) {
    if (!inject.isAsyncInjected) {
      state = inject?.getSingleton();
      snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, state);
    }
  }

  @override
  ReactiveModel<S> stream<S>(Stream<S> Function(T) stream, {T initialValue}) {
    final ReactiveModel<S> rm = RM.stream<S>(
      stream(
        inject.getReactive().value,
      ),
    );

    final _callBack = rm.unsubscribe;
    cleaner(_callBack);
    rm.subscription
      ..onData((data) {
        if (data is T) {
          value = data;
        } else {
          snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
          if (hasObservers) {
            rebuildStates();
          }
        }
      })
      ..onError((dynamic e) {
        snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
        if (hasObservers) {
          rebuildStates(null, (context) {
            (rm as ReactiveModelImp<S>).onErrorHandler?.call(context, e);
          });
        }
      })
      ..onDone(() {
        cleaner(_callBack, true);
      });

    return rm;
  }

  @override
  ReactiveModel<F> future<F>(Future<F> Function(T) future, {T initialValue}) {
    final rm = stream<F>((s) => future(s).asStream());
    snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, state);

    if (hasObservers) {
      rebuildStates();
    }
    return rm;
  }

  @override
  Inject<T> inject;

  ///whether this is a new ReactiveModel instance
  final bool isNewReactiveInstance;

  @override
  AsyncSnapshot<T> snapshot;

  @override
  T state;

  ///The value the ReactiveModel holds. It is the same as [state]
  ///
  ///value is more suitable fro immutable objects,
  ///
  ///value when set it automatically notify observers. You do not have to explicitly use [setValue]
  @override
  T get value {
    return inject.getReactive().state;
  }

  @override
  set value(T data) {
    setValue(() => data);
  }

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
      void Function(BuildContext context, dynamic error) errorHandler) {
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

  // bool get isStreamDone => _isStreamDone;
  // set isStreamDone(bool isStreamDone) {
  //   _isStreamDone = isStreamDone;
  // }

  @override
  StreamSubscription<T> subscription;

  ///unsubscribe form the stream.
  ///It works for injected streams or futures.
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

    ReactiveModel<T> rm = inject.newReactiveMapFromSeed[seed.toString()];
    if (rm != null) {
      return rm;
    }
    rm = inject.getReactive(true);
    if (rm is ReactiveModelImp<T>) {
      rm._seed = seed.toString();
      inject.newReactiveMapFromSeed['${rm._seed}'] = rm;
    }
    rm.cleaner(() {
      rm.resetToIdle();
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

  @override
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
      joinSingletonToNewData: () => joinSingletonToNewData,
      setValue: true,
    );
  }

  dynamic _result;
  @override
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
      if (canRebuild) {
        rebuildStates(
          filterTags,
          (BuildContext context) {
            if (onError != null && hasError) {
              onError(context, error);
            } else if (onErrorHandler != null && hasError) {
              onErrorHandler(context, error);
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

    try {
      if (fn == null) {
        snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
        _rebuildStates(canRebuild: true);
        return;
      }
      _result = fn(state) as dynamic;
      if (_result is Future) {
        snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, state);
        _rebuildStates(canRebuild: canRebuild());
        _result = await _result;
      }
    } catch (e) {
      snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
      _rebuildStates(canRebuild: canRebuild());
      bool _cathError = catchError ??
          false ||
              _whenConnectionState ||
              onError != null ||
              inject.hasOnSetStateListener ||
              onErrorHandler != null;
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
      state = _result as T;
      snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
      (inject.reactiveSingleton as ReactiveModelImp<T>).state = state;
      inject.singleton = state;
      _rebuildStates(canRebuild: true);
      return;
    }

    snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
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
    fn(rm);
    return true;
  }
}
