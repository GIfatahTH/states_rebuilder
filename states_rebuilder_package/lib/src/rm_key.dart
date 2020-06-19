import 'dart:async';

import 'package:flutter/widgets.dart';

import 'inject.dart';
import 'reactive_model.dart';
import 'reactive_model_imp.dart';
import 'states_rebuilder.dart';

///ReactiveModel Key
class RMKey<T> implements ReactiveModel<T> {
  ///ReactiveModel Key
  RMKey([this.initialValue]);

  StatesRebuilder<T> _rmInitial;
  ReactiveModelImp<T> _rm;

  ///ReactiveModel associated with this key
  ReactiveModelImp<T> get rm => _rm;

  ///initial value
  T initialValue;

  ///is this key associated with a ReactiveModel or not
  bool get isLinked => _rmInitial == null;
  set rm(ReactiveModel<T> rm) {
    if (rm == null || rm == _rm) {
      return;
    }
    for (var fn in initCallBack) {
      fn(rm, _rmInitial);
    }

    _rm = rm as ReactiveModelImp<T>;
    _rmInitial = null;
    _rm.cleaner(unsubscribe);
  }

  void cleanRMKey() {
    refreshCallBack = null;
    _rm = null;
    initialValue = null;
    initCallBack = null;
    _associatedReactiveModels.clear();
  }

  final Map<String, List<ReactiveModel>> _associatedReactiveModels = {};

  void associate(ReactiveModel rm) {
    String type = rm.type(false);
    if (_associatedReactiveModels.containsKey(type)) {
      _associatedReactiveModels[type].add(rm);
    } else {
      _associatedReactiveModels[type] = [rm];
    }
  }

  ReactiveModel<T> get<T>([int index = 0]) =>
      _associatedReactiveModels['$T'][index];

  ///cashed refresh callback
  void Function(ReactiveModel rm) refreshCallBack;

  ///Initialization callback
  Set<void Function(ReactiveModel rm, StatesRebuilder initRM)> initCallBack =
      {};

  ///refresh (reset to initial value) of the ReactiveModel associate with this RMKey
  ///and notify observing widgets.
  Future<T> refresh([bool shouldNotify = true]) {
    refreshCallBack?.call(_rm);
    if (!rm.inject.isAsyncInjected) {
      rm.setState((_) => null);
    } else {
      rm.rebuildStates();
    }
    return stateAsync;
  }

  @override
  T get state {
    return _rm?.state ?? initialValue;
  }

  @override
  set state(T data) {
    _rm?.state = data;
  }

  @override
  void addObserver({ObserverOfStatesRebuilder observer, String tag}) {
    if (_rm == null) {
      _rmInitial ??= _KeyStatesRebuilder<T>();
      _rmInitial.addObserver(observer: observer, tag: tag);
      return;
    }
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
    bool shouldAwait = false,
    int debounceDelay,
    int throttleDelay,
    bool skipWaiting = false,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context, T model) onData,
    dynamic Function() joinSingletonToNewData,
    bool joinSingleton = false,
    bool notifyAllReactiveInstances = false,
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
      debounceDelay: debounceDelay,
      throttleDelay: throttleDelay,
      skipWaiting: skipWaiting,
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
  ReactiveModel<F> future<F>(
    Future<F> Function(T, Future<T> stateAsync) future, {
    F initialValue,
  }) {
    return _rm.future(
      future,
      initialValue: initialValue,
    );
  }

  @override
  ReactiveModel<S> stream<S>(
    Stream<S> Function(T, StreamSubscription<dynamic> subscription) stream, {
    S initialValue,
    Object Function(S s) watch,
  }) {
    return _rm.stream(
      stream,
      initialValue: initialValue,
      watch: watch,
    );
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
  Disposer listenToRM(void Function(ReactiveModel<T> rm) fn) {
    return _rm.listenToRM(fn);
  }

  @override
  String type([bool detailed = true]) {
    return _rm.type(detailed);
  }

  @override
  Inject<T> get inject => _rm?.inject;

  @override
  Future<T> get stateAsync => _rm.stateAsync;

  @override
  void notify([List tags]) {
    _rm.notify(tags);
  }

  // @override
  // ReactiveModel<T> as<R>() {
  //   return _rm.as<R>();
  // }
}

class _KeyStatesRebuilder<T> extends StatesRebuilder<T> {}
