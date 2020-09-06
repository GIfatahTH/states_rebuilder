part of '../reactive_model.dart';

class _SetState<T> {
  final ReactiveModel<T> rm;
  final Function(T s) fn;
  final bool catchError;
  final Object Function(T state) watch;
  final List<dynamic> filterTags;
  final List<dynamic> seeds;
  final bool shouldAwait;
  int debounceDelay;
  int throttleDelay;
  final bool skipWaiting;
  final void Function(BuildContext context) onSetState;
  final void Function(BuildContext context) onRebuildState;
  final void Function(BuildContext context, dynamic error) onError;
  final void Function(BuildContext context, T model) onData;
  final dynamic Function() joinSingletonToNewData;
  final bool joinSingleton;
  final bool notifyAllReactiveInstances;
  bool silent;
  final BuildContext context;

  final Completer<T> completer = Completer<T>();
  final Completer<T> _setStateCompleter = Completer<T>();

  _SetState(
    this.fn, {
    @required this.rm,
    this.catchError,
    this.watch,
    this.filterTags,
    this.seeds,
    this.shouldAwait = false,
    this.debounceDelay,
    this.throttleDelay,
    this.skipWaiting = false,
    this.onSetState,
    this.onRebuildState,
    this.onError,
    this.onData,
    this.joinSingletonToNewData,
    this.joinSingleton = false,
    this.notifyAllReactiveInstances = false,
    this.silent = false,
    this.context,
  }) {
    watchBefore = watch?.call(rm.state);
  }

  dynamic watchBefore;
  bool _canRebuild() {
    if (watch == null) {
      return true;
    }
    bool canRebuild;
    dynamic watchAfter = watch?.call(rm.state);
    canRebuild = !_deepEquality.equals(watchAfter, watchBefore);

    watchBefore = watchAfter;
    return canRebuild;
  }

