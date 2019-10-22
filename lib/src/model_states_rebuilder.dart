import 'dart:async';
import 'package:flutter/widgets.dart';
import '../states_rebuilder.dart';

abstract class ModelStatesRebuilder<T> extends StatesRebuilder {
  AsyncSnapshot<T> _snapshot;

  /// Immutable representation of the most recent state (instance) of the injected model.
  AsyncSnapshot<T> get snapshot => _snapshot;

  ///The state of the injected model.
  T get state => _snapshot?.data;

  set state(T data) {
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.active, data);
    if (hasState || customListener.isNotEmpty) rebuildStates();
  }

  /// Mutate the state of the model.
  ///
  /// [fn] takes the current state as argument. You can optionally define
  /// a list of [StateBuilder] [tags] to be notified after state mutation.
  ///
  /// To limit the rebuild process to a particular set of model instance variables use [watch].
  ///
  /// [watch] is a function that returns a single model instance variable or a list of
  /// them. The rebuild process will be triggered if at least one of
  /// the return variable changes.
  ///
  /// Return variable must be either a primitive variable, a List, a Map or a Set.
  ///
  /// To use a custom type, you should override the `toString` method to reflect
  /// a unique identity of each instance.
  ///
  /// If it is not defined all listener will be notified when a new state is available.
  void setState(dynamic Function(T model) fn,
      {List tags, dynamic Function(T state) watch}) async {
    final before = watch != null ? watch(state)?.toString() : null;
    dynamic result = fn(state) as dynamic;
    if (result is Future) {
      _snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, state);
      if (hasState || customListener.isNotEmpty) rebuildStates(tags);
      await result;
    }
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
    final after = watch != null ? watch(state)?.toString() : "";
    if (hasState || customListener.isNotEmpty) {
      //It is a little challenging to compare twe reference values (List or Map)
      //To do so I converted the values to string and compare them using the `identical` function which is an optimization.
      //String in dart are immutable objects, which means that two strings with the same characters in the same order
      //share the same object.
      if (!identical(after, before)) rebuildStates(tags);
    }
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
  bool isDifferent = true;
  dynamic Function(T oldValue) watch;
  String _before;
  List tags;

  StreamStatesRebuilder(
      this._singleton, this._initialData, this.watch, this.tags) {
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
      if (watch != null) {
        final _after = watch(data).toString();
        isDifferent = !identical(_before, _after);
        _before = _after;
      }
      _snapshot = AsyncSnapshot<T>.withData(ConnectionState.active, data);
      if (hasState || customListener.isNotEmpty) if (isDifferent)
        rebuildStates(tags);
    }, onError: (Object error) {
      _snapshot = AsyncSnapshot<T>.withError(ConnectionState.active, error);
      if (hasState || customListener.isNotEmpty) rebuildStates(tags);
    }, onDone: () {
      _snapshot = snapshot.inState(ConnectionState.done);
      if (hasState || customListener.isNotEmpty) rebuildStates(tags);
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
