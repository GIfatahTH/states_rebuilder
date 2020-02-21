import 'package:flutter/material.dart';

import 'assertions.dart';
import 'inject.dart';
import 'reactive_model.dart';
import 'states_rebuilder.dart';

///A class used to register (inject) models.
class Injector extends StatefulWidget {
  ///List of models to register (inject).
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

  ///Used to reinject an already injected model to make it accessible to a new widget tree branch so that it can be found by [Injector.getAsReactive]
  final List<StatesRebuilder> reinject;

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
    this.inject,
    @required this.builder,
    this.reinject,
    //for app lifecycle
    this.initState,
    this.dispose,
    this.afterInitialBuild,
    this.appLifeCycle,
    this.disposeModels = false,
  })  : assert(builder != null),
        assert(inject != null || reinject != null, '''

| ***No model to inject***
| You have to define either the 'inject' or 'reinject' parameter.
| - 'inject' is use to inject new models.
| - 'reinject' is used to inject an already injected model to make it available to new branch of the widget tree.
|
        '''),
        super(key: key);

  static T get<T>({dynamic name, BuildContext context, bool silent = false}) {
    final String _name = name == null ? '$T' : name.toString();

    final Inject<T> inject = _getInject<T>(_name, silent);
    if (inject == null) {
      return null;
    }

    final model = inject.getSingleton();

    if (context == null) {
      return model;
    }

    if (model is StatesRebuilder) {
      assert(
        () {
          if (name != null) {
            throw Exception(AssertMessage.getModelWithContextAndName<T>(
                'Injector.get', '$name'));
          }
          return true;
        }(),
      );

      final InheritedInject inheritedInject = inject.staticOf(context);
      assert(inheritedInject == null || (model == inheritedInject.model));
      assert(
        () {
          if (silent == false && inheritedInject == null) {
            throw Exception(
                AssertMessage.inheritedWidgetOfReturnsNull<T>('Injector.get'));
          }
          return true;
        }(),
      );
      if (inject.refreshSubscribers != null) {
        inject.refreshSubscribers(model);
      }
    } else {
      throw Exception(AssertMessage.getModelNotStatesRebuilderWithContext<T>());
    }

    return model;
  }

  static ReactiveModel<T> getAsReactive<T>(
      {dynamic name, BuildContext context, bool silent = false}) {
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

    if (context == null) {
      if (inject.refreshSubscribers != null) {
        inject.refreshSubscribers(reactiveModel);
      }
      return reactiveModel;
    }

    assert(
      () {
        if (name != null) {
          throw Exception(AssertMessage.getModelWithContextAndName<T>(
              'Injector.getAsReactive', '$name'));
        }
        return true;
      }(),
    );
    final InheritedInject inheritedInject = inject.staticOf(context);
    assert(inheritedInject == null || (reactiveModel == inheritedInject.model));
    assert(
      () {
        if (silent == false && inheritedInject == null) {
          throw Exception(AssertMessage.inheritedWidgetOfReturnsNull<T>(
              'Injector.getAsReactive'));
        }
        return true;
      }(),
    );
    if (inject.refreshSubscribers != null) {
      inject.refreshSubscribers(reactiveModel);
    }
    ReactiveModelInternal.setOnSetStateContext(reactiveModel, context);
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

class InjectorState extends State<Injector> {
  ///Map contains all the registered models of the app
  static final Map<String, List<Inject<dynamic>>> allRegisteredModelInApp =
      <String, List<Inject<dynamic>>>{};
  List<Injectable> _injects = [];
  Widget _nestedInject;

  @override
  void initState() {
    super.initState();
    if (widget.inject != null) {
      for (Inject inject in widget.inject) {
        assert(inject != null);
        final name = inject.getName();
        final lastInject = allRegisteredModelInApp[name];
        if (lastInject == null) {
          allRegisteredModelInApp[name] = [inject];
          _injects.add(inject);
        } else {
          if (lastInject.first.isWidgetDeactivated) {
            allRegisteredModelInApp[name].add(inject);
            _injects.add(inject);
          } else {
            if (Injector.enableTestMode == false) {
              throw Exception(AssertMessage.injectingAnInjectedModel(name));
            }
          }
        }
      }
    }

    if (widget.reinject != null) {
      for (StatesRebuilder toReinject in widget.reinject) {
        dynamic model;

        if (toReinject is ReactiveModel<dynamic>) {
          model = toReinject?.state;
          assert(
            () {
              if (toReinject.isNewReactiveInstance) {
                throw Exception(AssertMessage.reinjectingNewReactiveInstance(
                    '${model.runtimeType}'));
              }
              return true;
            }(),
          );
        } else {
          model = toReinject;
        }

        final inject = Injector._getInject('${model.runtimeType}', true);

        assert(
          () {
            if (inject == null) {
              throw Exception(
                  AssertMessage.reinjectModelNotFound('${model.runtimeType}'));
            }
            return true;
          }(),
        );

        assert(
          () {
            if (inject.getSingleton() != model) {
              throw Exception(AssertMessage.reinjectNonInjectedInstance(
                  '${model.runtimeType}'));
            }
            return true;
          }(),
        );

        final name = inject.getName();
        allRegisteredModelInApp[name].add(inject);

        _injects.add(inject);
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

  @override
  void deactivate() {
    for (Inject inject in _injects) {
      inject.isWidgetDeactivated = true;
    }
    super.deactivate();
  }

  @override
  void dispose() {
    for (Inject inject in _injects) {
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
      inject.removeAllReactiveNewInstance();
    }

    if (widget.dispose != null) {
      widget.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nestedInject = Builder(
      builder: (BuildContext context) {
        return widget.builder(context);
      },
    );

    if (_injects.isNotEmpty) {
      for (Inject<dynamic> inject in _injects.reversed) {
        //Inject with name are not concerned with InheritedWidget

        if (inject.hasCustomName == false) {
          _nestedInject = inject.inheritedInject(_nestedInject);
        }
      }
    }
    return _nestedInject;
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
