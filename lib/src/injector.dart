import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/model_states_rebuilder.dart';
import 'package:states_rebuilder/src/register_injected_models.dart';
import 'package:states_rebuilder/src/state_builder.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';

class Injector<T extends StatesRebuilder> extends StatefulWidget {
  ///The builder closure. It takes as parameter the context and the registered generic model.
  final Widget Function(BuildContext, T) builder;

  ///List of models to register.
  final List<Function()> models;

  ///List of models to register.
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

  ///Function to execute in `initState` of the state. It takes as parameter the registered generic model.
  final void Function(T) initState;

  ///Function to execute in `dispose` of the state. It takes as parameter the registered generic model.
  final void Function(T) dispose;

  ///Function to track app life cycle state. It takes as parameter the registered generic model and the AppLifeCycleState.
  final void Function(T, AppLifecycleState) appLifeCycle;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context, String tagID) afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context, String tagID) afterRebuild;

  ///Set to true to dispose all models. The model should have instance method .`dispose`
  final bool disposeModels;

  Injector(
      {Key key,
      this.builder,
      this.models,
      this.inject,
      this.initState,
      this.dispose,
      this.appLifeCycle,
      this.afterInitialBuild,
      this.afterRebuild,
      this.disposeModels = false})
      : assert((models != null || inject != null) && builder != null),
        super(key: key);

  /// get the same singleton
  static T get<T>({dynamic name, BuildContext context, bool silent = false}) {
    String _name =
        name == null ? "$T".replaceAll(RegExp(r'<.*>'), "") : name.toString();
    T model =
        InjectorState.allRegisteredModelInApp[_name]?.last?.getSingleton();
    if (model == null) {
      if (!silent) {
        var _keys = InjectorState.allRegisteredModelInApp.keys;

        final message = "Model of type '$_name 'is not registered yet.\n"
            "You have to register the model before calling it.\n"
            "* To register the model use the `Injector` widget.\n"
            "* You can set the silent parameter to true to silent the error.\n"
            "***********************\n"
            "The list of registered models is : $_keys";
        throw Exception(message);
      }

      return null;
    }
    if (context != null && model is StatesRebuilder) {
      _markContextAsNeedsBuild(context, model);
    }
    return model;
  }

  ///get the same singletons as a `StatesRebuilder` model type
  static ModelStatesRebuilder<T> getAsModel<T>(
      {dynamic name, BuildContext context, bool silent = false}) {
    String _name =
        name == null ? "$T".replaceAll(RegExp(r'<.*>'), "") : name.toString();
    ModelStatesRebuilder model =
        InjectorState.allRegisteredModelInApp[_name]?.last?.getModelSingleton();
    if (model == null) {
      if (!silent) {
        var _keys = InjectorState.allRegisteredModelInApp.keys;

        final message = "Model of type '$_name 'is not registered yet.\n"
            "You have to register the model before calling it.\n"
            "* To register the model use the `Injector` widget.\n"
            "* You can set the silent parameter to true to silent the error.\n"
            "***********************\n"
            "The list of registered models is : $_keys";
        throw Exception(message);
      }
      return null;
    }
    if (context != null) {
      _markContextAsNeedsBuild(context, model);
    }
    return model;
  }

  /// get a new instance
  T getNew<T>({dynamic name, BuildContext context}) {
    String _name =
        name == null ? "$T".replaceAll(RegExp(r'<.*>'), "") : name.toString();
    final model =
        InjectorState.allRegisteredModelInApp[_name]?.last?.getInstance();

    if (context != null && model is StatesRebuilder) {
      _markContextAsNeedsBuild(context, model);
    }
    return model;
  }

  ///get the a new instance as a `StatesRebuilder` model type
  static ModelStatesRebuilder<T> getNewAsModel<T>([dynamic name]) {
    String _name =
        name == null ? "$T".replaceAll(RegExp(r'<.*>'), "") : name.toString();
    return InjectorState.allRegisteredModelInApp[_name]?.last
        ?.getModelInstance();
  }

  static void _markContextAsNeedsBuild(
      BuildContext context, StatesRebuilder model) {
    if (model.customListener.containsKey(context)) return;
    final fn = () {
      try {
        (context as Element).markNeedsBuild();
      } catch (e) {
        model.customListener.remove(context);
      }
    };
    model.customListener[context] = fn;
    model.cleaner(() {
      model.customListener.remove(context);
    });
  }

  @override
  State<Injector<T>> createState() {
    if (appLifeCycle == null) {
      return InjectorState<T>();
    } else {
      return InjectorStateAppLifeCycle<T>();
    }
  }
}

class InjectorState<T extends StatesRebuilder> extends State<Injector<T>> {
  //Map contains all the registered models of the app
  static final allRegisteredModelInApp = new Map<String, List<Inject>>();

  RegisterInjectedModel modelRegisterer;
  @override
  void initState() {
    super.initState();

    final _models = List<Inject>();
    if (widget.models != null) {
      _models.addAll(widget.models.map((fn) => Inject(fn)));
    }
    if (widget.inject != null) {
      widget.inject.forEach((e) {
        _models.add(e as Inject);
      });
    }
    modelRegisterer = RegisterInjectedModel(_models, allRegisteredModelInApp);
  }

  @override
  void dispose() {
    modelRegisterer.unRegisterInjectedModels(widget.disposeModels);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    T model;
    String name = "$T";
    if (name.contains("ModelStatesRebuilder")) {
      name = name.replaceAll("ModelStatesRebuilder<", "").replaceAll(">", "");
      model = Injector.getAsModel(silent: true, name: name) as T;
    } else {
      model = T != StatesRebuilder ? Injector.get<T>(silent: true) : null;
    }
    return StateBuilder(
      viewModels: [model],
      initState: (_, __) {
        if (widget.initState != null) {
          widget.initState(model);
        }
        model?.rebuildStates();
      },
      dispose: (_, __) {
        if (widget.dispose != null) {
          widget.dispose(model);
        }
      },
      afterInitialBuild: (context, tagID) {
        if (widget.afterInitialBuild != null)
          widget.afterInitialBuild(context, tagID);
      },
      afterRebuild: (context, tagID) {
        if (widget.afterRebuild != null) widget.afterRebuild(context, tagID);
      },
      builder: (context, _) => widget.builder(context, model),
    );
  }
}

class InjectorStateAppLifeCycle<T extends StatesRebuilder>
    extends InjectorState<T> with WidgetsBindingObserver {
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
    final model = T != StatesRebuilder ? Injector.get<T>() : null;
    widget.appLifeCycle(model, state);
  }
}
