part of '../rm.dart';

///Class that encapsulate the state (snapState), its creation, initialization and mutation
class ReactiveModelBase<T> {
  ReactiveModelBase({
    required this.creator,
    required this.initializer,
    T? initialState,
    required this.autoDisposeWhenNotUsed,
    this.debugPrintWhenNotifiedPreMessage,
  }) {
    //Set initial state on construction
    if (initialState != null) {
      _initialState = initialState;
    }

    // else if (null is! T) {
    //   final resolvedInitialState = _getPrimitiveNullState<T>();
    //   if (resolvedInitialState != null) {
    //     _initialState = resolvedInitialState;
    //   }
    // }
    //If the initial state is not be defined in the here,
    //it will be defined in the creator method.(The first valid value (onData))

    __snapState = _oldSnapState = SnapState._nothing(
      _initialState,
      kInitMessage,
      debugPrintWhenNotifiedPreMessage,
    );
  }

  ///The creator of the state
  dynamic Function() creator;

  ///The initializer of the state, called lazily when the state is first used or
  ///on state construction if isLazy is false.
  final VoidCallback initializer;
  final bool autoDisposeWhenNotUsed;

  late SnapState<T> __snapState;
  SnapState<T> get _snapState {
    return __snapState;
  }

  set _snapState(SnapState<T> snap) {
    if (snap != __snapState) {
      _oldSnapState = __snapState;
    }
    __snapState = snap;
  }

  late SnapState<T> _oldSnapState;

  VoidCallback? _removeFromInjectedList;

  ///Snap representation fo the state
  SnapState<T> get snapState {
    initializer(); //state is initialized when getting the snapState
    return _snapState;
  }

  ///Set the snapState and notify listeners
  set setSnapStateAndRebuild(SnapState<T>? snap) {
    _completeCompleter(snap ?? _snapState);
    if (snap == null) {
      //when the state is creating, or snapState is not changed
      return;
    }
    _snapState = snap;
    listeners.rebuildState(snap);
  }

  ///Async image of the state
  Future<SnapState<T>> get snapStateAsync async {
    initializer();
    if (_completer != null) {
      await _completer!.future;
      assert(!_snapState.isWaiting);
    }
    if (_snapState.hasError) {
      final future = Completer<SnapState<T>>();
      future.completeError(_snapState.error, _snapState.stackTrace);
      return future.future;
    }
    return _snapState;
  }

  T? _initialState;
  bool _isInitialized = false;
  bool _isDisposed = true;

  ///It is not null while the state is mutated asynchronously.
  StreamSubscription? subscription;
  Completer? _completer;
  Completer<dynamic>? _endStreamCompleter;

  ///SnapState listeners
  late final listeners = ReactiveModelListener<T>();
  final String? debugPrintWhenNotifiedPreMessage;

  ///Used to refresh the state
  Future<SnapState<T>> Function()? _initialStateCreator;

  ///Set the creator of the state
  void _setInitialStateCreator({
    required dynamic Function(dynamic Function()) middleCreator,
    required SnapState<T>? Function(SnapState<T> snap) middleState,
    required SnapState<T>? Function(SnapState<T> snap) onDone,
  }) {
    _initialStateCreator = () {
      final cachedAddToObs = OnReactiveState.addToObs;
      OnReactiveState.addToObs = null;
      final r = setStateFn(
        (_) => middleCreator(creator),
        middleState: middleState,
        onDone: onDone,
      )();
      OnReactiveState.addToObs = cachedAddToObs;
      return r;
    };
  }

  void _cancelSubscription() {
    subscription?.cancel();
    subscription = null;
    if (_completer?.isCompleted == false) {
      _completer!.complete();
    }
    _completer = null;
  }

  void _initCompleter() {
    if (_completer?.isCompleted == false) {
      _completer!.complete();
    }
    _completer = null;
    _completer = Completer();
  }

