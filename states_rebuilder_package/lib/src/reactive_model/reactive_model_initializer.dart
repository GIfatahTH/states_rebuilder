part of '../reactive_model.dart';

abstract class ReactiveModelInitializer<T> extends ReactiveModelState<T> {
  bool _isAsyncReactiveModel = false;
  void Function(T s)? _onInitialized;
  // T get state => (this as ReactiveModel<T>).state;
  // SnapState<T> get snapState => _coreRM.snapState;
  // set snapState(SnapState<T> snap) => _coreRM.snapState = snap;
  bool isDone = false;

  void _initialize() {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    if (_initialState != null) {
      _nullState ??= _initialState;
    }

    if (this is Injected && !_isFirstInitialized) {
      (this as Injected)._setDependence();
    }
    if (_coreRM.snapState.isWaiting || _coreRM.snapState.hasError) {
      //Here is reached by dependent Injected models, that one of there
      //dependencies is waiting or has error while initialization.
      assert(!_isFirstInitialized);
      dynamic result;
      try {
        result = _creator(this as ReactiveModel<T>);
        if (result is Future) {
          result.asStream().listen((dynamic _) {}).cancel();
          //Skip Future ;
          throw Error();
        } else if (result is Stream) {
          result.listen((dynamic _) {}).cancel();
          //Skip  Stream;
          throw Error();
        }
      } catch (e) {
        result = null;
      }
      if (result != null) {
        _nullState ??= result as T;
        _coreRM.snapState = _coreRM.snapState.copyWith(data: result as T);
        _coreRM._middleState
            ?.call(SnapState._nothing('INITIALIZING'), _coreRM.snapState);
        _coreRM.addToUndoQueue();
      }
      _onInitState();
      _notifyListeners();
      _onInitialized?.call(_coreRM._state!);
      _isFirstInitialized = true;
      return;
    }
    try {
      final dynamic result = _creator(this as ReactiveModel<T>);

      Stream<T>? asyncResult;
      if (result is Future<T>) {
        asyncResult = result.asStream();
      } else if (result is Stream<T>) {
        _coreRM._cachedWatch = _coreRM._watch?.call(_state);
        asyncResult = result;
      }
      _isAsyncReactiveModel = asyncResult != null;
      if (_isAsyncReactiveModel) {
        _coreRM._setToIsWaiting();
        if (!_isFirstInitialized) {
          _onInitState();
        }

        _handleAsyncSubscription(
          asyncResult as Stream<T>,
          onErrorRefresher: () {
            _snapState = _snapState.copyWith(
              connectionState: ConnectionState.none,
              resetError: true,
            );
            _isInitialized = false;
            _initialConnectionState = ConnectionState.done;
            _initialize();
          },
          onInitData: (s) => _nullState ??= s,
        );

        if (!_isFirstInitialized) {
          _onInitialized?.call(_coreRM._state!);
          _isFirstInitialized = true;
        }
        return;
      }
      // Injected._activeInjected = cached;
      _nullState ??= result as T;
      _coreRM.snapState = SnapState<T>._withData(
        _initialConnectionState,
        result ?? _nullState,
        _coreRM.snapState.isImmutable,
      );
      _coreRM._middleState?.call(
          SnapState._nothing(
            _isFirstInitialized ? 'REFRESHING' : 'INITIALIZING',
          ),
          _coreRM.snapState);
      _coreRM.addToUndoQueue();
      if (_shouldPersistStateOnInit) {
        _coreRM.persistState();
      }
    } catch (e, s) {
      _coreRM._setToHasError(
        e,
        s,
        onErrorRefresher: () {
          _snapState = _snapState.copyWith(
            connectionState: ConnectionState.done,
            resetError: true,
          );
          _initialConnectionState = ConnectionState.done;
          _isInitialized = false;
          _initialize();
          _coreRM.notifyListeners();
        },
      );
    }
    if (!_isFirstInitialized) {
      _onInitState();
      if (_state != null) {
        _onInitialized?.call(_state!);
      }
      _isFirstInitialized = true;
    }
  }

  StreamSubscription<dynamic> _handleAsyncSubscription(
    Stream asyncResult, {
    required void Function() onErrorRefresher,
    On<void>? onSetState,
    void Function()? onRebuildState,
    void Function(dynamic? error)? onError,
    void Function(T data)? onData,
    //use to set _nullState if not defined when instantiating
    //a future or stream
    void Function(T data)? onInitData,
    BuildContext? context,
    void Function()? onDane,
  }) {
    _subscription?.cancel();
    _subscription = null;
    return _subscription = asyncResult.listen(
      (dynamic data) {
        if (data is T) {
          onInitData?.call(data);
        } else {
          onInitData?.call(_state!);
        }
        _coreRM._setToHasData(
          data,
          onData: onData,
          onSetState: onSetState,
          onRebuildState: onRebuildState,
          context: context,
        );
      },
      onError: (dynamic e, StackTrace s) {
        _coreRM._setToHasError(
          e,
          s,
          onErrorRefresher: onErrorRefresher,
          onSetState: onSetState,
          onError: onError,
          context: context,
        );
      },
      onDone: () {
        _coreRM._completeCompleter(_state);
        isDone = true;
        onDane?.call();
      },
      cancelOnError: false,
    );
  }

  void _onInitState() {}
}
