import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'state_builder.dart';
import 'states_rebuilder.dart';

class StateWithMixinBuilder<T> extends StatefulWidget {
  /// You wrap any part of your widgets with `StateBuilder` Widget to make it Reactive.
  /// When `rebuildState` method is called and referred to it, it will rebuild.
  StateWithMixinBuilder({
    Key key,
    this.tag,
    this.models,
    @required this.builder,
    this.builderWithChild,
    this.child,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.didChangeAppLifecycleState,
    this.afterInitialBuild,
    this.afterRebuild,
    this.disposeModels = true,
    @required this.mixinWith,
  })  : assert(() {
          if (initState == null || dispose == null) {
            if (mixinWith == MixinWith.singleTickerProviderStateMixin ||
                mixinWith == MixinWith.tickerProviderStateMixin ||
                mixinWith == MixinWith.widgetsBindingObserver) {
              throw FlutterError('`initState` `dispose` must not be null\n'
                  'For example if you are using `TickerProviderStateMixin` so you have to instantiate \n'
                  'your controllers in the initState() and dispose them in the dispose() method\n'
                  'If you do not need to use any controller set the (){}');
            }
          }
          return true;
        }()),
        assert(mixinWith != null),
        super(
          key: key,
        );

  ///```dart
  ///StateWithMixinBuilder(
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state.
  ///
  ///The builder is provided with an [BuildContext] and [ReactiveModel<T>] parameters.
  final Widget Function(BuildContext context, ReactiveModel<T> model) builder;

  ///```dart
  ///StateWithMixinBuilder(
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model, Widget child) =>MyWidget(),
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

  ///```dart
  ///StateWithMixinBuilder(
  ///  initState:(BuildContext context,  TickerProvider ticker)=> myModel.init([context, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, T mix) initState;

  ///```dart
  ///StateWithMixinBuilder(
  ///  dispose:(BuildContext context,  TickerProvider ticker)=> myModel.dispose([context, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, T mix) dispose;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeDependencies:(BuildContext context,  TickerProvider ticker)=> myModel.myMethod([context, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, T mix) didChangeDependencies;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didUpdateWidget:(BuildContext context, StateBuilderBase oldWidget, TickerProvider ticker)=> myModel.myMethod([context,oldWidget, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, StateBuilder oldWidget, T mix)
      didUpdateWidget;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeAppLifecycleState:(BuildContext context,  AppLifecycleState state)=> myModel.myMethod([context, state]),
  ///  MixinWith : MixinWith.widgetsBindingObserver
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when the system puts the app in the background or returns the app to the foreground.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, AppLifecycleState state)
      didChangeAppLifecycleState;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context, T mix) afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context) afterRebuild;

  ///A custom name of your widget. It is used to rebuild this widget
  ///from your logic classes.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  ///
  ///  ///Each [StateBuilder] has a default tag which is its [context]
  final dynamic tag;

  ///Deprecated. Use models instead
  ///```dart
  ///StateWithMixinBuilder(
  ///  models:[myModel1, myModel2,myModel3],//If you want this widget to not rebuild, do not define any model.
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesWithMixinRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> models;

  ///An enum of Pre-defined mixins (ex: MixinWith.tickerProviderStateMixin)
  final MixinWith mixinWith;

  ///Whether to call dispose method of the models if exists.
  final bool disposeModels;

  @override
  State<StateWithMixinBuilder<T>> createState() {
    switch (mixinWith) {
      case MixinWith.tickerProviderStateMixin:
        return _StateBuilderStateTickerMix<T>();
        break;
      case MixinWith.singleTickerProviderStateMixin:
        return _StateBuilderStateSingleTickerMix<T>();
        break;
      case MixinWith.automaticKeepAliveClientMixin:
        return _StateBuilderStateAutomaticKeepAliveClient<T>();
        break;
      case MixinWith.widgetsBindingObserver:
        return _StateBuilderStateWidgetsBindingObserver<T>();
        break;
      default:
        return null;
    }
  }
}

enum MixinWith {
  tickerProviderStateMixin,
  singleTickerProviderStateMixin,
  automaticKeepAliveClientMixin,
  widgetsBindingObserver,
}

