import 'dart:async';

import 'package:flutter/widgets.dart';

import 'inject.dart';
import 'reactive_model.dart';
import 'reactive_model_imp.dart';
import 'states_rebuilder.dart';

///ReactiveModel Key
class RMKey<T> implements ReactiveModel<T> {
  ///ReactiveModel Key
  RMKey([this.initialValue]) {
    _rmInitial = RM.create<T>(initialValue);
    _rm = _rmInitial as ReactiveModelImp<T>;
  }
  ReactiveModel<T> _rmInitial;
  ReactiveModelImp<T> _rm;

  ///ReactiveModel associated with this key
  ReactiveModelImp<T> get rm => _rm;

  ///initial value
  T initialValue;

  ///is this key associated with a ReactiveModel or not
  bool get isLinked => _rm != _rmInitial;
  set rm(ReactiveModel<T> rm) {
    if (rm == null || rm == _rm) {
      return;
    }

    for (var fn in initCallBack) {
      fn(rm);
    }

    _rm = rm as ReactiveModelImp<T>;
    _rmInitial = null;
    initialValue = null;
    _rm.cleaner(unsubscribe);
  }

  ///cashed refresh callback
  void Function(ReactiveModel rm) refreshCallBack;

  ///Initialization callback
  Set<void Function(ReactiveModel rm)> initCallBack = {};

  ///refresh (reset to initial value) of the ReactiveModel associate with this RMKey
  ///and notify observing widgets.
  Future<T> refresh() {
    refreshCallBack?.call(_rm);
    if (!rm.inject.isAsyncInjected) {
      rm.setState((_) => null);
    } else {
      rm.rebuildStates();
    }
    return valueAsync;
  }

  @override
  T get state {
    assert(rm != null);
    return _rm?.state;
  }

  @override
  T get value => _rm?.value;
  @override
  set value(T data) {
    assert(_rm != null);
    _rm.value = data;
  }

  @override
  Future<void> setValue(
    FutureOr<T> Function() fn, {
    List<dynamic> filterTags,
    List<dynamic> seeds,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context, T data) onData,
    bool catchError = false,
    bool notifyAllReactiveInstances = false,
    bool joinSingleton,
    bool silent = false,
  }) async {
    assert(rm != null);
    return _rm?.setValue(
      fn,
      filterTags: filterTags,
      seeds: seeds,
      onSetState: onSetState,
      onRebuildState: onRebuildState,
      onData: onData,
      onError: onError,
      catchError: catchError,
      notifyAllReactiveInstances: notifyAllReactiveInstances,
      joinSingleton: joinSingleton,
      silent: silent,
    );
  }

  @override
  void addObserver({ObserverOfStatesRebuilder observer, String tag}) {
    _rm?.addObserver(observer: observer, tag: tag);
  }

  @override
  void cleaner(VoidCallback voidCallback, [bool remove = false]) {
    _rm?.cleaner(voidCallback, remove);
  }

  @override
  bool get hasObservers => _rm?.hasObservers;

  @override
  Map<String, Set<ObserverOfStatesRebuilder>> observers() {
    return _rm?.observers();
  }

  @override
  void rebuildStates([List tags, void Function(BuildContext) onSetState]) {
    _rm?.rebuildStates(tags, onSetState);
  }

  @override
  void removeObserver({ObserverOfStatesRebuilder observer, String tag}) {
    _rm?.removeObserver(observer: observer, tag: tag);
  }

  @override
  dynamic get error => _rm?.error;

  @override
  bool get hasData => _rm?.hasData;

  @override
  bool get hasError => _rm?.hasError;

  @override
  bool get isIdle => _rm?.isIdle;

  @override
  bool get isWaiting => _rm?.isWaiting;

  @override
  dynamic get joinSingletonToNewData => _rm?.joinSingletonToNewData;

  @override
  void resetToHasData() {
    _rm?.resetToHasData();
  }

  @override
  void resetToIdle() {
    _rm?.resetToIdle();
  }

  @override
  Future<void> setState(
    Function(T) fn, {
    bool catchError,
    Object Function(T state) watch,
    List<dynamic> filterTags,
    List<dynamic> seeds,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context, T model) onData,
    dynamic Function() joinSingletonToNewData,
    bool joinSingleton = false,
    bool notifyAllReactiveInstances = false,
    bool setValue = false,
    bool silent = false,
  }) async {
    return _rm?.setState(
      fn,
      catchError: catchError,
      watch: watch,
      filterTags: filterTags,
      seeds: seeds,
      onSetState: onSetState,
      onRebuildState: onRebuildState,
      onError: onError,
      onData: onData,
      joinSingletonToNewData: joinSingletonToNewData,
      joinSingleton: joinSingleton,
      notifyAllReactiveInstances: notifyAllReactiveInstances,
      setValue: setValue,
    );
  }

  @override
  StreamSubscription<dynamic> get subscription => _rm?.subscription;

  @override
  String toString() {
    return '$_rm';
  }

  @override
  R whenConnectionState<R>({
    @required R Function() onIdle,
    @required R Function() onWaiting,
    @required R Function(T state) onData,
    @required R Function(dynamic error) onError,
    bool catchError = true,
  }) {
    return _rm?.whenConnectionState(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onData: onData,
      onError: onError,
    );
  }

  @override
  AsyncSnapshot<T> snapshot;

  @override
  ReactiveModel<T> asNew([dynamic seed = 'defaultReactiveSeed']) {
    return _rm?.asNew(seed);
  }

  @override
  ConnectionState get connectionState => _rm?.connectionState;

  @override
  bool isA<T>() => rm.isA<T>();

  @override
  void copy(StatesRebuilder sb, [bool clear = true]) {
    _rm.copy(sb, clear);
  }

  @override
  ReactiveModel<T> future<S>(
    Future<S> Function(T) future, {
    T initialValue,
    bool wait = false,
  }) {
    return _rm.future(
      future,
      initialValue: initialValue,
      wait: wait,
    );
  }

  @override
  ReactiveModel<T> stream<S>(Stream<S> Function(T) stream, {T initialValue}) {
    return _rm.stream(stream, initialValue: initialValue);
  }

  @override
  void onError(
      void Function(BuildContext context, dynamic error) errorHandler) {
    _rm.onError(errorHandler);
  }

  @override
  void onData(void Function(T data) fn) {
    _rm.onData(fn);
  }

  @override
  void unsubscribe() {
    _rm.unsubscribe();
  }

  @override
  void Function() listenToRM(void Function(ReactiveModel<T> rm) fn) {
    return _rm.listenToRM(fn);
  }

  @override
  String type() {
    return _rm.type();
  }

  @override
  Inject<T> get inject => _rm.inject;

  @override
  Future<T> get valueAsync => _rm.valueAsync;
  // @override
  // ReactiveModel<T> as<R>() {
  //   return _rm.as<R>();
  // }
}
