import 'dart:async';

import 'package:flutter/src/widgets/async.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class RMKey<T> implements ReactiveModelImp<T> {
  ReactiveModel<T> _rmInitial;
  ReactiveModelImp<T> _rm;
  ReactiveModelImp<T> get rm => _rm;
  final T initialValue;
  RMKey([this.initialValue]) // : super.inj(Inject<T>(() => initialValue))
  {
    _rm = _rmInitial = RM.create<T>(initialValue);
  }
  bool get isLinked => _rm != _rmInitial;
  set rm(ReactiveModel<T> rm) {
    if (rm == null || rm == _rm) {
      return;
    }

    for (var fn in initCallBack) {
      fn(rm);
    }

    _rm = rm;
    _rm.cleaner(() {
      unsubscribe(null);
    });
  }

  void Function(ReactiveModel rm) refreshCallBack;
  Set<void Function(ReactiveModel rm)> initCallBack = {};

  ///refresh (reset to initial value) of the ReactiveModel associate with this RMKey
  ///and notify observing widgets.
  void refresh() {
    refreshCallBack?.call(_rm);
    if (!rm.inject.isAsyncInjected) {
      rm.setState((_) => null);
    } else {
      rm.rebuildStates();
    }
  }

  @override
  T get state {
    assert(rm != null);
    return _rm?.state;
  }

  @override
  T get value => _rm?.value;
  @override
  void set value(T data) {
    assert(_rm != null);
    _rm.value = data;
  }

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
  }) async {
    assert(rm != null);
    await setState(
      (_) => fn(),
      filterTags: filterTags,
      seeds: seeds,
      onSetState: onSetState,
      onRebuildState: onRebuildState,
      onData: onData,
      onError: onError,
      catchError: catchError,
      notifyAllReactiveInstances: notifyAllReactiveInstances,
      joinSingleton: joinSingleton,
      joinSingletonToNewData: _rm?.joinSingletonToNewData,
      setValue: true,
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
  get error => _rm?.error;

  @override
  bool get hasData => _rm?.hasData;

  @override
  bool get hasError => _rm?.hasError;

  @override
  Inject<T> get inject => _rm?.inject;

  @override
  bool get isIdle => _rm?.isIdle;

  @override
  bool get isNewReactiveInstance => _rm?.isNewReactiveInstance;

  @override
  bool get isStreamDone => _rm?.isStreamDone;

  @override
  bool get isWaiting => _rm?.isWaiting;

  @override
  get joinSingletonToNewData => _rm?.joinSingletonToNewData;

  @override
  void resetToHasData() {
    _rm?.resetToHasData();
  }

  @override
  void resetToIdle() {
    _rm?.resetToIdle();
  }

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
  StreamSubscription<T> get subscription => _rm?.subscription;

  @override
  String toString() {
    return '$_rm';
  }

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
  ReactiveModel<T> asNew([seed = 'defaultReactiveSeed']) {
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
  ReactiveModel<F> future<F>(Future<F> Function(T) future, {T initialValue}) {
    return _rm.future(future, initialValue: initialValue);
  }

  @override
  ReactiveModel<S> stream<S>(Stream<S> Function(T) stream, {T initialValue}) {
    return _rm.stream(stream, initialValue: initialValue);
  }

  // @override
  // void copyRM(ReactiveModel<T> to) {
  //   _rm.copyRM(to);
  // }

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
  void set state(T data) {
    _rm.state = data;
  }

  @override
  void subscribe(void Function(ReactiveModel<T> rm) fn) {
    _rm.subscribe(fn);
  }

  @override
  void unsubscribe([void Function(ReactiveModel<T> rm) fn]) {
    _rm.unsubscribe(fn);
  }

  // @override
  // ReactiveModel<T> as<R>() {
  //   return _rm.as<R>();
  // }
}