class _StateBuilderStateTickerMix<T> extends State<StateWithMixinBuilder<T>>
    with TickerProviderStateMixin {
  final T _nullModel = null;
  @override
  Widget build(BuildContext context) {
    return StateBuilder<dynamic>(
      initState: (BuildContext context, __) {
        if (widget.initState != null) {
          widget.initState(context, this is T ? this : _nullModel);
        }
      },
      dispose: (BuildContext context, _) {
        if (widget.dispose != null) {
          widget.dispose(context, this is T ? this : _nullModel);
        }
      },
      disposeModels: widget.disposeModels ?? false,
      didUpdateWidget: (BuildContext context, _, StateBuilder oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(
                  context, oldWidget, this is T ? this : _nullModel)
              : null,
      didChangeDependencies: (BuildContext context, _) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(
                  context, this is T ? this : _nullModel)
              : null,
      afterInitialBuild: (BuildContext context, _) =>
          widget.afterInitialBuild != null
              ? widget.afterInitialBuild(context, this is T ? this : _nullModel)
              : null,
      afterRebuild: (BuildContext context, _) =>
          widget.afterRebuild != null ? widget.afterRebuild(context) : null,
      models: widget.models ?? <StatesRebuilder>[null],
      tag: widget.tag,
      builder: (BuildContext context, _) => widget.builder(context, _),
    );
  }
}

class _StateBuilderStateSingleTickerMix<T>
    extends State<StateWithMixinBuilder<T>>
    with SingleTickerProviderStateMixin {
  final T _nullModel = null;

  @override
  Widget build(BuildContext context) {
    return StateBuilder<dynamic>(
      initState: (BuildContext context, __) {
        if (widget.initState != null) {
          widget.initState(context, this is T ? this : _nullModel);
        }
      },
      dispose: (BuildContext context, _) {
        if (widget.dispose != null) {
          widget.dispose(context, this is T ? this : _nullModel);
        }
      },
      disposeModels: widget.disposeModels ?? false,
      didUpdateWidget: (BuildContext context, _, StateBuilder oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(
                  context, oldWidget, this is T ? this : _nullModel)
              : null,
      didChangeDependencies: (BuildContext context, _) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(
                  context, this is T ? this : _nullModel)
              : null,
      afterInitialBuild: (BuildContext context, _) =>
          widget.afterInitialBuild != null
              ? widget.afterInitialBuild(context, this is T ? this : _nullModel)
              : null,
      afterRebuild: (BuildContext context, _) =>
          widget.afterRebuild != null ? widget.afterRebuild(context) : null,
      models: widget.models ?? <StatesRebuilder>[null],
      tag: widget.tag,
      builder: (BuildContext context, _) => widget.builder(context, _),
    );
  }
}

class _StateBuilderStateAutomaticKeepAliveClient<T>
    extends State<StateWithMixinBuilder<T>>
    with AutomaticKeepAliveClientMixin<StateWithMixinBuilder<T>> {
  final T _nullModel = null;
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StateBuilder<dynamic>(
      initState: (BuildContext context, __) {
        if (widget.initState != null) {
          widget.initState(context, this is T ? this : _nullModel);
        }
      },
      dispose: (BuildContext context, _) {
        if (widget.dispose != null) {
          widget.dispose(context, this is T ? this : _nullModel);
        }
      },
      disposeModels: widget.disposeModels ?? false,
      didUpdateWidget: (BuildContext context, _, StateBuilder oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(
                  context, oldWidget, this is T ? this : _nullModel)
              : null,
      didChangeDependencies: (BuildContext context, _) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(
                  context, this is T ? this : _nullModel)
              : null,
      afterInitialBuild: (BuildContext context, _) =>
          widget.afterInitialBuild != null
              ? widget.afterInitialBuild(context, this is T ? this : _nullModel)
              : null,
      afterRebuild: (BuildContext context, _) =>
          widget.afterRebuild != null ? widget.afterRebuild(context) : null,
      models: widget.models ?? <StatesRebuilder>[null],
      tag: widget.tag,
      builder: (BuildContext context, _) => widget.builder(context, _),
    );
  }
}

class _StateBuilderStateWidgetsBindingObserver<T>
    extends State<StateWithMixinBuilder<T>> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.didChangeAppLifecycleState != null)
      widget.didChangeAppLifecycleState(context, state);
  }

  final T _nullModel = null;

  @override
  Widget build(BuildContext context) {
    return StateBuilder<dynamic>(
      initState: (BuildContext context, __) {
        if (widget.initState != null) {
          widget.initState(context, this is T ? this : _nullModel);
        }
      },
      dispose: (BuildContext context, _) {
        if (widget.dispose != null) {
          widget.dispose(context, this is T ? this : _nullModel);
        }
      },
      disposeModels: widget.disposeModels ?? false,
      didUpdateWidget: (BuildContext context, _, StateBuilder oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(
                  context, oldWidget, this is T ? this : _nullModel)
              : null,
      didChangeDependencies: (BuildContext context, _) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(
                  context, this is T ? this : _nullModel)
              : null,
      afterInitialBuild: (BuildContext context, _) =>
          widget.afterInitialBuild != null
              ? widget.afterInitialBuild(context, this is T ? this : _nullModel)
              : null,
      afterRebuild: (BuildContext context, _) =>
          widget.afterRebuild != null ? widget.afterRebuild(context) : null,
      models: widget.models ?? <StatesRebuilder>[null],
      tag: widget.tag,
      builder: (BuildContext context, _) => widget.builder(context, _),
    );
  }
}
