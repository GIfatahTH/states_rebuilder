import 'package:flutter/material.dart';

import 'assertions.dart';
import 'inject.dart';
import 'reactive_model.dart';
import 'register_injected_models.dart';
import 'states_rebuilder.dart';

///A class used to register (inject) models.
class Injector extends StatefulWidget {
  ///A class used to register (inject) models.

  const Injector({
    Key key,
    // for injection
    @required this.builder,
    this.inject,
    this.reinject,
    //for app lifecycle
    this.initState,
    this.dispose,
    this.appLifeCycle,
    this.afterInitialBuild,
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

  ///The builder closure. It takes as parameter the context.
  final Widget Function(BuildContext) builder;

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

  ///Used to reinject an already injected model to make it accessible to a new widget tree branch so that it can be found by [Injector.getAsReactive]
  final List<StatesRebuilder> reinject;

  ///Function to execute in `initState` of the state.
  final void Function() initState;

  ///Function to execute in `dispose` of the state.
  final void Function() dispose;

  ///Function to track app life cycle state. It takes as parameter the AppLifeCycleState.
  final void Function(AppLifecycleState) appLifeCycle;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context) afterInitialBuild;

  ///Set to true to dispose all models.
  final bool disposeModels;

  /// get the same singleton
  static T get<T>({dynamic name, BuildContext context, bool silent = false}) {
    final String _name = name == null ? '$T' : name.toString();

    final Inject<T> inject = _getInject<T>(_name, silent);

    if (inject == null) {
      return null;
    }

    assert(
      () {
        if (inject.isAsyncType == true) {
          throw Exception(AssertMessage.getInjectStreamAndFutureError());
        }
        return true;
      }(),
    );

    final T model = inject?.getSingleton();

    if (context != null) {
      assert(
        () {
          if (model is! StatesRebuilder) {
            throw Exception(
                AssertMessage.getModelNotStatesRebuilderWithContext<T>());
          }
          return true;
        }(),
      );
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

        final InheritedWidget inheritedWidget =
            ReactiveModel.staticOf<T>(context);
        assert(
          () {
            if (!silent && inheritedWidget == null) {
              throw Exception(AssertMessage.inheritedWidgetOfReturnsNull<T>(
                  'Injector.get'));
            }
            return true;
          }(),
        );

        model.addCustomObserver(() {
          _getInject<T>(_name)?.rebuildInheritedWidget(null, null);
        });
      }
    }
    return model;
  }

  ///Use [getAsReactive] instead. It will be removed in next releases.
  @deprecated
  static ReactiveModel<T> getAsModel<T>(
      {dynamic name,
      BuildContext context,
      bool silent = false,
      bool asNewReactiveInstance = false,
      bool resetStateStatus = false}) {
    return getAsReactive<T>(
      name: name,
      context: context,
      silent: silent,
      asNewReactiveInstance: asNewReactiveInstance,
      keepCustomStateStatus: resetStateStatus,
    );
  }

  ///Get The registered reactive singleton with type $T or with name [name] if it is defined.
  ///
  /// If [context] is provided, the context-owning widget will be registered using [InheritedWidget].
  ///
  ///If no model is found, an error will be thrown. To silent it, set the parameter [silent] to true.
  ///
  ///To return a new reactive instance set [asNewReactiveInstance] to true. To pass the actual [ReactiveModel.customStateStatus] to
  ///the new reactive instance set [keepCustomStateStatus] to true.
  static ReactiveModel<T> getAsReactive<T>({
    dynamic name,
    BuildContext context,
    bool silent = false,
    bool asNewReactiveInstance = false,
    bool keepCustomStateStatus = false,
  }) {
    final String _name = name == null ? '$T' : name.toString();

    ReactiveModel<T> reactiveModel;

    final Inject<T> inject = _getInject<T>(_name, silent);

    if (inject == null) {
      return null;
    }

    if (!inject.isAsyncType && inject.getSingleton() is ReactiveModel) {
      reactiveModel = inject.getSingleton() as ReactiveModel<T>;
    } else {
      reactiveModel = (asNewReactiveInstance && context == null
          ? _getInject<T>(_name, silent)
              ?.getReactiveNewInstance(keepCustomStateStatus)
          : _getInject<T>(_name, silent)?.getReactiveSingleton());
    }
    if (context != null) {
      assert(
        () {
          if (name != null) {
            throw Exception(
              AssertMessage.getModelWithContextAndName<T>(
                'Injector.getAsReactive',
                '$name',
              ),
            );
          }
          return true;
        }(),
      );

      assert(
        () {
          if (asNewReactiveInstance == true) {
            throw Exception(
                AssertMessage.getNewReactiveInstanceWithContext<T>());
          }
          return true;
        }(),
      );
      final ReactiveModel<T> model = reactiveModel.of(context);

      assert(
        () {
          if (!silent && model == null) {
            throw Exception(
              AssertMessage.inheritedWidgetOfReturnsNull<T>(
                'Injector.getAsReactive',
              ),
            );
          }
          return true;
        }(),
      );

      assert(model == reactiveModel);
    }

    return reactiveModel;
  }

