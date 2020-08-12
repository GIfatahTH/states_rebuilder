import 'dart:async';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';

import 'inject.dart';
import 'injector.dart';
import 'reactive_model.dart';
import 'reactive_model_imp.dart';
import 'state_builder.dart';
import 'when_connection_state.dart';
import 'when_rebuilder_or.dart';

abstract class Injected<T> {
  Function() _creationFunction;
  final bool _autoClean;
  final void Function(T s) _onData;
  final void Function(dynamic e, StackTrace s) _onError;
  final void Function() _onWaiting;
  final void Function(T s) _onDispose;

  String get _name => '___Inject${hashCode}ed___';

  Inject<T> _inject;
  dynamic Function() _cashedMockCreationFunction;

  Injected({
    bool autoClean = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onDispose,
  })  : _autoClean = autoClean,
        _onData = onData,
        _onError = onError,
        _onWaiting = onWaiting,
        _onDispose = onDispose;

  ReactiveModel<T> _rm;
  ReactiveModel<T> get rm {
    if (_rm != null) {
      return _rm;
    }
    ReactiveModel<T> rm =
        InjectorState.allRegisteredModelInApp[_name]?.first?.getReactive();

    if (rm != null) {
      return _rm = rm;
    }
    _inject ??= _getInject();
    _inject.isGlobal = true;
    assert(InjectorState.allRegisteredModelInApp[_name] == null);
    InjectorState.allRegisteredModelInApp[_name] = [_inject];
    rm = _inject.getReactive();
    if (_autoClean ?? true) {
      rm.cleaner(_unregisterInject);
    }
    if (_onWaiting != null || _onData != null || _onError != null) {
      rm.listenToRM(
        (rm) {
          rm.whenConnectionState<void>(
            onIdle: () => null,
            onWaiting: () => _onWaiting?.call(),
            onData: (s) => _onData?.call(s),
            onError: (e) {
              //if setState has error override this _onError
              if (!(rm as ReactiveModelImp).setStateHasOnErrorCallback) {
                _onError?.call(e, (rm as ReactiveModelImp).stackTrace);
              }
            },
            catchError: _onError != null,
          );
        },
        listenToOnDataOnly: false,
      );
    }
    //
    return rm;
  }

  T get state {
    InjectedComputed._activeDependsOnSet?.add(rm);
    return _rm?.state ?? (_inject ??= _getInject()).getSingleton();
  }

  set state(T s) {
    rm.state = s;
  }

  Future<T> get stateAsync {
    return rm.stateAsync;
  }

  Inject<T> _getInject();

  void _unregisterInject() {
    assert(InjectorState.allRegisteredModelInApp[_name] == null ||
        InjectorState.allRegisteredModelInApp[_name].length == 1);
    if (InjectorState.allRegisteredModelInApp.remove(_name) != null) {
      if (_inject.isAsyncInjected) {
        _inject.reactiveSingleton?.unsubscribe();
      }
      _onDispose?.call(rm.state);
      print('`$T` is disposed');
      if (this is InjectedComputed<T>) {
        print('set InjectedComputed<T>');
      }
      _inject
        ..removeAllReactiveNewInstance()
        ..cleanInject();
    }
    _rm = null;
    _inject = null;
    if (_cashedMockCreationFunction != null) {
      _creationFunction = _cashedMockCreationFunction;
    }
  }

  void injectMock(T Function() creationFunction) {
    assert(this is InjectedImp<T>);
  }

  void injectFutureMock(Future<T> Function() creationFunction) {
    assert(this is InjectedFuture<T>);
  }

  void injectStreamMock(Stream<T> Function() creationFunction) {
    assert(this is InjectedStream<T>);
  }

