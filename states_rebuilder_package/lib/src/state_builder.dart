import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/rm_key.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'assertions.dart';

import 'injector.dart';
import 'reactive_model.dart';
import 'states_rebuilder.dart';

/// You wrap any part of your widgets with [StateBuilder] Widget to make it Reactive.
/// When [StatesRebuilder.rebuildStates] method is called, it will rebuild.
class StateBuilder<T> extends StatefulWidget {
  ///```dart
  ///StateBuilder(
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state.
  ///
  ///The builder is provided with a [BuildContext] and [ReactiveModel] parameters.
  final Widget Function(BuildContext context, ReactiveModel<T> model) builder;

  ///List of observable classes to which you want [StateBuilder] to subscribe.
  ///```dart
  ///StateBuilder(
  ///  models:[myModel1, myModel2, myModel3],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///states_rebuilder uses the observer pattern.
  ///
  ///Observable classes are classes that extends [StatesRebuilder].
  ///[ReactiveModel] is one of them.
  ///
  ///For the sake of performance consider using [observe] or [observeMany] instead.
  final List<StatesRebuilder> models;

  ///an observable class to which you want [StateBuilder] to subscribe.
  ///```dart
  ///StateBuilder(
  ///  observe:()=> myModel1,
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///states_rebuilder uses the observer pattern.
  ///
  ///Observable classes are classes that extends [StatesRebuilder].
  ///[ReactiveModel] is one of them.
  final StatesRebuilder<T> Function() observe;

  ///List of observable classes to which you want [StateBuilder] to subscribe.
  ///```dart
  ///StateBuilder(
  ///  observeMany:[()=> myModel1,()=> myModel2,()=> myModel3],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///states_rebuilder uses the observer pattern.
  ///
  ///Observable classes are classes that extends [StatesRebuilder].
  ///[ReactiveModel] is one of them.
  final List<StatesRebuilder Function()> observeMany;
  final List<StatesRebuilder> activeRM = [];

  ///A tag or list of tags you want this [StateBuilder] to register with.
  ///
  ///Whenever any of the observable model to which this [StateBuilder] is subscribed emits
  ///a notifications with a list of filter tags, this [StateBuilder] will rebuild if the
  ///the filter tags list contains at least on of those tags.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  ///
  ///Each [StateBuilder] has a default tag which is its [BuildContext]
  final dynamic tag;

  ///```dart
  ///StateBuilder(
  ///  initState:(BuildContext context, ReactiveModel model)=> myModel.init([context,model]),
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  final void Function(BuildContext context, ReactiveModel<T> model) initState;

  ///```dart
  ///StateBuilder(
  ///  dispose:(BuildContext context, ReactiveModel model) {
  ///     myModel.dispose([context, model]);
  ///   },
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  final void Function(BuildContext context, ReactiveModel<T> model) dispose;

  ///```dart
  ///StateBuilder(
  ///  didChangeDependencies:(BuildContext context, ReactiveModel model) {
  ///     //...your code
  ///   },
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  final void Function(BuildContext context, ReactiveModel<T> model)
      didChangeDependencies;

  ///```dart
  ///StateBuilder(
  ///  didUpdateWidget:(BuildContext context, ReactiveModel model,StateBuilder oldWidget) {
  ///     myModel.dispose([context, model]);
  ///   },
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  final void Function(BuildContext context, ReactiveModel<T> model,
      StateBuilder<T> oldWidget) didUpdateWidget;

