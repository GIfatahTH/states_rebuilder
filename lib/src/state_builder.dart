import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  })  : assert(() {
          if (blocs == null && viewModels == null) {
            throw FlutterError(
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
  final Function(BuildContext context, String tagID) initState;

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
  final Function(BuildContext context, String tagID) dispose;

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
  final Function(BuildContext context, String tagID) didChangeDependencies;

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

class _StateBuilderState extends State<StateBuilder> {
  var _tag;
  String _tagID;
  String uniqueID;
  @override
  void initState() {
    super.initState();
    uniqueID = shortHash(this) + UniqueKey().toString();
    if (widget.tag is List) {
      _tag = <String>[];
      widget.tag.forEach((e) {
        final tempTags = addListener(
            widget.viewModels ?? widget.blocs, e, uniqueID, _listener);
        _tag.add(tempTags[0]);
        _tagID = tempTags[1];
      });
    } else {
      final tempTags = addListener(
          widget.viewModels ?? widget.blocs, widget.tag, uniqueID, _listener);
      _tag = tempTags[0];
      _tagID = tempTags[1];
    }

    if (widget.initState != null) widget.initState(context, _tagID);
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (widget.tag is List) {
      _tag?.forEach((e) {
        removeListener(
            widget.viewModels ?? widget.blocs, e, uniqueID, _listener);
      });
    } else {
      removeListener(
          widget.viewModels ?? widget.blocs, _tag, uniqueID, _listener);
    }

    if (widget.disposeViewModels == true) {
      (widget.viewModels ?? widget.blocs)
          ?.forEach((b) => (b as dynamic).dispose());
    }

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
