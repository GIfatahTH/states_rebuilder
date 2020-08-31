part of '../inject.dart';

abstract class Injectable {}

///Base class for [Inject]
abstract class Inject<T> extends Injectable {
  static int _envMapLength;
  Inject._();

  ///Inject a value or a model.
  factory Inject(
    T Function() creationFunction, {
    dynamic name,
    bool isLazy = true,
    JoinSingleton joinSingleton,
  }) {
    return InjectImp(
      creationFunction,
      name: name,
      isLazy: isLazy,
      joinSingleton: joinSingleton,
    );
  }

  factory Inject.future(
    Future<T> Function() creationFutureFunction, {
    dynamic name,
    bool isLazy,
    T initialValue,
    List<dynamic> filterTags,
  }) = InjectFuture;

  factory Inject.stream(
    Stream<T> Function() creationStreamFunction, {
    dynamic name,
    bool isLazy,
    T initialValue,
    List<dynamic> filterTags,
    Object Function(T) watch,
  }) = InjectStream;

  ///Injected a map of flavor
  factory Inject.interface(
    Map<dynamic, FutureOr<T> Function()> impl, {
    dynamic name,
    bool isLazy,
    JoinSingleton joinSingleton,
    T initialValue,
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

    final creationFunction = impl[Injector.env];
    if (creationFunction is Future<T> Function()) {
      return Inject.future(
        creationFunction,
        name: name,
        isLazy: isLazy,
        initialValue: initialValue,
      );
    }
    return Inject(
      creationFunction as T Function(),
      name: name,
      isLazy: isLazy,
      joinSingleton: joinSingleton,
    );
  }

  ///Inject a model that depends on its previous state
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

  /// vanilla singleton
  T singleton;

  /// reactive singleton
  ReactiveModel<T> reactiveSingleton;

  String _name;

  /// List of new reactive instance created from this Inject
  List<ReactiveModel<T>> newReactiveInstanceList = <ReactiveModel<T>>[];

  ///Map of new reactive instance created by  ReactiveModel.AsNew
  Map<String, ReactiveModel<T>> newReactiveMapFromSeed = {};

  ///Number of [OnSetStateListener] widget listening the this [ReactiveModel]
  int onSetStateListenerNumber = 0;

  ///Has this ReactiveModel any subscribed [OnSetStateListener]
  bool get hasOnSetStateListener => onSetStateListenerNumber > 0;

  ReactiveModel<T> _getRM([bool asNew = false]);

  ///Is this [Inject] global
  bool isGlobal = false;

  /// Get the name of the model is registered with.
  String getName() {
    assert(T != dynamic);
    assert(T != Object);
    return _name ??= '$T';
  }

  T _getSingleton();

  ///Get the registered singleton
  T getSingleton() {
    try {
      return singleton ??= _getSingleton();
    } catch (e, s) {
      RM.errorLog?.call(e, s);
      assert(() {
        if (RM.debugError != null || RM.debugErrorWithStackTrace) {
          developer.log(
            e.toString(),
            name: 'states_rebuilder::getSingleton',
            error: e,
            stackTrace: s,
          );
        }
        return true;
      }());
      rethrow;
    }
  }

  ///Get the registered reactive singleton or new reactive instance
  ReactiveModel<T> getReactive([bool asNew = false]) {
    try {
      ReactiveModel<T> rs;
      if (reactiveSingleton == null || asNew) {
        rs = _getRM(asNew);
      }

      return asNew ? rs : reactiveSingleton ??= rs;
    } catch (e, s) {
      RM.errorLog?.call(e, s);
      assert(() {
        if (RM.debugError != null || RM.debugErrorWithStackTrace) {
          developer.log(
            e.toString(),
            name: 'states_rebuilder::getReactive',
            error: e,
            stackTrace: s,
          );
        }
        // RM.debugError?.call(e, s);
        return true;
      }());
      rethrow;
    }
  }

  ///Clear this [Inject]
  void cleanInject() {
    if (reactiveSingleton != null) {
      statesRebuilderCleaner(reactiveSingleton, false);
    }
    singleton = null;
    reactiveSingleton = null;
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

  @override
  String toString() {
    return 'Inject<$T>(singleton: ${singleton}, singletonRM: ${reactiveSingleton})';
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
