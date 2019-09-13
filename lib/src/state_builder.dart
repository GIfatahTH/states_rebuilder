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
    this.blocs,
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
          if (blocs == null && viewModels == null) {
            throw Exception(
                "ERR(StateBuilder)01: You have to define one of the `blocs` or `viewModels parameters.\n"
                "`blocs` and `viewModels` are used interchangeably.\n"
                "`blocs`  is deprecated and will be removed in the future.");
          }
          return true;
        }()),
        super(
          key: key,
          tag: tag,
          blocs: blocs,
          viewModels: viewModels,
          disposeViewModels: disposeViewModels,
          builder: builder,
        );

  ///```dart
  ///StateBuilder(
  ///  viewModels:[myVM],
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
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
  ///  initState:(BuildContext context, String tagID)=> myBloc.init([context, tagID]),
  ///  viewModels:[myVM],
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final void Function(BuildContext context, String tagID) initState;

  ///```
  ///StateBuilder(
  ///  dispose:(BuildContext context, String tagID)=> myBloc.dispose([context, tagID]),
  ///  viewModels:[myVM],
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final void Function(BuildContext context, String tagID) dispose;

  ///```
  ///StateBuilder(
  ///  didChangeDependencies:(BuildContext context, String tagID)=> myBloc.myMethod([context, tagID]),
  ///  viewModels:[myVM],
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final void Function(BuildContext context, String tagID) didChangeDependencies;

  ///```
  ///StateBuilder(
  ///  didUpdateWidget:(BuildContext context, String tagID,StateBuilderBase oldWidget)=> myBloc.myMethod([context, tagID,oldWidget]),
  ///  viewModels:[myVM],
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final void Function(
          BuildContext context, String tagID, StateBuilderBase oldWidget)
      didUpdateWidget;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context, String tagID) afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context, String tagID) afterRebuild;

  ///A custom name of your widget. It is used to rebuild this widget
  ///from your logic classes.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  final dynamic tag;

  ///Deprecated. Use viewModels instead.
  ///```dart
  ///StateBuilder(
  ///  blocs:[myBloc1, myBloc2,myBloc3],
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> blocs;

  ///```dart
  ///StateBuilder(
  ///  viewModels:[myVM1, myVM2,myVM3],
  ///  builder:(BuildContext context, String tagID) =>MyWidget(),
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
  String _tagID;
  @override
  void initState() {
    super.initState();
    final uniqueID = shortHash(this) + UniqueKey().toString();
    splitAndAddObserver = SplitAndAddObserver(widget, this, uniqueID);

    _tagID = splitAndAddObserver.tagID;
    if (widget.initState != null) widget.initState(context, _tagID);
    if (widget.afterInitialBuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterInitialBuild(context, _tagID),
      );
    }
  }

  void update() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    splitAndAddObserver.removeFromObserver();

    if (widget.dispose != null) widget.dispose(context, _tagID);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null)
      widget.didChangeDependencies(context, _tagID);
  }

  @override
  void didUpdateWidget(StateBuilderBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null)
      widget.didUpdateWidget(context, _tagID, oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.afterRebuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterRebuild(context, _tagID),
      );
    }
    return widget.builder(context, _tagID);
  }
}
