import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../rm.dart';

/// One of the three observer widgets in states_rebuilder
///
/// See [WhenRebuilder], [WhenRebuilderOr]
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
  final Widget Function(BuildContext context, ReactiveModel<T>? model)? builder;

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
  final Injected<T> Function()? observe;

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
  final List<Injected Function()>? observeMany;

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
  final void Function(BuildContext context, ReactiveModel<T>? model)? initState;

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
  final void Function(BuildContext context, ReactiveModel<T>? model)? dispose;

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
  final void Function(BuildContext context, ReactiveModel<T>? model)?
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
  final void Function(BuildContext context, ReactiveModel<T>? model,
      StateBuilder<T> oldWidget)? didUpdateWidget;

  ///Called after the widget is first inserted in the widget tree.
  final void Function(BuildContext context, ReactiveModel<T>? model)?
      afterInitialBuild;

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
          BuildContext context, ReactiveModel<T>? model, Widget? child)?
      builderWithChild;

  ///The child to be used in [builderWithChild].
  final Widget? child;

  ///Called whenever this widget is notified.
  final dynamic Function(BuildContext context, ReactiveModel<T>? model)?
      onSetState;

  /// Called whenever this widget is notified and after rebuilding the widget.
  final void Function(BuildContext context, ReactiveModel<T>? model)?
      onRebuildState;

  /// callback to be executed before notifying listeners. It the returned value is
  /// the same as the last one, the rebuild process is interrupted.
  ///
  final Object? Function(ReactiveModel<T>? model)? watch;

  ///Callback to determine whether this StateBuilder will rebuild or not.
  ///
  final bool Function(ReactiveModel<T>? model)? shouldRebuild;

  /// One of the three observer widgets in states_rebuilder
  ///
  /// See: [WhenRebuilder], [WhenRebuilderOr]
  StateBuilder({
    Key? key,
    // For state management
    this.builder,
    this.observe,
    this.observeMany,
    this.tag,
    this.builderWithChild,
    this.child,
    this.onSetState,
    this.onRebuildState,
    this.watch,
    this.shouldRebuild,

    // For state lifecycle
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.afterInitialBuild,
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
  State<StateBuilder<T>> createState() {
    // if (observeMany == null && observe != null) {
    //   return StateBasic<T>();
    // }
    return StateBuilderState<T>();
  }
}

///The state of [StateBuilder]
class StateBuilderState<T> extends State<StateBuilder<T>> {
  ReactiveModel<T>? rm;
  ReactiveModel<T>? exposedModelFromInitState;
  Injected<T>? observe;
  late Widget _widget;

  @override
  void initState() {
    super.initState();

    resolveObservers();

    _widget = On.data(() {
      if (widget.builder != null) {
        return widget.builder!(context, rm);
      }
      return widget.builderWithChild!(context, rm, widget.child);
    }).listenTo(
      observe!,
      initState: widget.initState != null
          ? () {
              widget.initState!.call(context, rm);
              if (widget.afterInitialBuild != null) {
                WidgetsBinding.instance?.addPostFrameCallback(
                  (_) => widget.afterInitialBuild!(context, rm),
                );
              }
            }
          : null,
      dispose: widget.dispose != null
          ? () => widget.dispose!.call(context, exposedModelFromInitState)
          : null,
      onSetState: On(
        () {
          widget.onSetState?.call(context, rm);
          if (widget.onRebuildState != null) {
            WidgetsBinding.instance?.addPostFrameCallback(
              (_) => widget.onRebuildState!(context, rm),
            );
          }
        },
      ),
      shouldRebuild: (_) {
        return (widget.shouldRebuild?.call(rm) ??
            (rm?.hasData != false || rm?.isIdle != false));
      },
      watch: widget.watch != null ? () => widget.watch!(rm) : null,
    );
  }

  void resolveObservers() {
    final observeMany = <Injected>[];

    if (widget.observe != null) {
      observe = widget.observe!.call();
      if (observe is ReactiveModel<T>) {
        rm = observe as ReactiveModel<T>;
      }
    }
    if (widget.observeMany != null && widget.observeMany!.isNotEmpty) {
      observeMany.addAll(widget.observeMany!.map((e) => e()));
      if (observe == null) {
        final r = observeMany.firstWhereOrNull((e) => e is ReactiveModel<T>);
        if (r != null) {
          rm = r as ReactiveModel<T>;
        } else {
          if (observeMany.first is ReactiveModel<T>) {
            rm = observeMany.first as ReactiveModel<T>;
          }
        }
        observe = ReactiveModel(creator: () {});
      }
      observeMany.forEach(
        (m) {
          final disposer = m.observeForRebuild((r) {
            if (r is ReactiveModel && widget.observe == null) {
              rm = r as ReactiveModel<T>;
            }
            observe?.notify();
          });
          observe?.addCleaner(() => disposer());
        },
      );
    } else if (widget.observe == null) {
      throw ArgumentError('You have to observe a model by defining '
          'either observe or observeMany parameters');
    }
    exposedModelFromInitState = rm;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.didChangeDependencies?.call(context, rm);
  }

  @override
  void didUpdateWidget(covariant StateBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.didUpdateWidget?.call(context, rm, oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _widget;
  }
}
