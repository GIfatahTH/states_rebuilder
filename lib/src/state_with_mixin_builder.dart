import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'states_rebuilder.dart';
import 'state_builder.dart';
import 'common.dart';

class StateWithMixinBuilder<T> extends StateBuilderBase {
  /// You wrap any part of your widgets with `StateBuilder` Widget to make it Reactive.
  /// When `rebuildState` method is called and referred to it, it will rebuild.
  StateWithMixinBuilder({
    Key key,
    this.tag,
    this.models,
    this.viewModels,
    @required this.builder,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.didChangeAppLifecycleState,
    this.afterInitialBuild,
    this.afterRebuild,
    this.disposeViewModels = true,
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
          tag: tag,
          models: models,
          viewModels: viewModels,
          builder: builder,
          disposeViewModels: disposeViewModels,
        );

  ///```dart
  ///StateWithMixinBuilder(
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state.
  /// `StateWithMixinBuilder` widget can be rebuilt from the logic class using
  ///the `rebuildState` method.
  ///
  ///The builder is provided with an [BuildContext] and [String] parameters.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  final StateBuilderType builder;

  ///```dart
  ///StateWithMixinBuilder(
  ///  initState:(BuildContext context, String tag, TickerProvider ticker)=> myModel.init([context, tag, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, String tag, T mix) initState;

  ///```dart
  ///StateWithMixinBuilder(
  ///  dispose:(BuildContext context, String tag, TickerProvider ticker)=> myModel.dispose([context, tag, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, String tag, T mix) dispose;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeDependencies:(BuildContext context, String tag, TickerProvider ticker)=> myModel.myMethod([context, tag, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, String tag, T mix)
      didChangeDependencies;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didUpdateWidget:(BuildContext context, String tag,StateBuilderBase oldWidget, TickerProvider ticker)=> myModel.myMethod([context, tag,oldWidget, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(
          BuildContext context, String tag, StateBuilderBase oldWidget, T mix)
      didUpdateWidget;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeAppLifecycleState:(BuildContext context, String tag, AppLifecycleState state)=> myModel.myMethod([context, tag, state]),
  ///  MixinWith : MixinWith.widgetsBindingObserver
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///Called when the system puts the app in the background or returns the app to the foreground.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, String tag, AppLifecycleState state)
      didChangeAppLifecycleState;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context, String tag, T mix)
      afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context, String tag) afterRebuild;

  ///A custom name of your widget. It is used to rebuild this widget
  ///from your logic classes.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  final dynamic tag;

  ///Deprecated. Use viewModels instead
  ///```dart
  ///StateWithMixinBuilder(
  ///  models:[myModel1, myModel2,myModel3],//If you want this widget to not rebuild, do not define any model.
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesWithMixinRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> models;

  ///```dart
  ///StatesWithMixinRebuilder(
  ///  viewModels:[myVM1, myVM2,myVM3],
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesWithMixinRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> viewModels;

  ///An enum of Pre-defined mixins (ex: MixinWith.tickerProviderStateMixin)
  final MixinWith mixinWith;

  final bool disposeViewModels;
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
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      initState: (context, tag) => widget.initState != null
          ? widget.initState(context, tag, this as T)
          : null,
      dispose: (context, tag) {
        if (widget.dispose != null) {
          widget.dispose(context, tag, this as T);
        } else if (widget.disposeViewModels == true) {
          (widget.viewModels ?? widget.models)
              ?.forEach((b) => (b as dynamic).dispose());
        }
      },
      didUpdateWidget: (context, tag, oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(context, tag, oldWidget, this as T)
              : null,
      didChangeDependencies: (context, tag) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(context, tag, this as T)
              : null,
      afterInitialBuild: (context, tag) => widget.afterInitialBuild != null
          ? widget.afterInitialBuild(context, tag, this as T)
          : null,
      afterRebuild: (context, tag) => widget.afterRebuild != null
          ? widget.afterRebuild(context, tag)
          : null,
      viewModels: (widget.viewModels ?? widget.models) ?? [],
      tag: widget.tag,
      builder: (context, tag) => widget.builder(context, tag),
    );
  }
}

