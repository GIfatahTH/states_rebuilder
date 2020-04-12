import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'reactive_model.dart';
import 'state_builder.dart';
import 'states_rebuilder.dart';

///Base class for [Inject]
abstract class Injectable {
  ///wrap with InheritedWidget
  Widget inheritedInject(Widget child);
}

///A class used to wrap injected models, streams or futures.
///It caches the rew singleton and the reactive singleton.
class Inject<T> implements Injectable {
  /// The Creation Function.
  T Function() creationFunction;

  /// Get the creation Function. It must return a Future.
  Future<T> Function() creationFutureFunction;

  /// Get the creation Function. It must return a Stream.
  Stream<T> Function() creationStreamFunction;

  String _name;

  /// vanilla singleton
  T singleton;

  /// reactive singleton
  ReactiveModel<T> reactiveSingleton;

  /// List of new reactive instance created from this Inject
  List<ReactiveModel<T>> newReactiveInstanceList = <ReactiveModel<T>>[];

  ///Map of new reactive instance created by  ReactiveModel.AsNew
  Map<String, ReactiveModel<T>> newReactiveMapFromSeed = {};

  /// True if the injected model is instantiated lazily; that is at the time of the first use with [Injector.getAsReactive] and [Injector.get].
  ///
  /// False if the injected model is instantiated at the time of the injection.
  ///
  ///Default value is `true`.
  bool isLazy;

  /// The initial value.
  T initialValue;

  ///Whether the injected model is stream or future
  bool get isAsyncInjected => _isFutureType || _isStreamType;

  ///Whether the model is of [StatesRebuilder] type
  bool get isStatesRebuilder =>
      isAsyncInjected ? false : singleton is StatesRebuilder;
  bool get hasCustomName => _hasCustomName;

  bool _isFutureType = false;
  bool get isFutureType => _isFutureType;

  bool _isStreamType = false;

  bool _hasCustomName = false;

  ///new reactive instances can transmit their state and notification to reactive singleton.
  JoinSingleton joinSingleton;

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
  List<dynamic> filterTags;

  int onSetStateListenerNumber = 0;
  bool get hasOnSetStateListener => onSetStateListenerNumber > 0;

  static int _envMapLength;

  bool isWidgetDeactivated = false;

  ///Inject a value or a model.
  Inject(
    this.creationFunction, {
    dynamic name,
    this.isLazy,
    this.joinSingleton,
  }) {
    _name = name?.toString();
    _hasCustomName = name != null;
  }

  ///Inject a Future
  Inject.future(
    this.creationFutureFunction, {
    dynamic name,
    this.isLazy = true,
    this.initialValue,
    this.filterTags,
  }) {
    _name = name?.toString();
    _isFutureType = true;
    _hasCustomName = name != null;
  }

  Inject.stream(
    this.creationStreamFunction, {
    dynamic name,
    this.isLazy = true,
    this.initialValue,
    this.watch,
    this.filterTags,
  }) {
    _name = name?.toString();
    _isStreamType = true;
    _hasCustomName = name != null;
  }

  Inject.interface(
    Map<dynamic, T Function()> impl, {
    dynamic name,
    this.isLazy,
    this.joinSingleton,
  }) {
    assert(Injector.env != null, '''
You are using [Inject.interface] constructor. You have to define the [Inject.env] before the [runApp] method
    ''');
    assert(impl[Injector.env] != null, '''
There is no implementation for ${Injector.env} of $T interface
    ''');
    _envMapLength ??= impl.length;
    assert(impl.length == _envMapLength, '''
You must be consistent about the number of flavor environment you have.
you had $_envMapLength flavors and you are defining ${impl.length} flavors.
    ''');

    this.creationFunction = impl[Injector.env];

    _name = name?.toString();
    _hasCustomName = name != null;
  }

  factory Inject.previous(
    T Function(T previous) creationFunction, {
    dynamic name,
    bool isLazy,
    JoinSingleton joinSingleton,
    T initialValue,
  }) {
    bool isInit = false;
    return Inject(
      () {
        T v = initialValue;
        if (isInit) {
          v = Injector.get<T>(silent: true);
        } else {
          isInit = true;
        }
        return creationFunction(v);
      },
      name: name,
      isLazy: isLazy,
      joinSingleton: joinSingleton,
    );
  }

