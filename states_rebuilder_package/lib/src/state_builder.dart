import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'assertions.dart';
import 'injector.dart';
import 'on_set_state_listener.dart';
import 'reactive_model.dart';
import 'reactive_model_imp.dart';
import 'rm_key.dart';
import 'states_rebuilder.dart';
import 'when_connection_state.dart';
import 'when_rebuilder_or.dart';

/// One of the four observer widgets in states_rebuilder
///
/// [WhenRebuilder], [WhenRebuilderOr] and [OnSetStateListener]
///
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
  // final List<StatesRebuilder> models;TODO

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

  ///Active ReactiveModel used in WhenRebuilder and WhenRebuilderOr
  final List<ReactiveModel> activeRM;

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
  final void Function(BuildContext context, ReactiveModel<T> model) didChangeDependencies;

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
  final void Function(BuildContext context, ReactiveModel<T> model, StateBuilder<T> oldWidget) didUpdateWidget;

  ///Called after the widget is first inserted in the widget tree.
  final void Function(BuildContext context, ReactiveModel<T> model) afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context, ReactiveModel<T> model) afterRebuild;

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
  final Widget Function(BuildContext context, ReactiveModel<T> model, Widget child) builderWithChild;

  ///The child to be used in [builderWithChild].
  final Widget child;

  ///Called whenever this widget is notified.
  final dynamic Function(BuildContext context, ReactiveModel<T> model) onSetState;

  /// Called whenever this widget is notified and after rebuilding the widget.
  final void Function(BuildContext context, ReactiveModel<T> model) onRebuildState;

  /// callback to be executed before notifying listeners. It the returned value is
  /// the same as the last one, the rebuild process is interrupted.
  ///
  final Object Function(ReactiveModel<T> model) watch;

  ///ReactiveModel key used to control this widget from outside its [builder] method.
  final RMKey rmKey;

  /// One of the four observer widgets in states_rebuilder
  ///
  /// [WhenRebuilder], [WhenRebuilderOr] and [OnSetStateListener]
  const StateBuilder({
    Key key,
    // For state management
    this.builder,
    // this.models,
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
    //Holds a list of resolved ReactiveModel (used internally in states_rebuilder)
    //TO IMPROVE
    this.activeRM,
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

class StateBuilderState<T> extends State<StateBuilder<T>> with ObserverOfStatesRebuilder {
  Set<StatesRebuilder> _models;
  String _autoGeneratedTag;
  ReactiveModel<T> _exposedModelFromGenericType;
  ReactiveModel<T> _exposedModelFromNotification;
  ReactiveModel<T> get _exposedModel =>
      T == dynamic ? _exposedModelFromNotification ?? _exposedModelFromGenericType : _exposedModelFromGenericType;

  @override
  void initState() {
    super.initState();
    InjectorState.contextSet.add(context);
    _autoGeneratedTag = 'AutoGeneratedTag#|:${context.hashCode}';
    _initState(this);

    if (widget.initState != null) {
      widget.initState(context, _exposedModel);
    }
    if (widget.afterInitialBuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterInitialBuild(context, _exposedModel),
      );
    }
    if (widget.watch != null) {
      _cashedWatch = widget.watch(_exposedModel);
    }
  }

  // void Function(ReactiveModel) _rmKeyInitCallback;

  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose(context, _exposedModelFromGenericType);
    }
    _dispose<T>(this);
    _models = null;
    _exposedModelFromGenericType = null;
    _exposedModelFromNotification = null;
    _cashedWatch = null;
    _actualWatch = null;
    InjectorState.contextSet.remove(context);
    super.dispose();
  }

  dynamic _cashedWatch;
  dynamic _actualWatch;
  int _numberOfRebuild = 0;
  @override
  void update([dynamic Function(BuildContext) onSetState, dynamic reactiveModel]) {
    if (!mounted) {
      return;
    }
    _exposedModelFromNotification = reactiveModel is ReactiveModel<T> ? reactiveModel : null;

    bool canRebuild = true;
    if (widget.watch != null) {
      _actualWatch = widget.watch(_exposedModel);

      canRebuild = !(const DeepCollectionEquality().equals(_actualWatch, _cashedWatch));

      _cashedWatch = _actualWatch;
    }

    if (canRebuild == false) {
      return;
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
    setState(() {
      assert(() {
        if (RM.debugWidgetsRebuild == true && _exposedModelFromNotification != null) {
          String observer = 'StateBuilder';
          if (widget.builderWithChild == null && widget.child != null) {
            if (widget.child is Text) {
              final data = (widget.child as Text).data;
              if (data.contains('#|0|#')) {
                observer = 'WhenRebuilder';
              } else if (data.contains('#|1|#')) {
                observer = 'WhenRebuilderOr';
              }
            }
          }
          final status = _exposedModelFromNotification?.whenConnectionState(
            onIdle: () => 'isIdle',
            onWaiting: () => 'isWaiting',
            onData: (T _) => 'hasData',
            onError: (dynamic _) => 'hasError',
            catchError: false,
          );
          final name = widget.key != null ? '${widget.key} | ' : '';

          developer.log(
            '$observer($hashCode) |'
            '$name'
            '${_exposedModelFromNotification?.type()}($status)',
            name: 'states_rebuilder Widget Rebuild',
            error: '|# ${++_numberOfRebuild} #| rebuild times',
          );
        }
        return true;
      }());
    });
  }

  void _setState() => setState(() {});

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
    if (widget.didChangeDependencies != null) widget.didChangeDependencies(context, _exposedModel);
  }

  @override
  void didUpdateWidget(StateBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rmKey != null) {
      oldWidget.rmKey.rm = null;
      oldWidget.rmKey.initialValue = null;
      oldWidget.rmKey.initCallBack = null;
      widget.rmKey.rm = _exposedModel;
      _models?.where((m) => m is ReactiveModel)?.forEach((rm) {
        widget.rmKey.associate(rm);
      });
    }
    if (this is StateBuilderState<Injector>) {
      return;
    }

    if (_models != null && widget.activeRM != null) {
      widget.activeRM.clear();
      widget.activeRM.addAll(
        _models.where((m) => m is ReactiveModel).cast<ReactiveModel>(),
      );
    }

    if (widget.didUpdateWidget != null) {
      widget.didUpdateWidget(context, _exposedModel, oldWidget);
    }
  }
}

