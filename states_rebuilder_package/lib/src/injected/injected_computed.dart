part of '../injected.dart';

///implementation of [Injected] for computed injection
class InjectedComputed<T> extends Injected<T> {
  final T _initialState;
  final bool Function(T s) _shouldCompute;
  final List<Injected<dynamic>> _asyncDependsOn;

  ///implementation of [Injected] for computed injection
  InjectedComputed({
    T Function(T s) compute,
    List<Injected<dynamic>> asyncDependsOn,
    Stream<T> Function(T s) computeAsync,
    bool autoDisposeWhenNotUsed = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    bool Function(T s) shouldCompute,
    T initialState,
    int undoStackLength,
    bool isLazy = true,
  })  : _initialState = initialState,
        _shouldCompute = shouldCompute,
        _asyncDependsOn = asyncDependsOn,
        assert(
          compute != null || computeAsync != null,
          'Define `compute` for sync computation or `computeAsync` for async computation',
        ),
        assert(
          compute == null || computeAsync == null,
          'You can not define both `compute` and `computeAsync`',
        ),
        assert(
          computeAsync == null && asyncDependsOn == null ||
              computeAsync != null && asyncDependsOn != null,
          'When using `computeAsync` you have to define `asyncDependsOn``',
        ),
        assert(
          asyncDependsOn == null || asyncDependsOn.isNotEmpty,
          'asyncDependsOn can not be null',
        ),
        super(
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          onData: onData,
          onError: onError,
          onWaiting: onWaiting,
          onInitialized: onInitialized,
          onDisposed: onDisposed,
          undoStackLength: undoStackLength,
        ) {
    if (_asyncDependsOn == null) {
      _creationFunction = () {
        if (_shouldCompute?.call(_rm?.state ?? _initialState) == false) {
          return _rm?.state ?? _initialState;
        }
        return compute(_rm?.state ?? _initialState);
      };
    } else {
      _creationFunction = () async* {
        if (_shouldCompute?.call(_rm?.state ?? _initialState) == false) {
          yield _rm?.state ?? _initialState;
        }
        yield* computeAsync(_rm?.state ?? _initialState);
      };
    }

    if (!isLazy) {
      _stateRM;
    }
  }
  @override
  String get _name => '___Injected${hashCode}Computed___';

  bool _isRegistered = false;
  @override
  ReactiveModel<T> get _stateRM {
    final rm = super._stateRM;
    if (_isRegistered) {
      return rm;
    }
    _isRegistered = true;
    if (_asyncDependsOn != null || _dependsOn.isNotEmpty) {
      for (var depend in _asyncDependsOn ?? _dependsOn) {
        final reactiveModel = depend._stateRM;
        if (rm.hasData || rm.isIdle) {
          if (reactiveModel.isWaiting) {
            rm.resetToIsWaiting();
          } else if (!reactiveModel.isWaiting && reactiveModel.hasError) {
            rm.resetToHasError(reactiveModel.error);
          }
        }
        final disposer = reactiveModel.listenToRM(
          (_) {
            ReactiveModel errorRM;
            for (var depend in _dependsOn) {
              final r = depend._stateRM;
              r.whenConnectionState(
                onIdle: null,
                onWaiting: null,
                onData: null,
                onError: (dynamic e) => errorRM = r,
                catchError: r.hasError,
              );
              if (r.isWaiting) {
                rm
                  ..resetToIsWaiting()
                  ..notify();
                return;
              }
            }

            if (errorRM != null) {
              rm
                ..resetToHasError(errorRM.error)
                ..notify();
              return;
            }
            rm.refresh();
          },
          listenToOnDataOnly: false,
        );
        rm.cleaner(disposer);
      }
    }
    return rm;
  }

  @override
  T get state {
    if (Injected._activeInjected?._dependsOn?.add(this) == true) {
      _numberODependence++;
    }
    //override to force calling rm getter
    return _stateRM.state;
  }

  @override
  void injectComputedMock({
    T Function(T s) compute,
    Stream<T> Function(T s) computeAsync,
    initialState,
  }) {
    assert(this is InjectedComputed<T>);
    _inject = null;
    if (_asyncDependsOn == null) {
      _creationFunction = () {
        final s = _rm?.state ?? initialState ?? _initialState;
        // if (_dependsOn?.isNotEmpty == true) {
        if (_shouldCompute?.call(s) == false) {
          return s;
        }
        return compute(s);
      };
    } else {
      _creationFunction = () async* {
        final s = _rm?.state ?? initialState ?? _initialState;
        if (_shouldCompute?.call(s) == false) {
          yield s;
        }
        yield* computeAsync(s);
      };
    }

    _cashedMockCreationFunction ??= _creationFunction;
  }

  @override
  Inject<T> _getInject() => _asyncDependsOn == null
      ? Inject<T>(
          _creationFunction as T Function(),
          name: _name,
          isLazy: false,
        )
      : Inject<T>.stream(
          _creationFunction as Stream<T> Function(),
          name: _name,
          isLazy: false,
          initialValue: _initialState,
        );

  @override
  void _dispose() {
    super._dispose();
    _dependsOn.clear();
    _isRegistered = false;
  }

  @override
  String toString() {
    return 'Computed : ${super.toString()}';
  }
}