  void _onSetState() {
    if (rm.hasError) {
      if (onError != null) {
        onError(RM.context, rm.error);
      } else {
        rm._onErrorHandler?.call(RM.context, rm.error);
      }
    }

    if (rm.hasData) {
      onData?.call(RM.context, rm.state);
      rm._onData?.call(rm.state);
      if (notifyAllReactiveInstances == true) {
        rm._notifyAll();
      } else if (seeds != null) {
        for (var seed in seeds) {
          final _rm = rm.inject.newReactiveMapFromSeed['$seed'];
          _rm?.rebuildStates();
        }
      }
    }

    onSetState?.call(RM.context);

    if (onRebuildState != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => onRebuildState(RM.context),
      );
    }
  }

  void rebuildStates({bool canRebuild = true}) {
    if (context != null) {
      RM.context = context;
    }
    if (rm._listenToRMSet.isNotEmpty) {
      rm
        .._setStateHasOnErrorCallback = onError != null
        .._listenToRMCall()
        .._setStateHasOnErrorCallback = false;
    }

    if ((silent || rm._listenToRMSet.isNotEmpty) && !rm.hasObservers) {
      _onSetState();
      return;
    }

    if (canRebuild) {
      rm
        ..rebuildStates(
          filterTags,
          (_) => _onSetState(),
        )
        .._joinSingleton(
          joinSingleton,
          joinSingletonToNewData,
        );
    }
  }

  void onWaitingCallback() {
    if (skipWaiting) {
      return;
    }
    rm.snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, rm.state);
    rebuildStates(canRebuild: _canRebuild());
  }

  bool onDataCallback(dynamic data) {
    if (data is T) {
      if (!rm.hasError &&
          !rm.isWaiting &&
          _deepEquality.equals(rm.inject.getReactive().state, data)) {
        return false;
      }
      rm
        .._addToUndoQueue()
        ..snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, data);

      return true;
    }

    rm.snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, rm._state);
    return true;
  }

  void onErrorCallBack(dynamic e, StackTrace s) {
    rm
      ..snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e)
      .._stackTrace = s;
    rebuildStates(canRebuild: true);
    bool _catchError = catchError ??
        false ||
            rm._whenConnectionState ||
            onError != null ||
            rm.inject.hasOnSetStateListener ||
            rm._onErrorHandler != null;
    rm._whenConnectionState = false;

    assert(() {
      if (RM.debugError || RM.debugErrorWithStackTrace) {
        developer.log(
          "This error ${_catchError ? 'is caught by' : 'is thrown from'} ReactiveModel<$T>:\n${_catchError ? '$e' : ''}",
          name: 'states_rebuilder::onError',
          error: _catchError ? null : e,
          stackTrace: _catchError ? RM.debugErrorWithStackTrace ? s : null : s,
        );
      }
      return true;
    }());

    if (_catchError == false) {
      RM.errorLog?.call(e, s);
      throw rm.error;
    }
  }

  Future<T> call() async {
    if (debounceDelay != null) {
      rm._debounceTimer?.cancel();
      rm._debounceTimer = Timer(Duration(milliseconds: debounceDelay), () {
        debounceDelay = null;
        call();
        rm._debounceTimer = null;
      });
      return null;
    } else if (throttleDelay != null) {
      if (rm._debounceTimer != null) {
        return null;
      }
      rm._debounceTimer = Timer(Duration(milliseconds: throttleDelay), () {
        rm._debounceTimer = null;
      });
    } else if (shouldAwait) {
      rm.stateAsync.then(
        (_) => _setStateHandler(),
      );
      return null;
    }

    return _setStateHandler();
  }

  Future<T> _setStateHandler() {
    rm._completer = completer;
    completer.future.catchError((dynamic d) => null);

    try {
      if (fn == null) {
        rm.snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, rm.state);
        rebuildStates(canRebuild: true);
        return null;
      }
      final dynamic _result = fn(rm.state) as dynamic;

      if (_result is Future) {
        _futureHandler(_result);
      } else if (_result is Stream) {
        _streamHandler(_result);
      } else {
        _syncHandler(_result);
      }
    } catch (e, s) {
      if (e is! FlutterError) {
        onErrorCallBack(e, s);
        completer.completeError(e, s);
        _setStateCompleter.complete(rm.state);
      }
    }
    return _setStateCompleter.future;
  }

  void _syncHandler(dynamic _result) {
    if (onDataCallback(_result)) {
      rebuildStates(canRebuild: _canRebuild());
    }
    completer.complete();
    _setStateCompleter.complete(rm.state);
  }

  void _futureHandler(Future<dynamic> _result) {
    silent = true;
    rm
      ..subscription = Stream<dynamic>.fromFuture(_result).listen(
        (dynamic d) {
          final isStateModified = onDataCallback(d);
          if (isStateModified) {
            rebuildStates(canRebuild: _canRebuild());
          }
          completer.complete(rm.state);
        },
        onError: (dynamic e, StackTrace s) {
          onErrorCallBack(e, s);
          completer.completeError(e, s);
        },
        onDone: () {
          rm.cleaner(rm.unsubscribe, true);
          _setStateCompleter.complete(rm.state);
        },
      )
      ..cleaner(rm.unsubscribe);
    onWaitingCallback();
  }

  void _streamHandler(Stream<dynamic> _result) {
    silent = true;
    rm.subscription = _result.listen(
      (dynamic d) {
        if (onDataCallback(d)) {
          rebuildStates(canRebuild: _canRebuild());
        }
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (dynamic e, StackTrace s) {
        onErrorCallBack(e, s);
        if (!completer.isCompleted) {
          completer.completeError(e, s);
        }
      },
      onDone: () {
        rm.cleaner(rm.unsubscribe, true);
        _setStateCompleter.complete(rm.state);
        rm.isStreamDone = true;
      },
      cancelOnError: false,
    );
    if (!rm._isGlobal) {
      rm.cleaner(rm.unsubscribe);
    }
    onWaitingCallback();
  }

  @override
  String toString() {
    return '$rm';
  }
}