  ///Called after the widget is first inserted in the widget tree.
  final void Function(BuildContext context, ReactiveModel<T> model)
      afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context, ReactiveModel<T> model)
      afterRebuild;

  ///if it is set to true all observable models will be disposed.
  ///
  ///Models are disposed by calling the 'dispose()' method if exists.
  ///
  ///In any of the injected class you can define a 'dispose()' method to clean up resources.
  final bool disposeModels;

  ///```dart
  ///StateBuilder(
  ///  models:[myModel],
  ///  builderWithChild:(BuildContext context, ReactiveModel model, Widget child) =>MyWidget(child),
  ///  child : MyChildWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state with child parameter.
  ///
  ///The builder is provided with a [BuildContext], [ReactiveModel] and [Widget] parameters.
  final Widget Function(
          BuildContext context, ReactiveModel<T> model, Widget child)
      builderWithChild;

  ///The child to be used in [builderWithChild].
  final Widget child;

  ///Called whenever this widget is notified.
  final dynamic Function(BuildContext context, ReactiveModel<T> model)
      onSetState;

  /// Called whenever this widget is notified and after rebuilding the widget.
  final void Function(BuildContext context, ReactiveModel<T> model)
      onRebuildState;

  ///A function that returns a one instance variable or a list of
  ///them. The rebuild process will be triggered if at least one of
  ///the return variable changes.
  ///
  ///Return variable must be either a primitive variable, a List, a Map or a Set.
  ///
  ///To use a custom type, you should override the `toString` method to reflect
  ///a unique identity of each instance.
  ///
  ///If it is not defined all listener will be notified when a new state is available.
  final Object Function(ReactiveModel<T> model) watch;

  ///ReactiveModel key used to control this widget from outside its [builder] method.
  final RMKey rmKey;

  StateBuilder({
    Key key,
    // For state management
    this.builder,
    this.models,
    this.observe,
    this.observeMany,
    this.tag,
    this.builderWithChild,
    this.child,
    this.onSetState,
    this.onRebuildState,
    this.watch,
    this.rmKey,

    // For state lifecycle
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.afterInitialBuild,
    this.afterRebuild,
    this.disposeModels,
  })  : assert(builder != null || builderWithChild != null, '''
  
  | ***Builder not defined*** 
  | You have to define either 'builder' or 'builderWithChild' parameter.
  | Use 'builderWithChild' with 'child' parameter. 
  | If 'child' is null use 'builder' instead.
  
        '''),
        assert(builderWithChild == null || child != null, '''
  | ***child is null***
  | You have defined the 'builderWithChild' parameter without defining the child parameter.
  | Use 'builderWithChild' with 'child' parameter. 
  | If 'child' is null use 'builder' instead.
  
        '''),
        super(key: key);
  @override
  StateBuilderState createState() => StateBuilderState<T>();
}