void _initState<T>(StateBuilderState<T> state) {
  final widget = state.widget;
  Set<StatesRebuilder Function()> _modelsCallBacks;

  void subscribe<T>(StatesRebuilder model) {
    model?.addObserver(observer: state, tag: state._autoGeneratedTag);
    if (widget.tag != null) {
      if (widget.tag is List) {
        for (var tag in widget.tag) {
          model?.addObserver(observer: state, tag: tag.toString());
        }
      } else {
        model?.addObserver(observer: state, tag: state.widget.tag.toString());
      }
    }
  }

  void _resolveModels<T>(StateBuilderState<T> state, [bool reRegister = false]) {
    if (_modelsCallBacks == null || _modelsCallBacks.isEmpty) {
      if (widget.observe == null && widget.observeMany == null) {
        if (T == dynamic) {
          throw Exception(AssertMessage.noModelsAndDynamicType());
        }
        state._exposedModelFromGenericType =
            (Injector.getAsReactive<T>() as ReactiveModelImp<T>)?.inject?.getReactive(true);

        subscribe<T>(state._exposedModelFromGenericType);
        return;
      }
      return;
    }

    final List<StatesRebuilder<dynamic>> _modelsList = state._models?.toList();
    state._models = {};
    int i = 0;
    for (var fn in _modelsCallBacks) {
      if (reRegister) {
        final m = fn?.call();
        _modelsList[i].copy(m);
        state._models.add(m);
      } else {
        state._models.add(fn?.call());
      }
      i++;
    }
    if (widget.activeRM != null) {
      state.widget.activeRM.clear();
      state.widget.activeRM.addAll(
        state._models.where((m) => m is ReactiveModel).cast<ReactiveModel>(),
      );
    }

    if (widget.observe != null) {
      if (state._models.first is! ReactiveModel<T>) {
        return;
      }
      state._exposedModelFromGenericType = state._models.first as ReactiveModel<T>;
      return;
    }
    if (T != dynamic) {
      for (var model in state._models) {
        if (model is ReactiveModel<T>) {
          state._exposedModelFromGenericType = model;
          return;
        }
      }
    }
    if (state._models.first is ReactiveModel<T>) {
      state._exposedModelFromGenericType = state._models.first as ReactiveModel<T>;
      return;
    }
  }

  if (widget.observe != null) {
    _modelsCallBacks ??= {};
    _modelsCallBacks.add(widget.observe);
  }
  if (widget.observeMany != null) {
    _modelsCallBacks ??= {};
    _modelsCallBacks.addAll(widget.observeMany);
    widget.observeMany.clear();
  }

  _resolveModels(state);

  if (state._models == null) {
    return;
  }

  for (StatesRebuilder model in state._models) {
    assert(model != null);
    subscribe<T>(model);

    if (model is RMKey && !model.isLinked) {
      model.initCallBack.add((rm, rmInit) {
        (rmInit ?? model.rm).copy(rm);
        Future.microtask(() => state._setState());
      });
    }
  }

  if (state.widget.rmKey != null) {
    state.widget.rmKey.rm = state._exposedModel;
    state.widget.rmKey.refreshCallBack = (rm) {
      state
        .._exposedModelFromGenericType = null
        .._exposedModelFromNotification = null;
      _resolveModels<T>(state, true);
      state.widget.rmKey.rm = state._exposedModel;
    };

    state._models.where((m) => m is ReactiveModel).forEach((rm) {
      state.widget.rmKey.associate(rm);
    });
  }
}

void _dispose<T>(StateBuilderState<T> state) {
  final widget = state.widget;
  state._exposedModelFromGenericType?.inject?.removeFromReactiveNewInstanceList(state._exposedModelFromGenericType);
  if (state._models == null) {
    return;
  }
  for (var model in state._models) {
    if (state.widget.disposeModels == true) {
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
    model?.removeObserver(observer: state, tag: state._autoGeneratedTag);
    if (widget.tag != null) {
      if (widget.tag is List) {
        for (var tag in widget.tag) {
          model?.removeObserver(observer: state, tag: tag.toString());
        }
      } else {
        model?.removeObserver(observer: state, tag: widget.tag.toString());
      }
    }
  }

  if (widget.rmKey != null) {
    widget.rmKey.cleanRMKey();
  }
}
