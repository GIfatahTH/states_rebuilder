import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/register_injected_models.dart';
import 'package:states_rebuilder/src/state_builder.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';

class InjectorState<T extends StatesRebuilder> extends State<Injector<T>> {
  //Map contains all the registered models of the app
  static final allRegisteredModelInApp = new Map<String, List<Inject>>();

  RegisterInjectedModel modelRegisterer;
  @override
  void initState() {
    super.initState();

    final _models = List<Inject<dynamic>>();
    if (widget.models != null) {
      _models.addAll(widget.models.map((fn) => Inject(fn)));
    }
    if (widget.inject != null) {
      _models.addAll(widget.inject);
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
    final model = T != StatesRebuilder ? Injector.get<T>() : null;
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