  static Inject<T> _getInject<T>(String name, [bool silent = false]) {
    final Inject<dynamic> model =
        InjectorState.allRegisteredModelInApp[name]?.last;
    assert(
      () {
        if (!silent && model == null) {
          throw Exception(AssertMessage.modelNotRegistered(
            name,
            '${InjectorState.allRegisteredModelInApp.keys}',
          ));
        }
        return true;
      }(),
    );

    return model as Inject<T>;
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

///State of Injector
class InjectorState extends State<Injector> {
  ///Map contains all the registered models of the app
  static final Map<String, List<Inject<dynamic>>> allRegisteredModelInApp =
      <String, List<Inject<dynamic>>>{};

  ///Map contains all the registered models of the app
  RegisterInjectedModel modelRegisterer;

  Widget _nestedInject;
  final List<Inject<dynamic>> _injects = <Inject<dynamic>>[];

  @override
  void initState() {
    super.initState();

    if (widget.inject != null) {
      for (Injectable inject in widget.inject) {
        _injects.add(inject as Inject<dynamic>);
      }
    }

    if (widget.reinject != null) {
      for (StatesRebuilder reactiveReinject in widget.reinject) {
        dynamic model;

        if (reactiveReinject is ReactiveModel<dynamic>) {
          model = reactiveReinject?.state;
        } else {
          model = model;
        }

        final Inject<dynamic> inject =
            allRegisteredModelInApp[model?.runtimeType?.toString()]?.first;

        assert(
          () {
            if (inject == null) {
              throw Exception('''

| ***Reinjected model not founded***
| The model you reinject is not found.
| It is most probably that you have registered the model with a custom name.
| 
| Rinjection of registered models with custom name is not allowed.
|
              ''');
            }
            return true;
          }(),
        );
        assert(inject.reactiveSingleton == reactiveReinject, '''
| ***Reinjecting new reactive instance***
| You are reinjecting a new reactive instance of [${model?.runtimeType}].
| New reactive instance can not be reinject, only reactive singleton that can be reinjected.
| 
| To use subscribe to new reactive instance use StateBuilder widget.
| 
|   ex:
|   final model = Injector.getAsReactive<${model?.runtimeType}]>(asNewReactiveInstance: true);
| 
|   return StateBuilder(
|     models: [model],
|     builder:(context,model){
|       ....
|     }
|   );
        ''');
        _injects.add(inject);
      }
    }

    modelRegisterer = RegisterInjectedModel(_injects, allRegisteredModelInApp);
    _injects
      ..clear()
      ..addAll(modelRegisterer.modelRegisteredByThis);

    if (widget.initState != null) {
      widget.initState();
    }
    if (widget.afterInitialBuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterInitialBuild(context),
      );
    }

    _nestedInject = Builder(
      builder: (BuildContext context) {
        return widget.builder(context);
      },
    );
    if (_injects.isNotEmpty) {
      for (Inject<dynamic> inject in _injects.reversed) {
        //Inject with name are not concerned with InheritedWidget
        if (inject.name == null) {
          _nestedInject = inject.inheritedInject(_nestedInject);
        }
      }
    }
  }

  @override
  void dispose() {
    modelRegisterer.unRegisterInjectedModels(widget.disposeModels);

    if (widget.dispose != null) {
      widget.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _nestedInject;
  }
}

///Stat of injector mixin with WidgetsBindingObserver
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