class _StateBuilderStateSingleTickerMix<T>
    extends State<StateWithMixinBuilder<T>>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      initState: (context, tag) => widget.initState != null
          ? widget.initState(context, tag, this as T)
          : null,
      dispose: (context, tag) {
        if (widget.dispose != null) {
          widget.dispose(context, tag, this as T);
        } else if (widget.disposeViewModels == true) {
          (widget.viewModels ?? widget.models)
              ?.forEach((b) => (b as dynamic).dispose());
        }
      },
      didUpdateWidget: (context, tag, oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(context, tag, oldWidget, this as T)
              : null,
      didChangeDependencies: (context, tag) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(context, tag, this as T)
              : null,
      afterInitialBuild: (context, tag) => widget.afterInitialBuild != null
          ? widget.afterInitialBuild(context, tag, this as T)
          : null,
      afterRebuild: (context, tag) => widget.afterRebuild != null
          ? widget.afterRebuild(context, tag)
          : null,
      viewModels: (widget.viewModels ?? widget.models) ?? [],
      tag: widget.tag,
      builder: (context, tag) => widget.builder(context, tag),
    );
  }
}

class _StateBuilderStateAutomaticKeepAliveClient<T>
    extends State<StateWithMixinBuilder<T>>
    with AutomaticKeepAliveClientMixin<StateWithMixinBuilder<T>> {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StateBuilder(
      initState: (context, tag) => widget.initState != null
          ? widget.initState(context, tag, this as T)
          : null,
      dispose: (context, tag) {
        if (widget.dispose != null) {
          widget.dispose(context, tag, this as T);
        } else if (widget.disposeViewModels == true) {
          (widget.viewModels ?? widget.models)
              ?.forEach((b) => (b as dynamic).dispose());
        }
      },
      didUpdateWidget: (context, tag, oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(context, tag, oldWidget, this as T)
              : null,
      didChangeDependencies: (context, tag) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(context, tag, this as T)
              : null,
      afterInitialBuild: (context, tag) => widget.afterInitialBuild != null
          ? widget.afterInitialBuild(context, tag, this as T)
          : null,
      afterRebuild: (context, tag) => widget.afterRebuild != null
          ? widget.afterRebuild(context, tag)
          : null,
      viewModels: (widget.viewModels ?? widget.models) ?? [],
      tag: widget.tag,
      builder: (context, tag) => widget.builder(context, tag),
    );
  }
}

class _StateBuilderStateWidgetsBindingObserver<T>
    extends State<StateWithMixinBuilder<T>> with WidgetsBindingObserver {
  String _tag;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.didChangeAppLifecycleState != null)
      widget.didChangeAppLifecycleState(context, _tag, state);
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      initState: (context, tag) {
        _tag = tag;
        if (widget.initState != null) widget.initState(context, tag, this as T);
      },
      dispose: (context, tag) {
        if (widget.dispose != null) {
          widget.dispose(context, tag, this as T);
        } else if (widget.disposeViewModels == true) {
          (widget.viewModels ?? widget.models)
              ?.forEach((b) => (b as dynamic).dispose());
        }
      },
      didUpdateWidget: (context, tag, oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(context, tag, oldWidget, this as T)
              : null,
      didChangeDependencies: (context, tag) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(context, tag, this as T)
              : null,
      afterInitialBuild: (context, tag) => widget.afterInitialBuild != null
          ? widget.afterInitialBuild(context, tag, this as T)
          : null,
      afterRebuild: (context, tag) => widget.afterRebuild != null
          ? widget.afterRebuild(context, tag)
          : null,
      viewModels: (widget.viewModels ?? widget.models) ?? [],
      tag: widget.tag,
      builder: (context, tag) => widget.builder(context, tag),
    );
  }
}
