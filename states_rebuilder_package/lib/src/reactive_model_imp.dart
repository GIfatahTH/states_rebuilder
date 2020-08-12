import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'inject.dart';
import 'injector.dart';
import 'reactive_model.dart';
import 'states_rebuilder.dart';

const deepEquality = DeepCollectionEquality();

///An implementation of [ReactiveModel]
class ReactiveModelImp<T> extends StatesRebuilder<T> with ReactiveModel<T> {
  ///An abstract class that defines the reactive environment.
  ReactiveModelImp(this.inject, [this.isNewReactiveInstance = false])
      : assert(inject != null) {
    _isGlobal = inject.isGlobal;
    if (!inject.isAsyncInjected) {
      snapshot = AsyncSnapshot<T>.withData(
        ConnectionState.none,
        inject?.getSingleton(),
      );
    } else if (inject.isFutureType) {
      _state = inject.initialValue;
      setState(
        (s) => inject.creationFutureFunction(),
        catchError: true,
        silent: true,
        filterTags: inject.filterTags,
      );
    } else {
      _state = inject.initialValue;
      // stateAsync = Future.value(_state);
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
        _contextSet.clear();
        _listenToRMSet.clear();
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
  T get state {
    if (!isNewReactiveInstance) {
      return _state;
    }
    return inject.getSingleton();
  }

  @override
  set state(T data) {
    setState((_) => data);
  }

  AsyncSnapshot<T> _snapshot;
  AsyncSnapshot<T> lastSnapshot;

  @override
  AsyncSnapshot<T> get snapshot => _snapshot;
  set snapshot(AsyncSnapshot<T> snap) {
    lastSnapshot = _snapshot;
    assert(snap != null);
    _state = snap.data ?? _state;
    _snapshot = snap;
  }

  final bool isNewReactiveInstance;
  @override
  dynamic get error => snapshot.error;
  StackTrace stackTrace;
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

  int numberOfFutureAndStreamBuilder = 0;

  @override
  StreamSubscription<dynamic> subscription;

  @override
  void unsubscribe() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  final _listenToRMSet = <void Function(ReactiveModel<T>)>{};
  Set<dynamic> get listenToRMSet {
    return {..._listenToRMSet};
  }

  void _listenToRMCall() => listenToRMSet.forEach((fn) => fn(this));
  @override
  Disposer listenToRM(
    void Function(ReactiveModel<T> rm) fn, {
    bool listenToOnDataOnly = true,
  }) {
    final listener = (s) {
      if (listenToOnDataOnly) {
        if (hasData) {
          fn(s);
        }
      } else {
        fn(s);
      }
    };
    _listenToRMSet.add(listener);

    // final _isIdle = isIdle;
    // Future.microtask(() {
    //   if (!_isIdle) {
    //     observer.update();
    //   }
    // });
    return () {
      print('remove');
      _listenToRMSet.remove(listener);
      if (_listenToRMSet.isEmpty && !hasObservers) {
        statesRebuilderCleaner(this);
      }
    };
  }

  @override
  R whenConnectionState<R>({
    @required R Function() onIdle,
    @required R Function() onWaiting,
    @required R Function(T state) onData,
    @required R Function(dynamic error) onError,
    bool catchError = true,
  }) {
    if (!_whenConnectionState) {
      _whenConnectionState = catchError;
    }
    if (isIdle) {
      return onIdle?.call();
    }
    if (hasError) {
      return onError?.call(error);
    }
    if (isWaiting) {
      return onWaiting?.call();
    }
    return onData?.call(state);
  }

  bool _whenConnectionState = false;
  bool setStateHasOnErrorCallback = false;

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
  void resetToIdle([T s]) {
    snapshot = AsyncSnapshot.withData(ConnectionState.none, s ?? state);
  }

  @override
  void resetToHasData([T s]) {
    snapshot = AsyncSnapshot.withData(ConnectionState.done, s ?? state);
  }

  @override
  void resetToIsWaiting([T s]) {
    snapshot = AsyncSnapshot.withData(ConnectionState.waiting, s ?? state);
  }

  @override
  void resetToHasError(dynamic e) {
    snapshot = AsyncSnapshot.withError(ConnectionState.done, e);
  }

  @override
  dynamic get joinSingletonToNewData => _joinSingletonToNewData;
  Timer _debounceTimer;

  Completer<T> _completer;

  Future<T> get stateAsync {
    return _completer?.future?.catchError((e) => throw (e)) ??
        Future.value(_state);
  }

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
    bool skipWaiting = false,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context, T model) onData,
    dynamic Function() joinSingletonToNewData,
    bool joinSingleton = false,
    bool notifyAllReactiveInstances = false,
    bool silent = false,
  }) async {
    void Function(dynamic Function(T) fn) _setStateCallBack =
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
        _setStateCallBack(fn);
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
        (_) => _setStateCallBack(fn),
      );
      return;
    }
    dynamic watchBefore = watch?.call(state);
    bool _canRebuild() {
      if (watch == null) {
        return true;
      }
      bool canRebuild;
      dynamic watchAfter = watch?.call(state);
      canRebuild = !deepEquality.equals(watchAfter, watchBefore);

      watchBefore = watchAfter;
      return canRebuild;
    }

    final _onSetState = () {
      if (hasError) {
        if (onError != null) {
          onError(RM.context, error);
        } else {
          onErrorHandler?.call(RM.context, error);
        }
      }

      if (hasData) {
        onData?.call(RM.context, state);
        _onData?.call(state);
        if (notifyAllReactiveInstances == true) {
          _notifyAll();
        } else if (seeds != null) {
          for (var seed in seeds) {
            final rm = inject.newReactiveMapFromSeed['$seed'];
            rm?.rebuildStates();
          }
        }
      }

      onSetState?.call(RM.context);

      if (onRebuildState != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => onRebuildState(RM.context),
        );
      }
    };

    void _rebuildStates({bool canRebuild = true}) {
      if (_listenToRMSet.isNotEmpty) {
        setStateHasOnErrorCallback = onError != null;
        _listenToRMCall();
        setStateHasOnErrorCallback = false;
      }

      if ((silent || _listenToRMSet.isNotEmpty) && !hasObservers) {
        _onSetState();
        return;
      }

      if (canRebuild) {
        rebuildStates(
          filterTags,
          (_) => _onSetState(),
        );
        _joinSingleton(
          joinSingleton,
          joinSingletonToNewData,
        );
      }
    }

    void _onWaitingCallback() {
      if (skipWaiting) {
        return;
      }
      snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, state);
      _rebuildStates(canRebuild: _canRebuild());
    }

    bool _onDataCallback(dynamic data) {
      if (data is T) {
        if (!hasError &&
            !isWaiting &&
            deepEquality.equals(inject.getReactive().state, data)) {
          return false;
        }
        _addToUndoQueue();
        snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, data);
        (inject.reactiveSingleton as ReactiveModelImp<T>)?._state = _state;
        inject.singleton = _state;

        return true;
      }

      snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, _state);
      return true;
    }

    void _onErrorCallBack(dynamic e, StackTrace s) {
      snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
      stackTrace = s;
      _rebuildStates(canRebuild: true); //TODO
      bool _catchError = catchError ??
          false ||
              _whenConnectionState ||
              onError != null ||
              inject.hasOnSetStateListener ||
              onErrorHandler != null;
      _whenConnectionState = false;
      assert(() {
        if (RM.debugError || RM.debugErrorWithStackTrace) {
          developer.log(
            "This error ${_catchError ? 'is caught by' : 'is thrown from'} ReactiveModel<$T>:\n${_catchError ? '$e' : ''}",
            name: 'states_rebuilder::onError',
            error: _catchError ? null : e,
            stackTrace:
                _catchError ? RM.debugErrorWithStackTrace ? s : null : s,
          );
        }
        return true;
      }());

      if (_catchError == false) {
        RM.errorLog?.call(e, s);
        throw error;
      }
    }

    final Completer<T> completer = Completer<T>();
    _completer = completer;
    completer.future.catchError((d) => null);
    final Completer<T> _setStateCompleter = Completer<T>();

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
            completer.complete(state);
            if (isStateModified) {
              _rebuildStates(canRebuild: _canRebuild());
            }
          },
          onError: (dynamic e, StackTrace s) {
            completer.completeError(e, s);
            _onErrorCallBack(e, s);
          },
          onDone: () {
            _setStateCompleter.complete(state);
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
              _rebuildStates(canRebuild: _canRebuild());
            }
          },
          onError: (dynamic e, StackTrace s) {
            completer.completeError(e, s);
            _onErrorCallBack(e, s);
          },
          onDone: () {
            _setStateCompleter.complete(state);
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
          _rebuildStates(canRebuild: _canRebuild());
          _setStateCompleter.complete(state);
        }
      }
    } catch (e, s) {
      if (e is! FlutterError) {
        _setStateCompleter.complete(state);
        _onErrorCallBack(e, s);
      }
    }
    return _setStateCompleter.future;
  }

  @override
  ReactiveModel<S> stream<S>(
    Stream<S> Function(T s, StreamSubscription<dynamic> subscription) stream, {
    S initialValue,
    Object Function(S s) watch,
  }) {
    final s = inject.getReactive().state;

    if (S != dynamic && this is ReactiveModelImp<S>) {
      final rm = Inject<S>.stream(
        () => stream(s, subscription),
        initialValue: initialValue ?? s,
        watch: watch,
      ).getReactive();
      final disposer = rm.listenToRM(
        (r) {
          if (r.hasData) {
            snapshot = AsyncSnapshot<T>.withData(
              ConnectionState.done,
              r.state as T,
            );
            (inject.reactiveSingleton as ReactiveModelImp<T>)._state = _state;
            inject.singleton = _state;
          }
        },
      );
      rm.cleaner(() {
        disposer();
      });
      rm.inject.creationStreamFunction = () => stream(s, subscription);
      return rm;
    }

    return Inject<S>.stream(
      () => stream(s, subscription),
      initialValue: initialValue,
      watch: watch,
    ).getReactive();
  }

  @override
  ReactiveModel<F> future<F>(
    Future<F> Function(T f, Future<T> stateAsync) future, {
    F initialValue,
    int debounceDelay,
  }) {
    final s = inject.getReactive().state;

    if (F != dynamic && this is ReactiveModelImp<F>) {
      final rm = Inject<F>.future(
        () => future(s, stateAsync),
        initialValue: initialValue ?? s,
      ).getReactive();
      var disposer;
      disposer = rm.listenToRM(
        (r) {
          if (r.hasData) {
            if (r.state is! T) {
              disposer();
              return;
            }
            snapshot = AsyncSnapshot<T>.withData(
              ConnectionState.done,
              r.state as T,
            );
            (inject.reactiveSingleton as ReactiveModelImp<T>)._state = _state;
            inject.singleton = _state;
          }
        },
      );
      rm.cleaner(() {
        disposer();
      });
      return rm;
    }

    return Inject<F>.future(
      () => future(s, stateAsync),
      initialValue: initialValue,
    ).getReactive();
  }

  _joinSingleton(
    bool joinSingleton,
    dynamic Function() joinSingletonToNewData,
  ) {
    if (isNewReactiveInstance) {
      final reactiveSingleton = inject.getReactive() as ReactiveModelImp<T>;
      if (joinSingletonToNewData != null) {
        reactiveSingleton._joinSingletonToNewData = joinSingletonToNewData();
      }

      if (inject.joinSingleton == JoinSingleton.withNewReactiveInstance ||
          joinSingleton == true) {
        reactiveSingleton.snapshot = snapshot;
        if (reactiveSingleton.hasObservers) {
          reactiveSingleton.rebuildStates();
        }
      } else if (inject.joinSingleton ==
          JoinSingleton.withCombinedReactiveInstances) {
        reactiveSingleton.snapshot = _combinedSnapshotState;
        if (reactiveSingleton.hasObservers) {
          reactiveSingleton.rebuildStates();
        }
      }
    }
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
          stackTrace = (rm as ReactiveModelImp).stackTrace;
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
      if (rm.hasObservers) {
        rm.rebuildStates();
      }
    }
    final singletonRM = inject.getReactive();
    if (singletonRM.hasObservers) {
      singletonRM.rebuildStates();
    }
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
  String type([bool detailed = true]) {
    if (!detailed) {
      return '$T';
    }
    String type = inject.isAsyncInjected
        ? inject.isFutureType ? 'Future of ' : 'Stream of '
        : '';
    type += '<$T>';
    return type;
  }

  void notify([List<dynamic> tags]) {
    if (_listenToRMSet.isNotEmpty) {
      setStateHasOnErrorCallback = onError != null;
      _listenToRMCall();
      setStateHasOnErrorCallback = false;
    }
    if (hasObservers) {
      rebuildStates(tags);
    }
  }

  @override
  Future<T> refresh([bool shouldNotify = true]) {
    cleaner(unsubscribe, true);
    unsubscribe();
    if (inject.isAsyncInjected) {
      if (inject.isFutureType) {
        setState(
          (dynamic s) => inject.creationFutureFunction(),
          catchError: true,
          silent: true,
          filterTags: inject.filterTags,
        );
      } else {
        setState(
          (dynamic s) => inject.creationStreamFunction(),
          catchError: true,
          silent: true,
          filterTags: inject.filterTags,
        );
      }
    } else {
      resetToIdle();
      inject.singleton = inject.creationFunction();
      _state = inject.singleton;
      (inject.reactiveSingleton as ReactiveModelImp<T>)._state = _state;
      if (shouldNotify) {
        notify();
      }
    }
    return stateAsync;
  }

  final Set<BuildContext> _contextSet = {};

  void contextSubscription(BuildContext context) {
    if (_contextSet.add(context)) {
      if (!InjectorState.contextSet.contains(context)) {
        InjectorState.contextSet.add(context);
      }
      Disposer disposer;
      disposer = listenToRM(
        (rm) {
          if (context.findRenderObject()?.attached == true) {
            (context as Element).markNeedsBuild();
          } else {
            _contextSet.remove(context);
            InjectorState.contextSet.add(context);
            disposer();
          }
        },
        listenToOnDataOnly: false,
      );
    }
  }

  @override
  String toString() {
    String rm =
        '${type()} ${!isNewReactiveInstance ? 'RM' : 'RM (new seed: "$_seed")'}'
        ' (#Code $hashCode)';
    int num = 0;
    observers().forEach((key, value) {
      if (key != '_ReactiveModelSubscriber') {
        if (!'$value'.contains('$Injector')) {
          num++;
        }
      }
    });

    return '$rm | ${whenConnectionState<String>(
      onIdle: () => 'isIdle ($state)',
      onWaiting: () => 'isWaiting ($state)',
      onData: (data) => 'hasData : ($data)',
      onError: (dynamic e) => 'hasError : ($e)',
      catchError: false,
    )} | $num observing widgets';
  }

  final Queue<AsyncSnapshot<T>> _undoQueue = ListQueue();
  final Queue<AsyncSnapshot<T>> _redoQueue = ListQueue();
  int _undoStackLength = 0;
  @override
  bool get canRedoState => _redoQueue.isNotEmpty;

  @override
  bool get canUndoState => _undoQueue.isNotEmpty;

  @override
  void clearUndoStack() {
    _undoQueue.clear();
    _redoQueue.clear();
  }

  @override
  ReactiveModel<T> redoState() {
    if (!canRedoState) {
      return null;
    }
    _undoQueue.add(snapshot);
    final oldSnapShot = _redoQueue.removeLast();
    snapshot = oldSnapShot;
    _state = snapshot.data;
    notify();
    return this;
  }

  @override
  ReactiveModel<T> undoState() {
    if (!canUndoState) {
      return null;
    }
    _redoQueue.add(snapshot);
    final oldSnapShot = _undoQueue.removeLast();
    snapshot = oldSnapShot;
    _state = snapshot.data;
    notify();

    return this;
  }

  void _addToUndoQueue() {
    if (_undoStackLength < 1) {
      return;
    }
    _undoQueue.add(snapshot);
    _redoQueue.clear();

    if (_undoQueue.length > _undoStackLength) {
      _undoQueue.removeFirst();
    }
  }

  @override
  void set undoStackLength(int length) {
    _undoStackLength = length;
  }
}
