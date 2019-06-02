import 'package:flutter/material.dart';
import 'states_rebuilder.dart';
import 'common.dart';

class StateBuilder extends StateBuilderBase {
  /// You wrap any part of your widgets with `StateBuilder` Widget to make it Reactive.
  /// When `rebuildState` method is called and referred to it, it will rebuild.
  StateBuilder({
    Key key,
    this.tag,
    @required this.blocs,
    @required this.builder,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
  }) : super(
          key: key,
          tag: tag,
          blocs: blocs,
          builder: builder,
        );

  ///```dart
  ///StateBuilder(
  ///  blocs:[myBloc],
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state.
  /// `StateBuilder` widget can be rebuilt from the logic class using
  ///the `rebuildState` method.
  ///
  ///The builder is provided with an [BuildContext] and [String] parameters.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this `StateBuilder`.
  final StateBuildertype builder;

  ///```
  ///StateBuilder(
  ///  initState:(BuildContext context, String tagID)=> myBloc.init([context, tagID]),
  ///  blocs:[myBloc],
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final Function(BuildContext context, String tagID) initState;

  ///```
  ///StateBuilder(
  ///  dispose:(BuildContext context, String tagID)=> myBloc.dispose([context, tagID]),
  ///  blocs:[myBloc],
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final Function(BuildContext context, String tagID) dispose;

  ///```
  ///StateBuilder(
  ///  didChangeDependencies:(BuildContext context, String tagID)=> myBloc.myMethod([context, tagID]),
  ///  blocs:[myBloc],
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final Function(BuildContext context, String tagID) didChangeDependencies;

  ///```
  ///StateBuilder(
  ///  didUpdateWidget:(BuildContext context, String tagID,_StateBuilder oldWidget)=> myBloc.myMethod([context, tagID,oldWidget]),
  ///  blocs:[myBloc],
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateBuilder`.
  final void Function(
          BuildContext context, String tagID, StateBuilderBase oldWidget)
      didUpdateWidget;

  ///A custom name of your widget. It is used to rebuild this widget
  ///from your logic classes.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  final dynamic tag;

  ///```
  ///StateBuilder(
  ///  blocs:[myBloc1, myBloc2,myBloc3],
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extand  `StatesRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> blocs;

  _StateBuilderState createState() => _StateBuilderState();
}

class _StateBuilderState extends State<StateBuilder> {
  String _tag;
  String _tagID;

  @override
  void initState() {
    super.initState();
    final tempTags =
        addListener(widget.blocs, widget.tag, "$hashCode", _listener);
    _tag = tempTags[0];
    _tagID = tempTags[1];
    if (widget.initState != null) widget.initState(context, _tagID);
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    removeListner(widget.blocs, _tag, hashCode, _listener);

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
    return widget.builder(context, _tagID);
  }
}