  void injectComputedMock({T Function(T s) compute, T initialState}) {
    assert(this is InjectedComputed<T>);
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
    bool silent = false,
  }) {
    return rm.setState(
      fn,
      catchError: catchError,
      watch: watch,
      filterTags: filterTags,
      seeds: seeds,
      shouldAwait: shouldAwait,
      debounceDelay: debounceDelay,
      throttleDelay: throttleDelay,
      skipWaiting: skipWaiting,
      onSetState: onSetState,
      onRebuildState: onRebuildState,
      onData: onData,
      onError: onError,
    );
  }

  Future<T> refresh([bool shouldNotify = true]) => rm.refresh(shouldNotify);
  void notify([List<dynamic> tags]) => rm.notify(tags);
  Widget rebuilder(
    Widget Function() builder, {
    void Function() initState,
    void Function() dispose,
    Key key,
  }) {
    return StateBuilder(
      key: key,
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      observe: () => rm,
      builder: (_, rm) => builder(),
    );
  }

  Widget whenRebuilder({
    @required Widget Function() onIdle,
    @required Widget Function() onWaiting,
    @required Widget Function() onData,
    @required Widget Function(dynamic) onError,
    void Function() initState,
    void Function() dispose,
    Key key,
  }) {
    return WhenRebuilder(
      key: key,
      observe: () => rm,
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      onIdle: () => onIdle(),
      onWaiting: () => onWaiting(),
      onError: (e) => onError(e),
      onData: (s) => onData(),
    );
  }

  Widget whenRebuilderOr({
    Widget Function() onIdle,
    Widget Function() onWaiting,
    Widget Function() onData,
    Widget Function(dynamic) onError,
    @required Widget Function() builder,
    void Function() initState,
    void Function() dispose,
    Key key,
  }) {
    return WhenRebuilderOr(
      key: key,
      observe: () => rm,
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      onIdle: onIdle == null ? null : () => onIdle(),
      onWaiting: onWaiting == null ? null : () => onWaiting(),
      onError: onError == null ? null : (e) => onError(e),
      onData: onData == null ? null : (s) => onData(),
      builder: (_, rm) => builder(),
    );
  }

  Widget futureBuilder<F>({
    @required Future<F> Function(T data, Future<T> asyncState) future,
    @required Widget Function() onWaiting,
    @required Widget Function(dynamic) onError,
    @required Widget Function(F data) onData,
    Key key,
  }) {
    return StateBuilder<F>(
      key: key,
      observe: () {
        return rm.future((s, stateAsync) {
          return future(s, stateAsync);
        });
      },
      initState: (_, __) =>
          (rm as ReactiveModelImp).numberOfFutureAndStreamBuilder++,
      dispose: (_, __) {
        (rm as ReactiveModelImp).numberOfFutureAndStreamBuilder--;
        if (!rm.hasObservers) {
          statesRebuilderCleaner(rm);
        }
      },
      onSetState: (_, rm) {
        if (rm.hasError) {
          //if setState has error override this _onError
          if (!(rm as ReactiveModelImp).setStateHasOnErrorCallback) {
            _onError?.call(rm.error, (rm as ReactiveModelImp).stackTrace);
          }
        }
      },
      builder: (_, rm) {
        if (rm.isWaiting) {
          return onWaiting == null ? onData(rm.state) : onWaiting();
        }

        if (rm.hasError) {
          return onError == null ? onData(rm.state) : onError(rm.error);
        }

        return onData(rm.state);
      },
    );
  }

  Widget streamBuilder<S>({
    @required Stream<S> Function(T s, StreamSubscription subscription) stream,
    @required Widget Function() onWaiting,
    @required Widget Function(dynamic) onError,
    @required Widget Function(S data) onData,
    Widget Function(S data) onDone,
    Key key,
  }) {
    return StateBuilder<S>(
      key: key,
      observe: () {
        return rm.stream((s, subscription) {
          return stream(s, subscription);
        });
      },
      initState: (_, __) =>
          (rm as ReactiveModelImp).numberOfFutureAndStreamBuilder++,
      dispose: (_, __) {
        (rm as ReactiveModelImp).numberOfFutureAndStreamBuilder--;
        if (!rm.hasObservers) {
          statesRebuilderCleaner(rm);
        }
      },
      onSetState: (_, rm) {
        if (rm.hasError) {
          //if setState has error override this _onError
          if (!(rm as ReactiveModelImp).setStateHasOnErrorCallback) {
            _onError?.call(rm.error, (rm as ReactiveModelImp).stackTrace);
          }
        }
      },
      builder: (_, rm) {
        if (rm.isWaiting) {
          return onWaiting == null ? onData(rm.state) : onWaiting();
        }

        if (rm.hasError) {
          return onError == null ? onData(rm.state) : onError(rm.error);
        }

        if ((rm as ReactiveModelImp).isStreamDone == true) {
          return onDone == null ? onData(rm.state) : onDone(rm.state);
        }
        return onData(rm.state);
      },
    );
  }

  @override
  String toString() {
    return rm?.toString();
  }
}