  /// Get the name of the model is registered with.
  String getName() {
    assert(T != dynamic);
    assert(T != Object);

    if (isLazy == false) {
      getReactive();
    }
    return _name ??= '$T';
  }

  ///Get the registered singleton
  T getSingleton() {
    if (isAsyncInjected == true) {
      singleton = getReactive().state;
      return singleton;
    }
    singleton ??= creationFunction();

    return singleton;
  }

  ///Get the registered reactive singleton or new reactive instance
  ReactiveModel<T> getReactive([bool asNew = false]) {
    ReactiveModel<T> rs;
    if (reactiveSingleton == null || asNew) {
      if (isAsyncInjected) {
        rs = StreamStatesRebuilder<T>(this, asNew);
      } else {
        rs = ReactiveStatesRebuilder<T>(this, asNew);
      }
      addToReactiveNewInstanceList(asNew ? rs : null);
    }

    return asNew ? rs : reactiveSingleton ??= rs;
  }

  void Function(StatesRebuilder model) refreshInheritedModelSubscribers;

  _InheritedWidgetModel _inheritedWidgetModel = _InheritedWidgetModel();

  @override
  Widget inheritedInject(Widget child) {
    return StateBuilder<Injector>(
      models: <StatesRebuilder>[_inheritedWidgetModel..injectSR = this],
      builder: (ctx, __) {
        return InheritedInject<T>(
          child: child,
          getSingleton: () => isStatesRebuilder
              ? getSingleton() as StatesRebuilder
              : getReactive(),
        );
      },
    );
  }

  InheritedInject staticOf(BuildContext context) {
    final InheritedInject model =
        context.dependOnInheritedWidgetOfExactType<InheritedInject<T>>();
    return model;
  }

  ///Add the reactive model in the inject new reactive models list.
  void addToReactiveNewInstanceList(ReactiveModel<T> rm) {
    if (rm == null) return;
    newReactiveInstanceList?.add(rm);
  }

  ///remove the reactive model in the inject new reactive models list.
  void removeFromReactiveNewInstanceList(ReactiveModel rm) {
    if (rm == null) return;
    newReactiveInstanceList?.remove(rm);
  }

  ///remove the reactive model in the inject new reactive models list.
  void removeAllReactiveNewInstance() {
    newReactiveInstanceList?.clear();
    newReactiveMapFromSeed.clear();
  }
}

///Inherited widget class
class InheritedInject<T> extends InheritedWidget {
  ///Inherited widget class
  const InheritedInject({Key key, Widget child, this.getSingleton})
      : super(key: key, child: child);

  ///get reactive singleton associated with this InheritedInject
  final StatesRebuilder Function() getSingleton;

  ///get The model
  StatesRebuilder get model => getSingleton();

  @override
  bool updateShouldNotify(InheritedInject<T> oldWidget) {
    return true;
  }
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

class _InheritedWidgetModel extends StatesRebuilder {
  Inject injectSR;
  StatesRebuilder modelFromInjectSR;

  @override
  void addObserver({ObserverOfStatesRebuilder observer, String tag}) {
    super.addObserver(observer: observer, tag: tag);

    if (injectSR != null) {
      injectSR.refreshInheritedModelSubscribers = (model) {
        modelFromInjectSR = model;
        StatesRebuilderInternal.addAllToObserverMap(this, modelFromInjectSR);
        //ensure that it is called once after each add of observer
        injectSR.refreshInheritedModelSubscribers = null;
      };
    }
  }

  @override
  void removeObserver({ObserverOfStatesRebuilder observer, String tag}) {
    super.removeObserver(observer: observer, tag: tag);

    if (injectSR != null && modelFromInjectSR != null) {
      if (modelFromInjectSR.observers()[tag] != null) {
        modelFromInjectSR.removeObserver(observer: observer, tag: tag);
      }
    }
  }
}
