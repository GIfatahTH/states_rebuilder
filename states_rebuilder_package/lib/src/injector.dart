import 'package:flutter/material.dart';

import 'assertions.dart';
import 'inject.dart';
import 'reactive_model.dart';
import 'reactive_model_imp.dart';
import 'states_rebuilder.dart';

///A class used to register (inject) models.
class Injector extends StatefulWidget {
  ///List of models to register (inject).
  ///
  ///**IMPORTANT: You can not inject more than one instance of a model.**
  ///**If you have to do that, use Inject with custom name.**
  ///example:
  ///```dart
  ///Injector(
  /// inject: [
  ///     Inject<int>(()=>1) // Inject a value
  ///     Inject<int>(()=>1,name:"var1") // Inject a value with a custom name
  ///     Inject<MyModel>(()=>MyModel()) // Inject a Model (dart class)
  ///     Inject<int>.stream(()=>myStream<int>(),initialValue:0) // Inject a stream with optional initial value
  ///     Inject<int>.future(()=>myFuture<int>(),initialValue:0) // Inject a future with optional initial value
  ///   ]
  ///)
  ///```
  final List<Injectable> inject;

  ///The builder closure. It takes as parameter the context.
  final Widget Function(BuildContext) builder;

  ///if it is set to true all injected models will be disposed.
  ///
  ///Injected models are disposed by calling the 'dispose()' method if exists.
  ///
  ///In any of the injected classes you can define a 'dispose()' method to clean up resources.
  final bool disposeModels;

  ///Refresh the list of inject model,
  ///whenever any of the observables in the [reinjectOn] emits a notification
  final List<StatesRebuilder> reinjectOn;

  ///By default refreshed model from [reinjectOn] will notify their observers.
  ///
  ///set [shouldNotifyOnReinjectOn] if you do not want to notify observers
  final bool shouldNotifyOnReinjectOn;

  ///Function to execute in `initState` of the state.
  final void Function() initState;

  ///Function to execute in `dispose` of the state.
  final void Function() dispose;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context) afterInitialBuild;

  ///Function to track app life cycle state. It takes as parameter the AppLifeCycleState.
  final void Function(AppLifecycleState) appLifeCycle;

  /// The environment the app should be in. It works with [Inject.interface]
  static dynamic env;

  ///set to true for test. It allows for injecting mock instances.
  static bool enableTestMode = false;

  ///A class used to register (inject) models.
  const Injector({
    Key key,
    // for injection
    @required this.inject,
    @required this.builder,
    this.reinjectOn,
    this.shouldNotifyOnReinjectOn = true,
    //for app lifecycle
    this.initState,
    this.dispose,
    this.afterInitialBuild,
    this.appLifeCycle,
    this.disposeModels = false,
  })  : assert(builder != null),
        assert(inject != null, '''

| ***No model to inject***
| You have to define either the 'inject' or 'reinject' parameter.
| - 'inject' is use to inject new models.
| - 'reinject' is used to inject an already injected model to make it available to new branch of the widget tree.
|
        '''),
        super(key: key);

  ///Get the singleton instance of a model registered with [Injector].
  static T get<T>({dynamic name, bool silent = false}) {
    final String _name = name == null ? '$T' : name.toString();

    final Inject<T> inject = _getInject<T>(_name, silent);
    if (inject == null) {
      return null;
    }

    return inject.getSingleton();
  }

  ///Get the singleton [ReactiveModel] instance of a model registered with [Injector].
  static ReactiveModel<T> getAsReactive<T>(
      {dynamic name, bool silent = false}) {
    final String _name = name == null ? '$T' : name.toString();

    final Inject<T> inject = _getInject<T>(_name, silent);

    if (inject == null) {
      return null;
    }
    final reactiveModel = inject.getReactive();
    assert(
      () {
        if (reactiveModel.state is StatesRebuilder) {
          throw Exception(AssertMessage.gettingAsReactiveAStatesRebuilderModel(
              '${reactiveModel.state.runtimeType}'));
        }
        return true;
      }(),
    );
    return reactiveModel;
  }

  static Inject<T> _getInject<T>(String name, [bool silent = false]) {
    final Inject<dynamic> inject =
        InjectorState.allRegisteredModelInApp[name]?.last;
    assert(
      () {
        if (silent != true && inject == null) {
          throw Exception(AssertMessage.modelNotRegistered(
            name,
            '${InjectorState.allRegisteredModelInApp.keys}',
          ));
        }
        return true;
      }(),
    );

    return inject as Inject<T>;
  }

  @override
  State<Injector> createState() {
    if (appLifeCycle == null) {
      return InjectorState();
    } else {
      return InjectorStateAppLifeCycle();
    }
  }
}