class InjectedImp<T> extends Injected<T> {
  InjectedImp(
    T Function() creationFunction, {
    bool autoClean = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onDispose,
  }) : super(
          autoClean: autoClean,
          onData: onData,
          onError: onError,
          onWaiting: onWaiting,
          onDispose: onDispose,
        ) {
    _creationFunction = creationFunction;
  }

  @override
  void injectMock(T Function() creationFunction) {
    super.injectMock(creationFunction);
    _unregisterInject();
    _inject = null;
    _creationFunction = creationFunction;
    _cashedMockCreationFunction ??= _creationFunction;
  }

  @override
  Inject<T> _getInject() => Inject(_creationFunction, name: _name);
}

class InjectedFuture<T> extends Injected<T> {
  final T _initialValue;

  InjectedFuture(
    Future<T> Function() creationFunction, {
    bool autoClean = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onDispose,
    bool isLazy = true,
    T initialValue,
  })  : _initialValue = initialValue,
        super(
          autoClean: autoClean,
          onData: onData,
          onError: onError,
          onWaiting: onWaiting,
          onDispose: onDispose,
        ) {
    _creationFunction = creationFunction;
    if (!isLazy) {
      rm;
    }
  }
  @override
  void injectFutureMock(Future<T> Function() creationFunction) {
    _unregisterInject();
    _inject = null;
    _creationFunction = creationFunction;
    _cashedMockCreationFunction ??= _creationFunction;
  }

  @override
  Inject<T> _getInject() => Inject.future(
        _creationFunction,
        name: _name,
        initialValue: _initialValue,
      );
}

class InjectedStream<T> extends Injected<T> {
  final T _initialValue;
  final Function(T) _watch;

  InjectedStream(
    Stream<T> Function() creationFunction, {
    bool autoClean = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onDispose,
    Function(T) watch,
    bool isLazy = true,
    T initialValue,
  })  : _initialValue = initialValue,
        _watch = watch,
        super(
          autoClean: autoClean,
          onData: onData,
          onError: onError,
          onWaiting: onWaiting,
          onDispose: onDispose,
        ) {
    _creationFunction = creationFunction;
    if (!isLazy) {
      rm;
    }
  }
  @override
  void injectStreamMock(Stream<T> Function() creationFunction) {
    assert(this is InjectedStream<T>);
    _unregisterInject();
    _inject = null;
    _creationFunction = creationFunction;
    _cashedMockCreationFunction ??= _creationFunction;
  }

  @override
  Inject<T> _getInject() => Inject.stream(
        _creationFunction,
        name: _name,
        initialValue: _initialValue,
        watch: _watch,
      );
}

