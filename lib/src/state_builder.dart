import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/split_and_add_observer.dart';
import 'states_rebuilder.dart';
import 'common.dart';

class StateBuilder extends StateBuilderBase {
  /// You wrap any part of your widgets with `StateBuilder` Widget to make it Reactive.
  /// When `rebuildState` method is called and referred to it, it will rebuild.
  StateBuilder({
    Key key,
    this.tag,
    this.models,
    this.viewModels,
    this.disposeViewModels,
    @required this.builder,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.afterInitialBuild,
    this.afterRebuild,
  })  : assert(() {
          if (models == null && viewModels == null) {
            throw Exception(
                "ERR(StateBuilder)01: You have to define one of the `models` or `viewModels parameters.\n"
                "`models` and `viewModels` are used interchangeably.\n"
                "`models`  is deprecated and will be removed in the future.");
          }
          return true;
        }()),
        super(
          key: key,
          tag: tag,
          models: models,
          viewModels: viewModels,
          disposeViewModels: disposeViewModels,
          builder: builder,
        );

  ///```dart
  ///StateBuilder(
  ///  viewModels:[myVM],
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state.
  /// `StateBuilder` widget can be rebuilt from the logic class using
  ///the `rebuildState` method.
  ///
  ///The builder is provided with an [BuildContext] and [String] parameters.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this `StateBuilder`.
  final StateBuilderType builder;

  ///```
  ///StateBuilder(
  ///  initState:(BuildContext context, String tag)=> myModel.init([context, tag]),
  ///  viewModels:[myVM],
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final void Function(BuildContext context, String tag) initState;

  ///```
  ///StateBuilder(
  ///  dispose:(BuildContext context, String tag)=> myModel.dispose([context, tag]),
  ///  viewModels:[myVM],
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final void Function(BuildContext context, String tag) dispose;

  ///```
  ///StateBuilder(
  ///  didChangeDependencies:(BuildContext context, String tag)=> myModel.myMethod([context, tag]),
  ///  viewModels:[myVM],
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final void Function(BuildContext context, String tag) didChangeDependencies;

  ///```
  ///StateBuilder(
  ///  didUpdateWidget:(BuildContext context, String tag,StateBuilderBase oldWidget)=> myModel.myMethod([context, tag,oldWidget]),
  ///  viewModels:[myVM],
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final void Function(
          BuildContext context, String tag, StateBuilderBase oldWidget)
      didUpdateWidget;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context, String tag) afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context, String tag) afterRebuild;

  ///A custom name of your widget. It is used to rebuild this widget
  ///from your logic classes.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  final dynamic tag;

  ///```dart
  ///StateBuilder(
  ///  models:[myModel1, myModel2,myModel3],
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> models;

  ///```dart
  ///StateBuilder(
  ///  viewModels:[myVM1, myVM2,myVM3],
  ///  builder:(BuildContext context, String tag) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> viewModels;

  final bool disposeViewModels;
  _StateBuilderState createState() => _StateBuilderState();
}

class _StateBuilderState extends State<StateBuilder>
    implements ListenerOfStatesRebuilder {
  SplitAndAddObserver splitAndAddObserver;
  String defaultTag;
  @override
  void initState() {
    super.initState();
    final uniqueID = shortHash(this) + UniqueKey().toString();
    splitAndAddObserver = SplitAndAddObserver(widget, this, uniqueID);

    defaultTag = splitAndAddObserver.defaultTag;
    if (widget.initState != null) widget.initState(context, defaultTag);
    if (widget.afterInitialBuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterInitialBuild(context, defaultTag),
      );
    }
  }

  bool update([void Function(BuildContext) onRebuildCallBack]) {
    if (!mounted) return false;

    setState(() {
      if (onRebuildCallBack != null) {
        onRebuildCallBack(context);
      }
    });
    return true;
  }

  @override
  void dispose() {
    splitAndAddObserver.removeFromObserver();

    if (widget.dispose != null) widget.dispose(context, defaultTag);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null)
      widget.didChangeDependencies(context, defaultTag);
  }

  @override
  void didUpdateWidget(StateBuilderBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null)
      widget.didUpdateWidget(context, defaultTag, oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.afterRebuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterRebuild(context, defaultTag),
      );
    }
    return widget.builder(context, defaultTag);
  }
}
