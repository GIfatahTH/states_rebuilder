import 'package:flutter/material.dart';

class Injector extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final List<Function()> models;
  Injector(
      {this.builder, this.models, this.dispose, this.disposeModels = false})
      : assert(models != null && builder != null);

  final VoidCallback dispose;
  final bool disposeModels;

  // Inject the same singleton
  static T get<T>([String name]) => _InjectorState._get<T>(false, name);

  /// Inject a new instance
  static T getNew<T>([String name]) => _InjectorState._get<T>(true, name);

  @override
  _InjectorState createState() => _InjectorState();
}

class _InjectorState extends State<Injector> {
  final vm = new Map<String, _Model>();

  @override
  void initState() {
    super.initState();
    widget.models.forEach((m) {
      String _modelName;
      Function creationFunction;
      var instance;
      var element = m();
      if (element is List) {
        if (element.length != 2 ||
            // !(element[0] is Function) ||
            !(element[1] is String)) {
          throw FlutterError(
              "The list length must be 2, and the first element must be a Function and the second a String");
        } else {
          instance = element[0];
          _modelName = "${instance.runtimeType}-" + element[1];
          creationFunction = () => m()[0];
        }
      } else {
        instance = element;
        _modelName = "${instance.runtimeType}";
        creationFunction = m;
      }
      assert(() {
        if (_modelsMap.containsKey(_modelName)) {
          throw FlutterError("the model $_modelName is already registred");
        }
        return true;
      }());
      vm[_modelName] =
          _Model(creationFunction: creationFunction, instance: instance);
      _modelsMap.addAll(vm);
    });
  }

  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose();
    }
    if (widget.disposeModels) {
      vm.forEach((k, v) {
        try {
          v.instance?.dispose();
        } catch (e) {
          if ('$e'.contains(
              "AnimationController.dispose() called more than once")) {
            print(e);
          } else {
            print(
                "You have set the parameter `disposeModels` of Injector to true.\n"
                "Your model must have a dispose() method\n"
                "If you are registering many models, and you want only a set of them to be dispsed,\n"
                "wrap them inside another nested Injector widget and set  the parameter `disposeModels` to true\n");
            rethrow;
          }
        }
      });
    }
    vm.forEach((k, v) {
      _modelsMap[k] = null;
      _modelsMap.remove(k);
    });
    super.dispose();
  }

  static final _modelsMap = new Map<String, _Model>();

  static T _get<T>(bool getNew, [String name]) {
    _Model _model;
    if (name != null) {
      name = "$T-$name";
      _model = _modelsMap[name];
    } else {
      name = "$T";
      _model = _modelsMap[name];
    }

    if (_model == null) {
      var _models = _modelsMap.keys;
      print("Model of type '$name 'is not registered yet.\n"
          "You have to registere the model before calling it.\n"
          "To registere the model use the `Injector` widget.\n"
          "The list of registered models is : $_models");
      return null;
    }

    if (getNew) {
      return _model.creationFunction() as T;
    }
    return _model.instance as T;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

class _Model {
  final Function() creationFunction;
  final instance;

  _Model({this.creationFunction, this.instance});
}