///
class InjectorState extends State<Injector> {
  ///Map contains all the registered models of the app
  static final Map<String, List<Inject<dynamic>>> allRegisteredModelInApp =
      <String, List<Inject<dynamic>>>{};
  List<Inject<dynamic>> _injects = [];
  @override
  void initState() {
    super.initState();
    _initState();

    if (widget.reinjectOn != null) {
      for (StatesRebuilder model in widget.reinjectOn) {
        model.addObserver(
          observer: _ObserverOfStatesRebuilder(
            () {
              if (model is ReactiveModelImp && !model.hasData) {
                return;
              }
              for (Inject<dynamic> inject in _injects) {
                final inj = allRegisteredModelInApp[inject.getName()].last;
                final rm = inj.getReactive();
                rm
                  ..cleaner(rm.unsubscribe, true)
                  ..unsubscribe();
                if (inject.isAsyncInjected) {
                  if (inject.isFutureType) {
                    inj.creationFutureFunction = inject.creationFutureFunction;
                    rm.setState(
                      (s) => inject.creationFutureFunction(),
                      catchError: true,
                      silent: true,
                      filterTags: inject.filterTags,
                    );
                  } else {
                    inj.creationStreamFunction = inject.creationStreamFunction;
                    rm.setState(
                      (s) => inject.creationStreamFunction(),
                      catchError: true,
                      silent: true,
                      filterTags: inject.filterTags,
                    );
                  }
                } else {
                  if (inj.singleton != null) {
                    inj.singleton = inj.creationFunction();
                    (inj.reactiveSingleton as ReactiveModelImp).state =
                        inj.singleton;
                    if (widget.shouldNotifyOnReinjectOn &&
                        inj.reactiveSingleton.hasObservers) {
                      inj.reactiveSingleton.setState(null);
                    }
                  }
                }
                // if (inject.isAsyncInjected) {
                //   inj
                //     ..getReactive().unsubscribe()
                //     ..creationStreamFunction = inject.creationStreamFunction
                //     ..creationFutureFunction = inject.creationFutureFunction;
                //   (inj.getReactive() as ReactiveModelStream).streamSubscribe();
                // } else {
                //   if (inj.singleton != null) {
                //     inj.singleton = inj.creationFunction();
                //     (inj.reactiveSingleton as ReactiveModelImp).state =
                //         inj.singleton;
                //     if (widget.shouldNotifyOnReinjectOn &&
                //         inj.reactiveSingleton.hasObservers) {
                //       inj.reactiveSingleton.setState(null);
                //     }
                //   }
                // }
              }
            },
          ),
          tag: 'reinjectOn',
        );
      }
    }

    if (widget.initState != null) {
      widget.initState();
    }

    if (widget.afterInitialBuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterInitialBuild(context),
      );
    }
  }

  void _initState() {
    if (widget.inject != null) {
      _injects = List<Inject<dynamic>>.from(widget.inject);
      for (Inject<dynamic> inject in _injects) {
        assert(inject != null);
        final name = inject.getName();
        inject.isGlobal = true;
        final lastInject = allRegisteredModelInApp[name];
        if (lastInject == null) {
          allRegisteredModelInApp[name] = [inject];
        } else {
          if (Injector.enableTestMode == false) {
            allRegisteredModelInApp[name].add(inject);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _dispose();

    if (widget.dispose != null) {
      widget.dispose();
    }
    _injects = null;
    super.dispose();
  }

  void _dispose() {
    for (Inject<dynamic> inject in _injects) {
      if (inject.isAsyncInjected) {
        inject.reactiveSingleton?.unsubscribe();
      }
      final name = inject.getName();
      allRegisteredModelInApp[name]?.remove(inject);

      if (allRegisteredModelInApp[name].isEmpty) {
        allRegisteredModelInApp.remove(name);

        if (widget.disposeModels == true) {
          try {
            (inject.getSingleton() as dynamic)?.dispose();
          } catch (e) {
            if (e is! NoSuchMethodError) {
              rethrow;
            }
          }
        }
      }
      inject
        ..removeAllReactiveNewInstance()
        ..singleton = null
        ..reactiveSingleton = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

///State of injector mixin with WidgetsBindingObserver
class InjectorStateAppLifeCycle extends InjectorState
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.appLifeCycle(state);
  }
}

class _ObserverOfStatesRebuilder extends ObserverOfStatesRebuilder {
  final void Function() updateCallback;
  _ObserverOfStatesRebuilder(this.updateCallback);
  @override
  bool update([Function(BuildContext) onSetState, dynamic _]) {
    updateCallback();
    return true;
  }
}

///
abstract class IN {
  ///Get the plain injected object
  static T get<T>({
    dynamic name,
    bool silent = false,
  }) {
    return Injector.get<T>(
      name: name,
      silent: silent,
    );
  }
}
