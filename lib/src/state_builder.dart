import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/src/add_observer.dart';
import 'states_rebuilder.dart';

/// You wrap any part of your widgets with [StateBuilder] Widget to make it Reactive.
/// When [StatesRebuilder.rebuildStates] method is called, it will rebuild.
class StateBuilder<T> extends StatefulWidget {
  /// You wrap any part of your widgets with [StateBuilder] Widget to make it Reactive.
  /// When [StatesRebuilder.rebuildStates] method is called, it will rebuild.
  const StateBuilder({
    Key key,
    // For state management
    this.models,
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
        assert(builderWithChild == null || child != null, '''
  | ***child is null***
  | You have defined the 'builderWithChild' parameter without defining the child parameter.
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
  final void Function(BuildContext context, ReactiveModel<T> model,
      StateBuilder<T> oldWidget) didUpdateWidget;

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
  final List<StatesRebuilder> models;

  ///if it is set to true all observable models will be disposed.
  ///
  ///Models are disposed by calling the 'dispose()' method if exists.
  ///
  ///In any of the injected class you can define a 'dispose()' method to clean up resources.
  final bool disposeModels;

  @override
  _StateBuilderState<T> createState() => _StateBuilderState<T>();
}

class _StateBuilderState<T> extends State<StateBuilder<T>>
    implements ObserverOfStatesRebuilder {
  AddToObserver addToObserver;
  ReactiveModel<T> _exposedModel;

  // Is true if the element has been marked as needing rebuilding.
  bool _isDirty;

  @override
  void initState() {
    _isDirty = true;
    super.initState();
    List<StatesRebuilder> _models = widget.models;

    final String uniqueID = context.hashCode.toString();

    if (_models == null || _models.isEmpty) {
      assert(
        () {
          if (T == dynamic) {
            throw Exception('''
      
***No model is defined***
You are using [StateBuilder] widget without providing a generic type or defining the [models] parameter.

To fix, you have to either :
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
          Injector.getAsReactive<T>(asNewReactiveInstance: true, silent: true)
            ..addToReactiveNewInstanceList();
      _models = <StatesRebuilder>[_exposedModel];
    } else if (_models.first is ReactiveModel) {
      //Make the exposed model to be the first in the list
      _exposedModel = _models.first as ReactiveModel<T>;
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

    setState(
      () {
        if (onSetState != null) {
          onSetState(context);
        }

        //Do not call [StateBuilder.onSetState] more than one for each rebuild
        if (!_isDirty) {
          if (widget.onSetState != null) {
            widget.onSetState(context, _exposedModel);
          }
          if (widget.onRebuildState != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => widget.onRebuildState(context, _exposedModel),
            );
          }
          _isDirty = true;
        }
      },
    );
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
        } catch (e) {
          if (e is! NoSuchMethodError) {
            rethrow;
          }
        }
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
  void didUpdateWidget(StateBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null)
      widget.didUpdateWidget(context, _exposedModel, oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    _isDirty = false;
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
