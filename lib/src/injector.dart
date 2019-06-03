import 'package:flutter/material.dart';
import 'states_rebuilder.dart';

class _ServiceFactory {
  Function() creationFunction;
  Object instance;

  _ServiceFactory({this.creationFunction, this.instance});

  getObject(bool isfactory) {
    if (instance == null) {
      instance = creationFunction();
    }
    if (isfactory) {
      return creationFunction();
    }
    return instance;
  }
}

class Injector extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final List<Function()> models;
  Injector(
      {this.builder, this.models, this.dispose, this.disposeViewModels = false})
      : assert(models != null && builder != null);

  final VoidCallback dispose;
  final bool disposeViewModels;

  // Inject the same singleton
  static T singleton<T>([String name]) => _InjectorState._get<T>(false, name);

  /// Inject a new instance
  static T instance<T>([String name]) => _InjectorState._get<T>(true, name);

  @override
  _InjectorState createState() => _InjectorState();
}

class _InjectorState extends State<Injector> {
  final vm = new Map<String, _ServiceFactory>();

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
      vm[_modelName] = _ServiceFactory(
          creationFunction: creationFunction, instance: instance);
      _modelsMap.addAll(vm);
    });
  }

  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose();
    }
    if (widget.disposeViewModels) {
      vm.forEach((k, v) {
        if (v.instance is StatesRebuilder) {
          (v.instance as StatesRebuilder).dispose();
        }
      });
    }
    vm.forEach((k, v) {
      _modelsMap[k] = null;
      _modelsMap.remove(k);
    });
    super.dispose();
  }

  static final _modelsMap = new Map<String, _ServiceFactory>();

  static T _get<T>(bool isFactory, [String name]) {
    _ServiceFactory object;
    if (name != null) {
      name = "$T-$name";
      object = _modelsMap[name];
    } else {
      name = "$T";
      object = _modelsMap[name];
    }

    if (object == null) {
      var _models = _modelsMap.keys;
      print("Model of type '$name 'is not registered inside yet.\n"
          "You have to registere the model before calling it.\n"
          "To registere the model use the `Injector` widget.\n"
          "The list of registered models is : $_models");
      return null;
    }

    return object.getObject(isFactory) as T;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
