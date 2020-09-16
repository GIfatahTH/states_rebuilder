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
    String debugPrintWhenNotifiedPreMessage,
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
        // assert(
        //   asyncDependsOn != null,
        //   'asyncDependsOn can not be null',
        // ),
        super(
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          onData: onData,
          onError: onError,
          onWaiting: onWaiting,
          onInitialized: onInitialized,
          onDisposed: onDisposed,
          undoStackLength: undoStackLength,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
        ) {
    _name = '___Injected${hashCode}Computed___';
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

  bool _isRegisteredComputed = false;
  @override
  ReactiveModel<T> get _stateRM {
    final rm = super._stateRM;
    if (_isRegisteredComputed) {
      return rm;
    }
    _isRegisteredComputed = true;
    if (_asyncDependsOn != null || _dependsOn.isNotEmpty) {
      for (var depend in _asyncDependsOn ?? _dependsOn) {
        final reactiveModel = depend._stateRM;
        //Initial status for the computed
        if (rm.hasData || rm.isIdle) {
          if (reactiveModel.isWaiting) {
            rm.resetToIsWaiting();
          } else if (reactiveModel.hasError) {
            rm.resetToHasError(reactiveModel.error);
          }
        }
        Disposer disposer;
        disposer = (reactiveModel as ReactiveModelInternal).listenToRMInternal(
          (_) {
            final Injected<T> injected =
                _functionalInjectedModels[rm.inject.getName()] as Injected<T>;
            if (injected == null) {
              disposer();
              return;
            }
            ReactiveModel errorRM;
            for (var depend in injected._dependsOn) {
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
          isInjectedModel: true,
        );
        rm.cleaner(disposer);
      }
    }

    _clearDependence ??= (_asyncDependsOn ?? _dependsOn).isEmpty
        ? null
        : () {
            for (var depend in (_asyncDependsOn ?? _dependsOn)) {
              depend._numberODependence--;
              if (depend._rm?.hasObservers != true &&
                  depend._numberODependence < 1) {
                depend.dispose();
              }
            }
          };

    return rm;
  }

  @override
  void injectComputedMock({
    T Function(T s) compute,
    Stream<T> Function(T s) computeAsync,
    initialState,
  }) {
    super.injectComputedMock();

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
    _isRegisteredComputed = false;
  }

  @override
  void _cloneTo(Injected<T> to) {
    super._cloneTo(to);
    (to as InjectedComputed)._isRegisteredComputed = _isRegisteredComputed;
  }

  @override
  String toString() {
    return 'Computed ${super.toString()} depends on ${(_asyncDependsOn ?? _dependsOn?.length ?? 0)} models';
  }
}
