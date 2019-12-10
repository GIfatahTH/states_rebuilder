import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/src/add_observer.dart';
import 'states_rebuilder.dart';

class StateBuilder<T> extends StatefulWidget {
  /// You wrap any part of your widgets with [StateBuilder] Widget to make it Reactive.
  /// When [StatesRebuilder.rebuildStates] method is called, it will rebuild.
  const StateBuilder({
    Key key,
    // For state management
    this.models,
    this.viewModels,
    this.tag,
    this.builder,
    this.builderWithChild,
    this.child,
    this.onSetState,
    this.onRebuildState,
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
        super(
          key: key,
        );

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

  ///```
  ///StateBuilder(
  ///  initState:(BuildContext context, ReactiveModel model)=> myModel.init([context,model]),
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  final void Function(BuildContext context, ReactiveModel<T> model) initState;

  ///```
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

  ///```
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

  ///```
  ///StateBuilder(
  ///  didUpdateWidget:(BuildContext context, ReactiveModel model,StateBuilder oldWidget) {
  ///     myModel.dispose([context, model]);
  ///   },
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  final void Function(
          BuildContext context, ReactiveModel<T> model, StateBuilder oldWidget)
      didUpdateWidget;

  ///Called after the widget is first inserted in the widget tree.
  final void Function(BuildContext context, ReactiveModel<T> model)
      afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context, ReactiveModel<T> model)
      afterRebuild;

  ///Called whenever this widget is notified.
  final void Function(BuildContext context, ReactiveModel<T> model) onSetState;

  /// Called whenever this widget is notified and after rebuilding the widget.
  final void Function(BuildContext context, ReactiveModel<T> model)
      onRebuildState;

  ///A custom name of your widget. It is used to rebuild this widget
  ///from your logic classes.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  ///
  ///Each [StateBuilder] has a default tag which is its [context]
  final dynamic tag;

  ///```dart
  ///StateBuilder(
  ///  models:[myModel1, myModel2,myModel3],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget to subscribe.
  ///The logic class should extend  `StatesRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> models;

  ///```dart
  ///StateBuilder(
  ///  models:[myModel1, myModel2,myModel3],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesRebuilder`of the states_rebuilder package.
  @Deprecated('use models instead')
  final List<StatesRebuilder> viewModels;

  ///Whether to call dispose method of the models if exists.
  final bool disposeModels;

  @override
  _StateBuilderState<T> createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T> extends State<StateBuilder<T>>
    implements ObserverOfStatesRebuilder {
  AddToObserver addToObserver;
  ReactiveModel<T> _exposedModel;

  @override
  void initState() {
    super.initState();
    List<StatesRebuilder> _models = widget.models ?? widget.viewModels;

    final String uniqueID = context.hashCode.toString();

    if (_models == null || _models.isEmpty) {
      assert(
        () {
          if (T == dynamic) {
            throw Exception('''
      
      ***No model is defined***
      You have to either :
      1- Provide a generic type to create and subscribe to a new reactive environnement
        ex:
         StateBuilder<MyModel>(
           Builder:(BuildContext context, ReactiveModel<MyModel> myModel){
             return ...
           }
         )
      2- define the [models] property. to subscribe to an already defined reactive environnement instance
        ex:
          StateBuilder(
            models : [myModelInstance],
            Builder:(BuildContext context, ReactiveModel<MyModel> myModel){
              return ...
            }
          )
      ''');
          }
          return true;
        }(),
      );
      //created a new reactive instance from the provided generic type.
      _exposedModel =
          Injector.getAsReactive<T>(asNewReactiveInstance: true, silent: true);

      _exposedModel.addToReactiveNewInstanceList();
      _models = <StatesRebuilder>[_exposedModel];
    } else if (_models.first is ReactiveModel) {
      //Make the exposed model to be the first in the list
      _exposedModel = _models.first;
    }

    if (_models != null) {
      addToObserver = AddToObserver(widget, this, _models, uniqueID);
    }

    if (widget.initState != null) {
      widget.initState(context, _exposedModel);
    }
    if (widget.afterInitialBuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterInitialBuild(context, _exposedModel),
      );
    }
  }

  @override
  bool update([void Function(BuildContext) onSetState]) {
    if (!mounted) {
      return false;
    }
    setState(() {
      if (onSetState != null) {
        onSetState(context);
      }

      if (widget.onSetState != null) {
        widget.onSetState(context, _exposedModel);
      }
    });
    if (widget.onRebuildState != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onRebuildState(context, _exposedModel),
      );
    }
    return true;
  }

  @override
  void dispose() {
    addToObserver.removeFromObserver();

    if (widget.dispose != null) {
      widget.dispose(context, _exposedModel);
    }

    if (widget.disposeModels == true) {
      final List<StatesRebuilder> _models =
          widget.models ?? <StatesRebuilder>[];
      for (final StatesRebuilder model in _models) {
        try {
          if (model != null) {
            (model as dynamic)?.dispose();
          }
        } catch (e) {}
      }
    }

    _exposedModel?.removeFromReactiveNewInstanceList();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null)
      widget.didChangeDependencies(context, _exposedModel);
  }

  @override
  void didUpdateWidget(StateBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null)
      widget.didUpdateWidget(context, _exposedModel, oldWidget);
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
}
