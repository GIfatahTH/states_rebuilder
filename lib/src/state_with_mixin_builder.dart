import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'states_rebuilder.dart';
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
  final void Function(String tagID, T mix) didChangeDependencies;

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
        return _StateBuilderStateTickerMix();
        break;
      case MixinWith.singleTickerProviderStateMixin:
        return _StateBuilderStateSingleTickerMix();
        break;
      case MixinWith.automaticKeepAliveClientMixin:
        return _StateBuilderStateAutomaticKeepAliveClient();
        break;
      case MixinWith.widgetsBindingObserver:
        return _StateBuilderStateWidgetsBindingObserver();
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

class _StateBuilderStateTickerMix
    extends _StateBuilderStateWithMixin<TickerProviderStateMixin>
    with TickerProviderStateMixin {
  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose(context, _tagID, _ticker);
    } else if (widget.disposeViewModels) {
      (widget.viewModels ?? widget.blocs)
          ?.forEach((b) => (b as dynamic).dispose());
    }
    super.dispose();
  }
}

class _StateBuilderStateSingleTickerMix
    extends _StateBuilderStateWithMixin<SingleTickerProviderStateMixin>
    with SingleTickerProviderStateMixin {
  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose(context, _tagID, _ticker);
    } else if (widget.disposeViewModels == true) {
      (widget.viewModels ?? widget.blocs)
          ?.forEach((b) => (b as dynamic).dispose());
    }
    super.dispose();
  }
}

class _StateBuilderStateAutomaticKeepAliveClient
    extends _StateBuilderStateWithMixin
    with AutomaticKeepAliveClientMixin<StateWithMixinBuilder> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.builder(context, _tagID);
  }

  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose(context, _tagID, _ticker);
    } else if (widget.disposeViewModels == true) {
      (widget.viewModels ?? widget.blocs)
          ?.forEach((b) => (b as dynamic).dispose());
    }
    super.dispose();
  }
}

class _StateBuilderStateWidgetsBindingObserver
    extends _StateBuilderStateWithMixin<WidgetsBindingObserver>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.didChangeAppLifecycleState != null)
      widget.didChangeAppLifecycleState(context, _tagID, state);
  }

  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose(context, _tagID, _ticker);
    } else if (widget.disposeViewModels == true) {
      (widget.viewModels ?? widget.blocs)
          ?.forEach((b) => (b as dynamic).dispose());
    }
    super.dispose();
  }
}

class _StateBuilderStateWithMixin<T> extends State<StateWithMixinBuilder> {
  var _tag;
  String _tagID;
  T _ticker;
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

    _ticker = this as T;
    if (widget.initState != null) widget.initState(context, _tagID, _ticker);
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
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null)
      widget.didChangeDependencies(_tagID, _ticker);
  }

  @override
  void didUpdateWidget(StateBuilderBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null)
      widget.didUpdateWidget(context, _tagID, oldWidget, _ticker);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _tagID);
  }
}