class InjectedInterface<T> extends Injected<T> {
  final Map<dynamic, FutureOr<T> Function()> _impl;
  final T _initialValue;
  InjectedInterface(
    Map<dynamic, FutureOr<T> Function()> impl, {
    bool autoClean = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onDispose,
    T initialValue,
  })  : _impl = impl,
        _initialValue = initialValue,
        super(
          autoClean: autoClean,
          onData: onData,
          onError: onError,
          onWaiting: onWaiting,
          onDispose: onDispose,
        );
  static int _envMapLength;
  @override
  Inject<T> _getInject() {
    assert(Injector.env != null, '''
You are using [Inject.interface] constructor. You have to define the [Inject.env] before the [runApp] method
    ''');
    assert(_impl[Injector.env] != null, '''
There is no implementation for ${Injector.env} of $T interface
    ''');
    _envMapLength ??= _impl.length;
    assert(_impl.length == _envMapLength, '''
You must be consistent about the number of flavor environment you have.
you had $_envMapLength flavors and you are defining ${_impl.length} flavors.
    ''');

    final creationFunction = _impl[Injector.env];
    if (creationFunction is Future<T> Function()) {
      return Inject.future(
        creationFunction,
        name: _name,
        initialValue: _initialValue,
      );
    }
    return Inject(creationFunction, name: _name);
  }
}

class InjectedComputed<T> extends Injected<T> {
  final T _initialState;
  final bool Function(T s) _shouldCompute;
  final Set<ReactiveModel> _dependsOn = {};
  InjectedComputed(
    T Function(T s) compute, {
    bool autoClean = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onDispose,
    bool Function(T s) shouldCompute,
    T initialState,
  })  : _initialState = initialState,
        _shouldCompute = shouldCompute,
        super(
          autoClean: autoClean,
          onData: onData,
          onError: onError,
          onWaiting: onWaiting,
          onDispose: onDispose,
        ) {
    _creationFunction = () {
      if (_dependsOn?.isNotEmpty == true) {
        if (_shouldCompute?.call(_rm?.state ?? _initialState) == false) {
          return _rm?.state ?? _initialState;
        }
        return compute(_rm?.state ?? _initialState);
      }
      final cashedSet = _activeDependsOnSet;
      _activeDependsOnSet = _dependsOn;
      final fn = compute(_rm?.state ?? _initialState);
      _activeDependsOnSet = cashedSet;
      return fn;
    };
  }

  @override
  ReactiveModel<T> get rm {
    final rm = super.rm;
    if (_dependsOn.isNotEmpty) {
      for (var reactiveModel in _dependsOn) {
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
            for (var r in _dependsOn) {
              r.whenConnectionState(
                onIdle: null,
                onWaiting: null,
                onData: null,
                onError: (e) => errorRM = r,
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
            rm.setState(
              (s) => rm.inject.creationFunction(),
              silent: true,
            );
          },
          listenToOnDataOnly: false,
        );
        rm.cleaner(() {
          disposer();
        });
      }
    }
    return rm;
  }

  @override
  T get state {
    if (InjectedComputed._activeDependsOnSet?.add(rm) == true) {
      print(InjectedComputed._activeDependsOnSet);
    }
    return rm.state;
  }

  static Set<ReactiveModel> _activeDependsOnSet;
  @override
  void injectComputedMock({T Function(T s) compute, T initialState}) {
    assert(this is InjectedComputed<T>);
    final s = rm.state ?? initialState ?? _initialState;
    _unregisterInject();
    _inject = null;
    _creationFunction = () {
      if (_dependsOn?.isNotEmpty == true) {
        if (!_shouldCompute(s)) {
          return s;
        }
        return compute(s);
      }
      final cashedSet = InjectedComputed._activeDependsOnSet;
      InjectedComputed._activeDependsOnSet = _dependsOn;
      final fn = compute(s);
      InjectedComputed._activeDependsOnSet = cashedSet;
      return fn;
    };
    _cashedMockCreationFunction ??= _creationFunction;
  }

  @override
  Inject<T> _getInject() => Inject<T>(_creationFunction, name: _name);

  @override
  void _unregisterInject() {
    super._unregisterInject();
    _dependsOn.clear();
  }

  @override
  String toString() {
    return 'Computed : ' + super.toString();
  }
}