  void _completeCompleter(SnapState<T>? snap) {
    if (snap == null) {
      return;
    }
    if (snap.isWaiting) {
      _initCompleter();
    } else if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete();
    }
  }

  ///Mutate the state
  Future<SnapState<T>> Function() setStateFn(
    dynamic Function(T? state) fn, {
    required SnapState<T>? Function(SnapState<T> snap) middleState,
    required SnapState<T>? Function(SnapState<T> snap) onDone,
    String? debugMessage,
  }) {
    late Future<SnapState<T>> Function() call;
    call = () async {
      try {
        var _stream;
        dynamic result = fn(snapState.data);
        if (result is Future) {
          _stream = result.asStream();
        } else if (result is Stream) {
          _stream = result;
        }
        if (_stream != null) {
          final dataFuture = _streamSubscription(
            _stream!,
            middleState,
            () => call(), //used for refresh
          );
          if (!_snapState.isWaiting) {
            setSnapStateAndRebuild = middleState(
              _snapState._copyToIsWaiting(
                infoMessage:
                    debugMessage ?? (result is Future ? kFuture : kStream),
              ),
            );
          }

          final data = await dataFuture;
          if (data is Stream) {
            return setStateFn(
              (state) => data,
              middleState: middleState,
              onDone: onDone,
            )();
          }

          _snapState = onDone(_snapState.copyToIsDone()) ?? _snapState;

          return _snapState;
        }
        assert(
          result == null || result is T,
          'Type mismatch of the state: $result is not $T',
        );
        setSnapStateAndRebuild = middleState(
          _snapState._copyToHasData(result),
        );

        return _snapState;
      } catch (err, s) {
        if (err is Error) {
          //Error are not supposed to be captured and handled
          StatesRebuilerLogger.log('', err, s);
          rethrow;
        }
        //In the other hand Exception are handled
        setSnapStateAndRebuild = middleState(
          _snapState._copyToHasError(
            err,
            () => call(),
            stackTrace: s,
          ),
        );

        return _snapState;
      }
    };

    return call;
  }

  Future<dynamic> _streamSubscription(
    Stream stream,
    SnapState<T>? Function(SnapState<T> snap) middleState,
    VoidCallback refresher,
  ) {
    if (!_snapState.isWaiting) {
      if (_endStreamCompleter?.isCompleted == false) {
        _endStreamCompleter!.complete();
      }
    }
    _endStreamCompleter = Completer<dynamic>();
    subscription?.cancel();
    subscription = null;
    subscription = stream.listen(
      (data) {
        if (data is Stream) {
          subscription!.cancel();
          if (_endStreamCompleter?.isCompleted == false) {
            _endStreamCompleter?.complete(data);
          }
        } else {
          setSnapStateAndRebuild = middleState(
            _snapState._copyToHasData(data),
          );
        }
      },
      onError: (err, s) {
        if (err is Error) {
          //Error are not supposed to be captured and handled
          throw err;
        }
        //In the other hand Exception are handled
        setSnapStateAndRebuild = middleState(
          _snapState._copyToHasError(
            err,
            refresher,
            stackTrace: s,
          ),
        );
        if (_endStreamCompleter?.isCompleted == false) {
          _endStreamCompleter?.complete();
        }
      },
      onDone: () {
        if (_endStreamCompleter?.isCompleted == false) {
          _endStreamCompleter?.complete();
        }
      },
    );

    return _endStreamCompleter!.future;
  }

  ///Refresh the state
  void _refresh({String? infoMessage}) {
    if (!_isInitialized) {
      //If refresh is called in non initialized state
      //then just initialize it and return
      initializer();
      return;
    }

    _cancelSubscription();

    _snapState = infoMessage == kRecomputing
        ? _snapState.copyWith(infoMessage: kRecomputing)
        : _snapState._copyToIsIdle(
            infoMessage: infoMessage ?? kRefreshMessage,
          );

    _initialStateCreator?.call();
  }

  ///Dispose the state
  void dispose() {
    _isDisposed = true;
    if (_endStreamCompleter != null &&
        _endStreamCompleter!.isCompleted == false) {
      _endStreamCompleter!.complete();
    }

    _cancelSubscription();
    _isInitialized = false;
    _snapState = SnapState._nothing(
      _initialState,
      kInitMessage,
      debugPrintWhenNotifiedPreMessage,
    );
    listeners.cleanState();
  }
}

void resetReactiveModelBase(ReactiveModelBase rm) {
  rm._isInitialized = false;
}

T? _getPrimitiveNullState<T>() {
  if (T == int) {
    return 0 as T;
  }
  if (T == double) {
    return 0.0 as T;
  }
  if (T == String) {
    return '' as T;
  }
  if (T == bool) {
    return false as T;
  }
  return null;
}
