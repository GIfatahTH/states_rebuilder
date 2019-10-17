import 'dart:async';

import 'package:flutter/widgets.dart';

import '../states_rebuilder.dart';

abstract class ModelStatesRebuilder<T> extends StatesRebuilder {
  AsyncSnapshot<T> _snapshot;
  AsyncSnapshot<T> get snapshot => _snapshot;

  T get state => _snapshot?.data;
  set state(T data) {
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.active, data);
    if (hasState || customListener.isNotEmpty) rebuildStates();
  }

  dynamic setState(dynamic Function(T model) fn, {List tags}) async {
    dynamic result = fn(state) as dynamic;
    if (result is Future) {
      await result;
    }
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.active, state);

    if (hasState || customListener.isNotEmpty) rebuildStates(tags);
  }
}

class ValueStatesRebuilder<T> extends ModelStatesRebuilder<T> {
  ValueStatesRebuilder(T instance) {
    this.state = instance;
  }
}

class StreamStatesRebuilder<T> extends ModelStatesRebuilder<T> {
  final Stream<T> _singleton;
  final T _initialData;
  StreamSubscription<T> _subscription;

  StreamStatesRebuilder(this._singleton, this._initialData) {
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _initialData);
    _subscribe();
    cleaner(
      () {
        _unsubscribe();
      },
    );
  }

  void _subscribe() {
    _subscription = _singleton.listen((T data) {
      _snapshot = AsyncSnapshot<T>.withData(ConnectionState.active, data);
      if (hasState || customListener.isNotEmpty) rebuildStates();
    }, onError: (Object error) {
      _snapshot = AsyncSnapshot<T>.withError(ConnectionState.active, error);
      if (hasState || customListener.isNotEmpty) rebuildStates();
    }, onDone: () {
      _snapshot = snapshot.inState(ConnectionState.done);
      if (hasState || customListener.isNotEmpty) rebuildStates();
    }, cancelOnError: false);
    _snapshot = snapshot.inState(ConnectionState.waiting);
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}
