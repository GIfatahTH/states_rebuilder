import 'dart:async';

import 'package:flutter/material.dart';

import 'injector.dart';
import 'reactive_model.dart';
import 'state_builder.dart';
import 'states_rebuilder.dart';

///Base class for [Inject]
abstract class Injectable {
  ///wrap with InheritedWidget
  Widget inheritedInject(Widget child);
}

///Join reactive singleton to reactive environment
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
  ///Priority 4- The combined [ReactiveModel.hasData] is true if it has no error, isn't awaiting  and is not in 'none' state.
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

  /// True if the injected model is instantiated lazily; that is at the time of the first use with [Injector.getAsReactive] and [Injector.get].
  ///
  /// False if the injected model is instantiated at the time of the injection.
  ///
  ///Default value is `true`.
  bool isLazy;

  ///A function that returns a one instance variable or a list of
  ///them. The rebuild process will be triggered if at least one of
  ///the return variable changes.
  ///
  ///Return variable must be either a primitive variable, a List, a Map or a Set.
  ///
  ///To use a custom type, you should override the `toString` method to reflect
  ///a unique identity of each instance.
  ///
  ///If it is not defined all listener will be notified when a new state is available.
  Object Function(T) watch;

  /// List of [StateBuilder]'s tags to be notified to rebuild.
  List<dynamic> tags;

  ///The custom name to be used instead of the type to get the injected instance.
  dynamic name;

  ///A dynamic variable to hold your custom state status other than those defined by [ReactiveModel.connectionState]
  dynamic initialCustomStateStatus;

  ///new reactive instances can transmit their state and notification to reactive singleton.
  ///
  JoinSingleton joinSingleton;

  ///Whether the reactive singleton is instantiated
  bool get isReactiveModel => reactiveSingleton != null;

  ///Whether the model is of [StatesRebuilder] type
  bool get isStatesRebuilder => singleton is StatesRebuilder;

  ///Whether the injected model is stream or future
  bool get isAsyncType => _isFutureType || _isStreamType;

  bool _isFutureType = false;
  bool _isStreamType = false;
  String _name; // cache for name
  /// vanilla singleton
  T singleton;

  /// reactive singleton
  ReactiveModel<T> reactiveSingleton;

  /// List of new reactive instance created from this Inject
  List<ReactiveModel<T>> newReactiveInstanceList = <ReactiveModel<T>>[];

  /// Get the name of the model is registered with.
  String getName() {
    assert(T != dynamic);

    _name ??= '$T';

    if (!isLazy) {
      if (isAsyncType) {
        getReactiveSingleton();
      } else {
        getSingleton();
      }
    }
    return _name;
  }

  ///Get the registered singleton
  T getSingleton() {
    singleton ??= _creationFunction();
    return singleton;
  }

  ///Get the registered reactive singleton
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

  ///Get a new reactive instance
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

  final _StatesRebuilder _statesRebuilder = _StatesRebuilder();

  ///Notify InheritedWidget
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

///Inherited widget class
class InheritedInject<T> extends InheritedWidget {
  ///Inherited widget class
  const InheritedInject({Key key, Widget child, this.getReactiveSingleton})
      : super(key: key, child: child);

  ///get reactive singleton associated with this InheritedInject
  final ReactiveModel<T> Function() getReactiveSingleton;

  /// The last registered add BuildContext
  static final List<BuildContext> lastContext = <BuildContext>[null];

  ///get The model
  ReactiveModel<T> get model => getReactiveSingleton();

  @override
  bool updateShouldNotify(InheritedInject<T> oldWidget) {
    return true;
  }
}

class _StatesRebuilder extends StatesRebuilder {}
