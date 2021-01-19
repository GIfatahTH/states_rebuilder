part of '../reactive_model.dart';

abstract class ReactiveModelInitializer<T> extends ReactiveModelState<T> {
  bool _isAsyncReactiveModel = false;
  void Function(T s)? _onInitialized;
  T get state => (this as ReactiveModel<T>).state;
  SnapState<T> get snapState => _coreRM.snapState;
  set snapState(SnapState<T> snap) => _coreRM.snapState = snap;
  Object? Function(T? s)? _watch;
  Object? _cachedWatch;
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
    if (snapState.isWaiting || snapState.hasError) {
      //Here is reached by dependent Injected models, that one of there
      //dependencies is waiting or has error while initialization.
      assert(!_isFirstInitialized);
      var result;
      try {
        result = _creator(this as ReactiveModel<T>);
        if (result is Future) {
          result.asStream().listen((_) {}).cancel();
          //Skip Future ;
          throw Error();
        } else if (result is Stream) {
          result.listen((_) {}).cancel();
          //Skip  Stream;
          throw Error();
        }
      } catch (e) {
        result = null;
      }
      if (result != null) {
        _nullState ??= result;
        snapState = snapState._copyWith(data: result);
        _coreRM.addToUndoQueue();
        // if (_coreRM.persistanceProvider != null &&
        //     !_isStateInitiallyPersisted) {
        //   _coreRM.persistState();
        // }
      }
      _onInitState();
      _notifyListeners();
      _onInitialized?.call(state);
      _isFirstInitialized = true;
      return;
    }

    final result = _creator(this as ReactiveModel<T>);

    Stream<T>? asyncResult;
    if (result is Future<T>) {
      asyncResult = result.asStream();
    } else if (result is Stream<T>) {
      _cachedWatch = _watch?.call(_state);
      asyncResult = result;
    }
    _isAsyncReactiveModel = asyncResult != null;
    if (_isAsyncReactiveModel) {
      if (!_isFirstInitialized) {
        _onInitState();
      }
      _snapState = SnapState._waiting(_state);
      _completer = Completer<dynamic>();
      _notifyListeners();
      _handleAsyncSubscription(
        asyncResult as Stream<T>,
        onInitData: (s) => _nullState ??= s,
      );

      if (!_isFirstInitialized) {
        _onInitialized?.call(state);
        _isFirstInitialized = true;
      }
      return;
    }
    // Injected._activeInjected = cached;
    _nullState ??= result;
    snapState = SnapState<T>._withData(
      _initialConnectionState,
      result,
      snapState.isImmutable,
    );
    _coreRM.addToUndoQueue();
    if (_coreRM.persistanceProvider != null && !_isStateInitiallyPersisted) {
      _coreRM.persistState();
    }
    if (!_isFirstInitialized) {
      _onInitState();
      _onInitialized?.call(state);
      _isFirstInitialized = true;
    }
  }

  StreamSubscription<dynamic> _handleAsyncSubscription(
    Stream asyncResult, {
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
      (data) {
        if (_watch != null &&
            deepEquality.equals(_cachedWatch, _cachedWatch = _watch!(data))) {
          return;
        }
        onInitData?.call(data);
        _coreRM._setToHasData(
          data,
          onData: onData,
          onSetState: onSetState,
          onRebuildState: onRebuildState,
          context: context,
        );
      },
      onError: (e, s) {
        _coreRM._setToHasError(
          e,
          s,
          onSetState: onSetState,
          onError: onError,
          context: context,
        );
      },
      onDone: () {
        if (_completer?.isCompleted == false) {
          _completer?.complete(_state);
        }
        isDone = true;
        onDane?.call();
      },
      cancelOnError: false,
    );
  }

  void _onInitState() {}
}
