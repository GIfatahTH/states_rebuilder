import 'dart:async';

import 'package:flutter/material.dart';

import 'reactive_model.dart';
import 'state_builder.dart';
import 'states_rebuilder.dart';

abstract class Injectable {
  Widget inheritedInject(Widget child);
}

enum JoinSingleton {
  ///The reactive singleton retains the state of the new reactive instance that is being notified.
  withNewReactiveInstance,

  ///The reactive singleton retains a combined state of the new instances.
  ///
  ///The combined state priority logic is:
  ///
  ///Priority 1- The combined [ReactiveModel.hasError] is true if at least one of the new instances has error
  ///
  ///Priority 2- The combined [ReactiveModel.connectionState] is awaiting if at least one of the new instances is awaiting.
  ///
  ///Priority 3- The combined [ReactiveModel.connectionState] is 'none' if at least one of the new instances is 'none'.
  ///
  ///Priority 4- The combined [ReactiveModel.hasDate] is true if it has no error, isn't awaiting  and is not in 'none' state.
  withCombinedReactiveInstances
}

///A class used to wrap injected models, streams or futures.
///It caches the rew singleton and the reactive singleton.
class Inject<T> implements Injectable {
  ///Inject a value or a model.
  Inject(
    this._creationFunction, {
    this.name,
    this.isLazy = true,
    this.initialCustomStateStatus,
    this.joinSingleton,
  }) {
    if (name != null) {
      _name = name.toString();
    }
  }

  ///Inject a Future
  Inject.future(
    this._creationFutureFunction, {
    this.name,
    this.initialValue,
    this.isLazy = true,
    this.watch,
    this.tags,
  }) {
    if (name != null) {
      _name = name.toString();
    }
    _isFutureType = true;
  }

  ///Inject a Stream
  Inject.stream(
    this._creationStreamFunction, {
    this.name,
    this.initialValue,
    this.isLazy = true,
    this.watch,
    this.tags,
  }) {
    if (name != null) {
      _name = name.toString();
    }
    _isStreamType = true;
  }

  /// The Creation Function.
  T Function() _creationFunction;

  /// The creation Function. It must return a Future.
  Future<T> Function() _creationFutureFunction;

  /// The creation Function. It must return a Stream.
  Stream<T> Function() _creationStreamFunction;

  /// The initial value.
  T initialValue;

  /// True if the injected model is instantiated lazily; that is at the time of the first use with [getAsReactive] and [get].
  ///
  /// False if the injected model is instantiated at the time of the injection.
  ///
  ///Default value is `true`.
  bool isLazy;

  ///A function that returns a single model instance variable or a list of
  ///them. The rebuild process will be triggered if at least one of
  ///the return variable changes.
  ///
  ///Return variable must be either a primitive variable, a List, a Map or a Set.
  ///
  ///To use a custom type, you should override the `toString` method to reflect
  ///a unique identity of each instance.
  ///
  ///If it is not defined all listener will be notified when a new state is available.
  dynamic Function(T) watch;

  /// List of [StateBuilder]'s tags to be notified to rebuild.
  List<dynamic> tags;

  ///The custom name to be used instead of the type to get the injected instance.
  dynamic name;

  ///A dynamic variable to hold your custom state status other than those defined by [ReactiveModel.connectionState]
  dynamic initialCustomStateStatus;

  ///new reactive instances can transmit their state and notification to reactive singleton.
  ///
  JoinSingleton joinSingleton;

  bool get isReactiveModel => reactiveSingleton != null;
  bool get isStatesRebuilder => singleton is StatesRebuilder;
  bool get isAsyncType => _isFutureType || _isStreamType;

  bool _isFutureType = false;
  bool _isStreamType = false;
  String _name; // cache for name
  T singleton; // vanilla singleton
  ReactiveModel<T> reactiveSingleton; // reactive singleton
  List<ReactiveModel<T>> newReactiveInstanceList = <
      ReactiveModel<
          T>>[]; // List of new reactive instance created from this Inject

  String getName() {
    if (_name == null) {
      _name = '$T';
    }
    assert(_name != 'dynamic');
    if (!isLazy) {
      getSingleton();
    }
    return _name;
  }

  T getSingleton() {
    singleton ??= _creationFunction();
    return singleton;
  }

  T getNewInstance() {
    return _creationFunction();
  }

  ReactiveModel<T> getReactiveSingleton() {
    if (reactiveSingleton == null) {
      if (_isFutureType) {
        reactiveSingleton = StreamStatesRebuilder<T>(
          _creationFutureFunction().asStream(),
          this,
        );
      } else if (_isStreamType) {
        reactiveSingleton = StreamStatesRebuilder<T>(
          _creationStreamFunction(),
          this,
        );
      } else {
        reactiveSingleton = ReactiveStatesRebuilder<T>(this)
          ..customStateStatus = initialCustomStateStatus;
      }
    }
    return reactiveSingleton;
  }

  ReactiveModel<T> getReactiveNewInstance([bool keepStateStatus]) {
    if (_isFutureType) {
      return reactiveSingleton;
    } else if (_isStreamType) {
      return reactiveSingleton;
    } else {
      ReactiveStatesRebuilder<T> _reactiveStatesRebuilder;
      if (keepStateStatus == true) {
        _reactiveStatesRebuilder = ReactiveStatesRebuilder<T>(this)
          ..customStateStatus = getReactiveSingleton().customStateStatus;
      } else {
        _reactiveStatesRebuilder = ReactiveStatesRebuilder<T>(this)
          ..customStateStatus = initialCustomStateStatus;
      }

      return _reactiveStatesRebuilder;
    }
  }

  final _statesRebuilder = _StatesRebuilder();

  void rebuildInheritedWidget(
    List<dynamic> tags,
    Function(BuildContext context) onSetState,
  ) {
    if (_statesRebuilder.hasObservers) {
      _statesRebuilder.rebuildStates(tags, onSetState);
    }
  }

  @override
  Widget inheritedInject(Widget child) {
    return StateBuilder<dynamic>(
      models: <StatesRebuilder>[_statesRebuilder],
      builder: (_, __) => InheritedInject<T>(
        child: child,
        getReactiveSingleton: () => reactiveSingleton,
      ),
    );
  }
}

class InheritedInject<T> extends InheritedWidget {
  InheritedInject({Key key, this.child, this.getReactiveSingleton})
      : super(key: key, child: child);
  final Widget child;
  final ReactiveModel<T> Function() getReactiveSingleton;
  static final List<BuildContext> lastContext = [null];

  ReactiveModel<T> get model => getReactiveSingleton();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

class _StatesRebuilder extends StatesRebuilder {}
