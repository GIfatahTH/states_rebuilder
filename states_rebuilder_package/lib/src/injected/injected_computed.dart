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
    _resolveDependencies(rm, (inj) => inj._stateRM);
    return rm;
  }

  @override
  T get state {
    final s = super.state;
    if (_isRegisteredComputed) {
      return s;
    }
    _isRegisteredComputed = true;
    _resolveDependencies(_rm);
    return s;
  }

  void _resolveDependencies(ReactiveModel computedRM,
      [ReactiveModel Function(Injected) getRM]) {
    if (_asyncDependsOn == null && _dependsOn.isEmpty) {
      return;
    }

    for (var depend in _asyncDependsOn ?? _dependsOn) {
      final reactiveModel = getRM?.call(depend) ?? depend._rm;
      //Initial status for the computed
      if (computedRM.hasData || computedRM.isIdle) {
        if (reactiveModel.isWaiting) {
          computedRM.resetToIsWaiting();
        } else if (reactiveModel.hasError) {
          computedRM.resetToHasError(reactiveModel.error);
        }
      }
      Disposer disposer;
      disposer = (reactiveModel as ReactiveModelInternal).listenToRMInternal(
        (_) {
          // final Injected<T> injected =
          //     _functionalInjectedModels[rm.inject.getName()] as Injected<T>;

          // final injected = computedRM;
          if (computedRM == null) {
            disposer();
            return;
          }
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
              computedRM
                ..resetToIsWaiting()
                ..notify();
              return;
            }
          }

          if (errorRM != null) {
            computedRM
              ..resetToHasError(errorRM.error)
              ..notify();
            return;
          }
          computedRM.refresh();
        },
        listenToOnDataOnly: false,
        isInjectedModel: true,
        debugListener: 'COMPUTED',
      );
      reactiveModel.cleaner(disposer);
      computedRM.cleaner(disposer);
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
        )
      : Inject<T>.stream(
          _creationFunction as Stream<T> Function(),
          name: _name,
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
