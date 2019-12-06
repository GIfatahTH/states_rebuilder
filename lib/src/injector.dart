import 'package:flutter/material.dart';

import 'inject.dart';
import 'reactive_model.dart';
import 'register_injected_models.dart';
import 'states_rebuilder.dart';

///A class used to register (inject) models.
class Injector extends StatefulWidget {
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
        assert(inject != null || reinject != null),
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

    final Inject<dynamic> inject = _getInject(_name, silent);

    if (inject == null) {
      return null;
    }

    if (inject.isAsyncType == true) {
      throw Exception(
          'get method is not allowed with stream and future injection. Use getAsReactive');
    }

    final model = inject?.getSingleton();

    if (context != null) {
      if (model is StatesRebuilder) {
        if (name != null) {
          throw Exception(
              'You are using the context to register it to the InheritedWidget of type $T.'
              'You can not use both context and name parameters');
        }

        final inheritedWidget = ReactiveModel.staticOf<T>(context);
        if (inheritedWidget == null && silent) {
          throw Exception('No model is registered with type $T');
        }
        model.addCustomObserver(() {
          _getInject(_name)?.rebuildInheritedWidget(null, null);
        });
      } else {
        throw Exception('The class $T does not extend StatesRebuilder.'
            'Try removing the context parameter or make your class extends StatesRebuilder');
      }
    }
    return model;
  }

  ///Use [getAsReactive] instead. It will be removed in next releases.
  @Deprecated('use gatAsModel instead')
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
    assert(() {
      if (asNewReactiveInstance == true && context != null) {
        throw Exception(
            'Avoid getting new instance of the model with the context defined\n'
            'You can remove the [context] parameter and use [SatesBuilder] to register the model');
      }
      return true;
    }());

    final String _name = name == null ? '$T' : name.toString();

    ReactiveModel<T> reactiveModel;

    final Inject<dynamic> inject = _getInject(_name, silent);

    if (inject == null) {
      return null;
    }

    if (!inject.isAsyncType && inject.getSingleton() is ReactiveModel) {
      reactiveModel = inject.getSingleton();
    } else {
      reactiveModel = asNewReactiveInstance && context == null
          ? _getInject(_name, silent)
              ?.getReactiveNewInstance(keepCustomStateStatus)
          : _getInject(_name, silent)?.getReactiveSingleton();
    }
    if (context != null) {
      if (name != null) {
        throw Exception(
            'You are using the context to register it to the InheritedWidget of type $T.'
            'You can not use both context and name parameters');
      }
      final ReactiveModel<T> model = reactiveModel.of(context);

      if (model == null && !silent) {
        throw Exception('No model is registered with type $T');
      }

      assert(model == reactiveModel);
    }

    return reactiveModel;
  }

  static Inject<dynamic> _getInject(String name, [bool silent = false]) {
    final model = InjectorState.allRegisteredModelInApp[name]?.last;
    if (model == null) {
      if (!silent) {
        final Iterable<String> _keys =
            InjectorState.allRegisteredModelInApp.keys;

        final String message = 'Model of type "$name" is not registered yet.\n'
            'You have to register the model before calling it.\n'
            '* To register the model use the `Injector` widget.\n'
            '* You can set the silent parameter to true to silent the error.\n'
            '***********************\n'
            'The list of registered models is : $_keys';
        throw Exception(message);
      }

      return null;
    }
    return model;
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
  //Map contains all the registered models of the app
  static final Map<String, List<Inject<dynamic>>> allRegisteredModelInApp =
      <String, List<Inject<dynamic>>>{};

  RegisterInjectedModel modelRegisterer;

  Widget _nestedInject;
  final List<Inject<dynamic>> _injects = <Inject<dynamic>>[];

  @override
  void initState() {
    super.initState();

    if (widget.inject != null) {
      widget.inject.forEach(_injects.add);
    }

    if (widget.reinject != null) {
      for (StatesRebuilder reactiveModel in widget.reinject) {
        dynamic model;

        if (reactiveModel is ReactiveModel<dynamic>) {
          model = reactiveModel?.state;
        } else {
          model = model;
        }

        final Inject inject =
            allRegisteredModelInApp[model?.runtimeType?.toString()]?.first;
        if (inject != null) {
          _injects.add(inject);
        }
      }
    }

    modelRegisterer = RegisterInjectedModel(_injects, allRegisteredModelInApp);
    _injects.clear();
    _injects.addAll(modelRegisterer.modelRegisteredByThis);

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
  void dispose() {
    modelRegisterer.unRegisterInjectedModels(widget.disposeModels);

    if (widget.dispose != null) {
      widget.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nestedInject = Builder(
      builder: (BuildContext context) => widget.builder(context),
    );
    if (_injects.isNotEmpty) {
      for (Inject inject in _injects.reversed) {
        //Inject with name are not concerned with InheritedWidget
        if (inject.name == null) {
          _nestedInject = inject.inheritedInject(_nestedInject);
        }
      }
    }
    return _nestedInject;
  }
}

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
