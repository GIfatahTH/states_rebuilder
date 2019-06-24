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
    this.blocs,
    this.viewModels,
    @required this.builder,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.didChangeAppLifecycleState,
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
        super(
          key: key,
          tag: tag,
          blocs: blocs,
          viewModels: viewModels,
          builder: builder,
          disposeViewModels: disposeViewModels,
        );

  ///```dart
  ///StateWithMixinBuilder(
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
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
  ///  initState:(BuildContext context, String tagID, TickerProvider ticker)=> myBloc.init([context, tagID, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, String tagID, T mix) initState;

  ///```dart
  ///StateWithMixinBuilder(
  ///  dispose:(BuildContext context, String tagID, TickerProvider ticker)=> myBloc.dispose([context, tagID, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, String tagID, T mix) dispose;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeDependencies:(BuildContext context, String tagID, TickerProvider ticker)=> myBloc.myMethod([context, tagID, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, String tagID, T mix)
      didChangeDependencies;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didUpdateWidget:(BuildContext context, String tagID,StateBuilderBase oldWidget, TickerProvider ticker)=> myBloc.myMethod([context, tagID,oldWidget, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(
          BuildContext context, String tagID, StateBuilderBase oldWidget, T mix)
      didUpdateWidget;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeAppLifecycleState:(BuildContext context, String tagID, AppLifecycleState state)=> myBloc.myMethod([context, tagID, state]),
  ///  MixinWith : MixinWith.widgetsBindingObserver
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///Called when the system puts the app in the background or returns the app to the foreground.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(
          BuildContext context, String tagID, AppLifecycleState state)
      didChangeAppLifecycleState;

  ///A custom name of your widget. It is used to rebuild this widget
  ///from your logic classes.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  final dynamic tag;

  ///Deprecated. Use viewModels instead
  ///```dart
  ///StateWithMixinBuilder(
  ///  blocs:[myBloc1, myBloc2,myBloc3],//If you want this widget to not rebuild, do not define any bloc.
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesWithMixinRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> blocs;

  ///```dart
  ///StatesWithMixinRebuilder(
  ///  viewModels:[myVM1, myVM2,myVM3],
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesWithMixinRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> viewModels;

  ///An enum of Pre-defined mixins (ex: MixinWith.tickerProviderStateMixin)
  final MixinWith mixinWith;

  final bool disposeViewModels;
  createState() {
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
      initState: (context, tagID) => widget.initState != null
          ? widget.initState(context, tagID, this as T)
          : null,
      dispose: (context, tagID) {
        if (widget.dispose != null) {
          widget.dispose(context, tagID, this as T);
        } else if (widget.disposeViewModels == true) {
          (widget.viewModels ?? widget.blocs)
              ?.forEach((b) => (b as dynamic).dispose());
        }
      },
      didUpdateWidget: (context, tagID, oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(context, tagID, oldWidget, this as T)
              : null,
      didChangeDependencies: (context, tagID) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(context, tagID, this as T)
              : null,
      viewModels: (widget.viewModels ?? widget.blocs) ?? [],
      tag: widget.tag,
      builder: (context, tagID) => widget.builder(context, tagID),
    );
  }
}

class _StateBuilderStateSingleTickerMix<T>
    extends State<StateWithMixinBuilder<T>>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      initState: (context, tagID) => widget.initState != null
          ? widget.initState(context, tagID, this as T)
          : null,
      dispose: (context, tagID) {
        if (widget.dispose != null) {
          widget.dispose(context, tagID, this as T);
        } else if (widget.disposeViewModels == true) {
          (widget.viewModels ?? widget.blocs)
              ?.forEach((b) => (b as dynamic).dispose());
        }
      },
      didUpdateWidget: (context, tagID, oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(context, tagID, oldWidget, this as T)
              : null,
      didChangeDependencies: (context, tagID) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(context, tagID, this as T)
              : null,
      viewModels: (widget.viewModels ?? widget.blocs) ?? [],
      tag: widget.tag,
      builder: (context, tagID) => widget.builder(context, tagID),
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
      initState: (context, tagID) => widget.initState != null
          ? widget.initState(context, tagID, this as T)
          : null,
      dispose: (context, tagID) {
        if (widget.dispose != null) {
          widget.dispose(context, tagID, this as T);
        } else if (widget.disposeViewModels == true) {
          (widget.viewModels ?? widget.blocs)
              ?.forEach((b) => (b as dynamic).dispose());
        }
      },
      didUpdateWidget: (context, tagID, oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(context, tagID, oldWidget, this as T)
              : null,
      didChangeDependencies: (context, tagID) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(context, tagID, this as T)
              : null,
      viewModels: (widget.viewModels ?? widget.blocs) ?? [],
      tag: widget.tag,
      builder: (context, tagID) => widget.builder(context, tagID),
    );
  }
}

class _StateBuilderStateWidgetsBindingObserver<T>
    extends State<StateWithMixinBuilder<T>> with WidgetsBindingObserver {
  String _tagID;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.didChangeAppLifecycleState != null)
      widget.didChangeAppLifecycleState(context, _tagID, state);
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      initState: (context, tagID) {
        _tagID = tagID;
        if (widget.initState != null)
          widget.initState(context, tagID, this as T);
      },
      dispose: (context, tagID) {
        if (widget.dispose != null) {
          widget.dispose(context, tagID, this as T);
        } else if (widget.disposeViewModels == true) {
          (widget.viewModels ?? widget.blocs)
              ?.forEach((b) => (b as dynamic).dispose());
        }
      },
      didUpdateWidget: (context, tagID, oldWidget) =>
          widget.didUpdateWidget != null
              ? widget.didUpdateWidget(context, tagID, oldWidget, this as T)
              : null,
      didChangeDependencies: (context, tagID) =>
          widget.didChangeDependencies != null
              ? widget.didChangeDependencies(context, tagID, this as T)
              : null,
      viewModels: (widget.viewModels ?? widget.blocs) ?? [],
      tag: widget.tag,
      builder: (context, tagID) => widget.builder(context, tagID),
    );
  }
}