class StateBuilderState<T> extends State<StateBuilder<T>>
    with ObserverOfStatesRebuilder {
  Set<StatesRebuilder> _models;
  Set<StatesRebuilder Function()> _modelsCallBacks = {};
  String autoGeneratedTag;
  ReactiveModel<T> _exposedModelFromGenericType;
  ReactiveModel<dynamic> _exposedModelFromNotification;
  ReactiveModel<dynamic> get _exposedModel => T == dynamic
      ? _exposedModelFromNotification ?? _exposedModelFromGenericType
      : _exposedModelFromGenericType;

  @override
  void initState() {
    super.initState();
    autoGeneratedTag = 'AutoGeneratedTag#|:${context.hashCode}';
    if (widget.models != null) {
      for (var model in widget.models) {
        _modelsCallBacks.add(() => model);
      }
    }
    if (widget.observe != null) {
      _modelsCallBacks.add(widget.observe);
    }
    if (widget.observeMany != null) {
      _modelsCallBacks.addAll(widget.observeMany);
    }

    _initState();
    if (widget.initState != null) {
      widget.initState(context, _exposedModel);
    }
    if (widget.afterInitialBuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterInitialBuild(context, _exposedModel),
      );
    }
    if (widget.watch != null) {
      _cashedWatch = widget.watch(_exposedModel).toString();
    }
  }

  void _resolveModels([bool reRegister = false]) {
    if (_modelsCallBacks.isEmpty) {
      if (widget.models == null) {
        if (T == dynamic) {
          throw Exception(AssertMessage.noModelsAndDynamicType());
        }
        _exposedModelFromGenericType =
            Injector.getAsReactive<T>()?.inject?.getReactive(true);
        _subscribe(_exposedModelFromGenericType);
      }
      return;
    }
    final _modelsList = _models?.toList();
    _models = {};
    int i = 0;
    for (var fn in _modelsCallBacks) {
      if (reRegister) {
        final m = fn?.call();
        _modelsList[i].copy(m);
        _models.add(m);
      } else {
        _models.add(fn?.call());
      }
      i++;
    }
    widget.activeRM.clear();
    widget.activeRM.addAll(_models.toList());

    if (T != dynamic) {
      for (var model in _models) {
        if (model is ReactiveModel<T>) {
          _exposedModelFromGenericType = model;
          return;
        }
      }
    }
    if (_models.first is ReactiveModel<T>) {
      _exposedModelFromGenericType = _models?.first;
      return;
    }
  }

  void Function(ReactiveModel) _rmKeyInitCallback;

  void _initState() {
    _resolveModels();

    if (_models == null) {
      return;
    }
    for (var model in _models) {
      assert(model != null);
      _subscribe(model);

      if (model is RMKey && !model.isLinked) {
        model.initCallBack.add(_rmKeyInitCallback = (rm) {
          model.rm.copy(rm);
          Future.microtask(() => setState(() {}));
        });
      }
    }
    if (widget.rmKey != null) {
      widget.rmKey.rm = _exposedModel;
      widget.rmKey.refreshCallBack = (rm) {
        _exposedModelFromGenericType = null;
        _exposedModelFromNotification = null;
        _resolveModels(true);
        widget.rmKey.rm = _exposedModel;
      };
    }
  }

  void _subscribe(StatesRebuilder model) {
    model?.addObserver(observer: this, tag: autoGeneratedTag);
    if (widget.tag != null) {
      if (widget.tag is List) {
        for (var tag in widget.tag) {
          model?.addObserver(observer: this, tag: tag.toString());
        }
      } else {
        model?.addObserver(observer: this, tag: widget.tag.toString());
      }
    }
  }

  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose(context, _exposedModelFromGenericType);
    }
    _dispose();
    if (widget.rmKey != null) {
      widget.rmKey.refreshCallBack = null;
    }
    super.dispose();
  }

  void _dispose() {
    _exposedModelFromGenericType?.inject
        ?.removeFromReactiveNewInstanceList(_exposedModelFromGenericType);
    if (_models == null) {
      return;
    }
    for (var model in _models) {
      if (model is RMKey) {
        model.initCallBack.add(_rmKeyInitCallback);
      }
      _unsubscribe(model);
    }
    _exposedModelFromGenericType = null;
    _exposedModelFromNotification = null;
  }

  _unsubscribe(StatesRebuilder model) {
    if (widget.disposeModels == true) {
      try {
        if (model != null) {
          (model as dynamic)?.dispose();
        }
      } catch (e) {
        if (e is! NoSuchMethodError) {
          rethrow;
        }
      }
    }
    model?.removeObserver(observer: this, tag: autoGeneratedTag);
    if (widget.tag != null) {
      if (widget.tag is List) {
        for (var tag in widget.tag) {
          model?.removeObserver(observer: this, tag: tag.toString());
        }
      } else {
        model?.removeObserver(observer: this, tag: widget.tag.toString());
      }
    }
  }

  String _cashedWatch = '';
  String _actualWatch = '';
  @override
  bool update(
      [dynamic Function(BuildContext) onSetState, dynamic reactiveModel]) {
    if (!mounted) {
      return false;
    }
    _exposedModelFromNotification = reactiveModel;

    bool canRebuild = true;
    if (widget.watch != null) {
      _actualWatch = widget.watch(_exposedModel).toString();
      canRebuild = _actualWatch.hashCode != _cashedWatch.hashCode;
      _cashedWatch = _actualWatch;
    }

    if (canRebuild == false) {
      return true;
    }

    if (widget.onSetState != null) {
      widget.onSetState(context, _exposedModel);
    } else if (onSetState != null) {
      onSetState(context);
    }

    if (widget.onRebuildState != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onRebuildState(context, _exposedModel),
      );
    }
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.afterRebuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterRebuild(context, _exposedModel),
      );
    }

    if (widget.builderWithChild != null) {
      return widget.builderWithChild(context, _exposedModel, widget.child);
    }
    return widget.builder(context, _exposedModel);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null)
      widget.didChangeDependencies(context, _exposedModel);
  }

  @override
  void didUpdateWidget(StateBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (this is StateBuilderState<Injector>) {
      return;
    }

    if (widget.rmKey != null) {
      widget.rmKey.rm = _exposedModel;
    }

    if (_models != null) {
      widget.activeRM.clear();
      widget.activeRM.addAll(_models.toList());
    }

    if (widget.didUpdateWidget != null) {
      widget.didUpdateWidget(context, _exposedModel, oldWidget);
    }
  }
}
