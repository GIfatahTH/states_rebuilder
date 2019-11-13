import 'dart:async';
import 'package:flutter/widgets.dart';
import '../states_rebuilder.dart';

abstract class ModelStatesRebuilder<T> extends StatesRebuilder {
  AsyncSnapshot<T> _snapshot;

  /// A representation of the most recent state (instance) of the injected model.
  ///
  AsyncSnapshot<T> get snapshot => _snapshot;

  T _state;

  ///The state of the injected model.
  T get state => _state ?? _snapshot.data;

  StreamSubscription<T> get subscription => null;

  ///Current state of connection to the asynchronous computation.
  ///
  ///The initial state is [ConnectionState.none]. If the an asynchronous event is mutating the state,
  ///the connection state is set to [ConnectionState.waiting] and listeners are notified. When the asynchronous task resolves
  ///the connection state is set to [ConnectionState.one] and listeners are notified.
  ///
  ///If the state is mutated by a non synchronous event, the connection state remains [ConnectionState.none].
  ConnectionState get connectionState => _snapshot.connectionState;

  ///Returns whether this state contains a non-null [error] value.
  bool get hasError => _snapshot.hasError;

  ///Returns whether this snapshot contains a non-null [data] value.
  bool get hasData => _snapshot.hasData;

  ///The latest error object received by the asynchronous computation.
  Object get error => _snapshot.error;

  /// custom status of state (ex: "ready" , "playing"; "displaying")
  ///
  /// The best place to change [stateStatus] is inside the callback of the [onSetState] parameters.
  var stateStatus;

  set state(T data) {
    _state = data;
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _state);
    if (hasState || customListener.isNotEmpty) rebuildStates();
  }

  /// Mutate the state of the model.
  ///
  /// [fn] takes the current state as argument. You can optionally define
  /// a list of [StateBuilder] [tags] to be notified after state mutation.
  ///
  /// To limit the rebuild process to a particular set of model instance variables use [watch].
  ///
  /// If you want to catch error define [catchError] to be true
  ///
  /// With [onsetState] you can define callBacks to be executed after mutating the state such as Navigation,
  /// show dialog or SnackBar.
  ///
  /// [watch] is a function that returns a single model instance variable or a list of
  /// them. The rebuild process will be triggered if at least one of
  /// the return variable changes. Returned variable must be either a primitive variable,
  /// a List, a Map or a Set.To use a custom type, you should override the `toString` method to reflect
  /// a unique identity of each instance.
  /// If it is not defined all listener will be notified when a new state is available.
  Future setState<D>(
    dynamic Function(T model) fn, {
    List tags,
    dynamic Function(T state) watch,
    bool catchError = false,
    void Function(BuildContext context) onSetState,
  }) async {
    final before = watch != null ? watch(state)?.toString() : null;

    try {
      dynamic result = fn(state) as dynamic;
      if (result is Future) {
        _snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, state);
        try {
          if (hasState || customListener.isNotEmpty)
            rebuildStates(tags, onSetState != null ? onSetState : null);
        } catch (e) {}
        await result;
      }
    } catch (e) {
      _snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
      if (hasState || customListener.isNotEmpty)
        rebuildStates(tags, onSetState != null ? onSetState : null);
      if (!catchError) rethrow;
      return;
    }
    _snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
    final after = watch != null ? watch(state)?.toString() : "";
    if (hasState || customListener.isNotEmpty) {
      //String in dart are immutable objects, which means that two strings with the same characters in the same order
      //share the same object.
      if (!identical(after, before)) {
        rebuildStates(tags, onSetState != null ? onSetState : null);
      }
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

  @override
  StreamSubscription<T> get subscription => _subscription;

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
