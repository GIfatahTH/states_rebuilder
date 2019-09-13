import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/injector_state.dart';
import 'package:states_rebuilder/src/inject.dart';

import '../states_rebuilder.dart';

class Injector<T extends StatesRebuilder> extends StatefulWidget {
  ///The builder closure. It takes as parameter the context and the registered generic model.
  final Widget Function(BuildContext, T) builder;

  ///List of models to register.
  final List<Function()> models;

  ///List of models to register. Inject is preferred if you want to register with an interface
  final List<Inject> inject;

  ///Function to execute in `initState` of the state. It takes as parameter the registered generic model.
  final Function(T) initState;

  ///Function to execute in `dispose` of the state. It takes as parameter the registered generic model.
  final Function(T) dispose;

  ///Function to track app life cycle state. It takes as parameter the registered generic model and the AppLifeCycleState.
  final Function(T, AppLifecycleState) appLifeCycle;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context, String tagID) afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context, String tagID) afterRebuild;

  ///Set to true to dispose all models. The model should have instance method .`dispose`
  final bool disposeModels;

  Injector(
      {this.builder,
      this.models,
      this.inject,
      this.initState,
      this.dispose,
      this.appLifeCycle,
      this.afterInitialBuild,
      this.afterRebuild,
      this.disposeModels = false})
      : assert((models != null || inject != null) && builder != null);

  // Inject the same singleton
  static T get<T>([String name, void Function(String) errorLogger]) {
    String _name = name == null ? "$T".replaceAll(RegExp(r'<.*>'), "") : name;
    T model =
        InjectorState.allRegisteredModelInApp[_name]?.last?.getSingleton();
    if (model == null) {
      var _keys = InjectorState.allRegisteredModelInApp.keys;

      final message = "Model of type '$_name 'is not registered yet.\n"
          "You have to register the model before calling it.\n"
          "To register the model use the `Injector` widget.\n"
          "The list of registered models is : $_keys";
      if (errorLogger == null) {
        print(message);
      } else {
        errorLogger(message);
      }
      return null;
    }
    return model;
  }

  /// Inject a new instance
  static T getNew<T>([String name]) {
    String _name = name == null ? "$T".replaceAll(RegExp(r'<.*>'), "") : name;

    return InjectorState.allRegisteredModelInApp[_name]?.last?.getInstance();
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
