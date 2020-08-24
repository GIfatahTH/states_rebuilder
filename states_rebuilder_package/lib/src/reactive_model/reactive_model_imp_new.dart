part of '../reactive_model.dart';

class ReactiveModelImpNew<T> extends ReactiveModelImp<T> {
  ReactiveModelImpNew(Inject<T> inject) : super(inject);

  @override
  T get state {
    return inject.getSingleton();
  }

  @override
  ReactiveModel<T> asNew([dynamic seed = 'defaultReactiveSeed']) {
    return inject.getReactive().asNew(seed);
  }

  void _joinSingleton(
    bool joinSingleton,
    dynamic Function() joinSingletonToNewData,
  ) {
    final reactiveSingleton = inject.getReactive();
    if (joinSingletonToNewData != null) {
      reactiveSingleton._joinSingletonToNewData = joinSingletonToNewData();
    }

    if ((inject as InjectImp).joinSingleton ==
            JoinSingleton.withNewReactiveInstance ||
        joinSingleton == true) {
      reactiveSingleton.snapshot = snapshot;
      if (reactiveSingleton.hasObservers) {
        reactiveSingleton.rebuildStates();
      }
    } else if ((inject as InjectImp).joinSingleton ==
        JoinSingleton.withCombinedReactiveInstances) {
      reactiveSingleton.snapshot = _combinedSnapshotState;
      if (reactiveSingleton.hasObservers) {
        reactiveSingleton.rebuildStates();
      }
    }
  }

  String toString() {
    String rm = '${type()} RM (new seed: "$_seed")'
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
    BuildContext context,
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
        context: context,
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
      canRebuild = !_deepEquality.equals(watchAfter, watchBefore);

      watchBefore = watchAfter;
      return canRebuild;
    }

    final _onSetState = () {
      if (hasError) {
        if (onError != null) {
          onError(RM.context, error);
        } else {
          _onErrorHandler?.call(RM.context, error);
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
        _setStateHasOnErrorCallback = onError != null;
        _listenToRMCall();
        _setStateHasOnErrorCallback = false;
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
            _deepEquality.equals(inject.getReactive().state, data)) {
          return false;
        }
        _addToUndoQueue();
        snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, data);

        return true;
      }

      snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, _state);
      return true;
    }

    void _onErrorCallBack(dynamic e, StackTrace s) {
      snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
      _stackTrace = s;
      _rebuildStates(canRebuild: true); //TODO
      bool _catchError = catchError ??
          false ||
              _whenConnectionState ||
              onError != null ||
              inject.hasOnSetStateListener ||
              _onErrorHandler != null;
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

    if (context != null) {
      RM.context = context;
    }

    final Completer<T> completer = Completer<T>();
    _completer = completer;
    completer.future.catchError((dynamic d) => null);

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
            if (isStateModified) {
              _rebuildStates(canRebuild: _canRebuild());
            }
            completer.complete(state);
          },
          onError: (dynamic e, StackTrace s) {
            _onErrorCallBack(e, s);
            completer.completeError(e, s);
          },
          onDone: () {
            cleaner(unsubscribe, true);
            _setStateCompleter.complete(state);
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
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onError: (dynamic e, StackTrace s) {
            _onErrorCallBack(e, s);
            if (!completer.isCompleted) {
              completer.completeError(e, s);
            }
          },
          onDone: () {
            cleaner(unsubscribe, true);
            _setStateCompleter.complete(state);
            isStreamDone = true;
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
        }
        completer.complete();
        _setStateCompleter.complete(state);
      }
    } catch (e, s) {
      if (e is! FlutterError) {
        _onErrorCallBack(e, s);
        completer.completeError(e, s);
        _setStateCompleter.complete(state);
      }
    }
    return _setStateCompleter.future;
  }
}
