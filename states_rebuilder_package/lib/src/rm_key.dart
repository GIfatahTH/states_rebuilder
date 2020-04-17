import 'dart:async';

import 'package:flutter/src/widgets/async.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class RMKey<T> implements ReactiveModel<T> {
  ReactiveModel<T> rm;

  @override
  T get state {
    assert(rm != null);
    return rm.state;
  }

  @override
  void set state(T data) {
    rm.state = data;
  }

  @override
  T get value => rm.value;

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
      joinSingletonToNewData: rm.joinSingletonToNewData,
      setValue: true,
    );
  }

  @override
  void addObserver({ObserverOfStatesRebuilder observer, String tag}) {
    rm.addObserver(observer: observer, tag: tag);
  }

  @override
  void cleaner(VoidCallback voidCallback) {
    rm.cleaner(voidCallback);
  }

  @override
  bool get hasObservers => rm.hasObservers;

  @override
  Map<String, Set<ObserverOfStatesRebuilder>> observers() {
    return rm.observers();
  }

  @override
  void rebuildStates([List tags, void Function(BuildContext) onSetState]) {
    rm.rebuildStates(tags, onSetState);
  }

  @override
  void removeObserver({ObserverOfStatesRebuilder observer, String tag}) {
    rm.removeObserver(observer: observer, tag: tag);
  }

  @override
  get error => rm.error;

  @override
  bool get hasData => rm.hasData;

  @override
  bool get hasError => rm.hasError;

  @override
  Inject<T> get inject => rm.inject;

  @override
  bool get isIdle => rm.isIdle;

  @override
  bool get isNewReactiveInstance => rm.isNewReactiveInstance;

  @override
  bool get isStreamDone => rm.isStreamDone;

  @override
  bool get isWaiting => rm.isWaiting;

  @override
  get joinSingletonToNewData => rm.joinSingletonToNewData;

  @override
  void resetToHasData() {
    rm.resetToHasData();
  }

  @override
  void resetToIdle() {
    rm.resetToIdle();
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
    return rm.setState(
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
  StreamSubscription<T> get subscription => rm.subscription;

  @override
  String toStringErrorStack() {
    return rm.toStringErrorStack();
  }

  @override
  void unsubscribe() {
    rm.unsubscribe();
  }

  R whenConnectionState<R>({
    @required R Function() onIdle,
    @required R Function() onWaiting,
    @required R Function(T state) onData,
    @required R Function(dynamic error) onError,
    bool catchError = true,
  }) {
    return rm.whenConnectionState(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onData: onData,
      onError: onError,
    );
  }

  @override
  var customStateStatus;

  @override
  AsyncSnapshot<T> snapshot;

  @override
  ReactiveModel<T> asNew([seed = 'defaultReactiveSeed']) {
    return rm.asNew(seed);
  }

  @override
  ConnectionState get connectionState => rm.connectionState;

  @override
  void copyStatue(ReactiveModel from) {
    rm.copyStatue(from);
  }
}
