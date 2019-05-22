library states_rebuilder;

import 'package:flutter/material.dart';

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder {
  Map<String, Map<String, VoidCallback>> _listeners =
      {}; //key holds the listener tags and the value holds the listeners

  /// Method to add listener to the _listeners Map
  addToListeners(
      {@required String tag,
      @required VoidCallback listener,
      @required String hashcode}) {
    _listeners[tag] ??= {};
    _listeners[tag][hashcode] = listener;
  }

  removeFromListeners(String tag, String hashcode) {
    List<String> keys = List.from(listeners[tag]?.keys);
    if (keys == null) return;
    keys.forEach((k) {
      if (k == hashcode) {
        listeners[tag].remove(k);

        return;
      }
    });
    if (listeners[tag].isEmpty) {
      listeners.remove(tag);
    }
  }

  /// listeners getter
  Map<String, Map<String, VoidCallback>> get listeners => _listeners;

  String spliter = "";

  /// You call `rebuildState` inside any of your logic classes that extends `StatesRebuilder`.
  rebuildStates([List<dynamic> tags]) {
    if (tags == null) {
      _listeners.forEach((_, v) {
        v?.forEach((__, listener) {
          if (listener != null) listener();
        });
      });
    } else {
      for (final tag in tags) {
        if (tag is String) {
          final split = tag?.split(spliter);
          if (split.length > 1 && _listeners[split[0]] != null) {
            _listeners[split[0]][split.last]();
            continue;
          }
        }

        final listenerList = _listeners["$tag"];
        listenerList?.forEach((_, listener) {
          if (listener != null) listener();
        });
      }
    }
  }
}

typedef _StateBuildertype = Widget Function(BuildContext context, String tagID);

abstract class _StateBuilder extends StatefulWidget {
  _StateBuilder({
    Key key,
    this.tag,
    this.blocs,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  final _StateBuildertype builder;
  final dynamic tag;
  final List<StatesRebuilder> blocs;
}

class StateBuilder extends _StateBuilder {
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
  final _StateBuildertype builder;

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
          BuildContext context, String tagID, _StateBuilder oldWidget)
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
        _addListener(widget.blocs, widget.tag, "$hashCode", _listener);
    _tag = tempTags[0];
    _tagID = tempTags[1];
    if (widget.initState != null) widget.initState(context, _tagID);
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _removeListner(widget.blocs, _tag, hashCode, _listener);

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
  void didUpdateWidget(_StateBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null)
      widget.didUpdateWidget(context, _tagID, oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _tagID);
  }
}

List<String> _addListener(List<StatesRebuilder> widgetBlocs, dynamic widgetTag,
    String hashcode, VoidCallback listener) {
  String tag, _tagID;

  if (widgetBlocs != null) {
    widgetBlocs.forEach(
      (StatesRebuilder b) {
        if (b == null) return null;
        tag = (widgetTag != null && widgetTag != "")
            ? "$widgetTag"
            : "#@dFau_Lt${b.hashCode}TaG30";
        _tagID = "$tag${b.spliter}$hashcode";
        b.addToListeners(tag: tag, listener: listener, hashcode: hashcode);
      },
    );
  }
  return [tag, _tagID];
}

void _removeListner(
  List<StatesRebuilder> widgetBlocs,
  String tag,
  int hashcode,
  VoidCallback listener,
) {
  if (widgetBlocs != null) {
    widgetBlocs.forEach(
      (StatesRebuilder b) {
        if (b == null) return;
        if (tag == null) return;
        b.removeFromListeners(tag, "$hashcode");
      },
    );
  }
}

class StateWithMixinBuilder<T> extends _StateBuilder {
  /// You wrap any part of your widgets with `StateBuilder` Widget to make it Reactive.
  /// When `rebuildState` method is called and referred to it, it will rebuild.
  StateWithMixinBuilder({
    Key key,
    this.tag,
    this.blocs,
    @required this.builder,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.didChangeAppLifecycleState,
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
          builder: builder,
        );

  ///```dart
  ///StateWithMixinBuilder(
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state.
  /// `StateWithMixinBuilder` widget can be rebuilt from the logic class using
  ///the `rebuildState` method.
  ///
  ///The builder is provided with an [BuildContext] and [String] parameters.
  ///
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  final _StateBuildertype builder;

  ///```dart
  ///StateWithMixinBuilder(
  ///  initState:(BuildContext context, String tagID, TickerProvider ticker)=> myBloc.init([context, tagID, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
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
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
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
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(String tagID, T mix) didChangeDependencies;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didUpdateWidget:(BuildContext context, String tagID,_StateBuilder oldWidget, TickerProvider ticker)=> myBloc.myMethod([context, tagID,oldWidget, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  ///The String parameter is a unique tag automatically generated to refer to this`StateWithMixinBuilder`.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(
          BuildContext context, String tagID, _StateBuilder oldWidget, T mix)
      didUpdateWidget;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeAppLifecycleState:(BuildContext context, String tagID, AppLifecycleState state)=> myBloc.myMethod([context, tagID, state]),
  ///  MixinWith : MixinWith.widgetsBindingObserver
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
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

  ///```dart
  ///StateWithMixinBuilder(
  ///  blocs:[myBloc1, myBloc2,myBloc3],//If you want this widget to not rebuild, do not define any bloc.
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, String tagID) =>Mywidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extand  `StatesWithMixinRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> blocs;

  ///An enum of Pre-defined mixins (ex: MixinWith.tickerProviderStateMixin)
  final MixinWith mixinWith;

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
        return _StateBuilderState();
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
      widget.dispose(context, _tagID, _tiker);
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
      widget.dispose(context, _tagID, _tiker);
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
}

class _StateBuilderStateWidgetsBindingObserver
    extends _StateBuilderStateWithMixin<WidgetsBindingObserver>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.didChangeAppLifecycleState != null)
      widget.didChangeAppLifecycleState(context, _tagID, state);
  }
}

class _StateBuilderStateWithMixin<T> extends State<StateWithMixinBuilder> {
  String _tag, _tagID;
  T _tiker;

  @override
  void initState() {
    super.initState();

    final tempTags =
        _addListener(widget.blocs, widget.tag, "$hashCode", _listener);
    _tag = tempTags[0];
    _tagID = tempTags[1];

    _tiker = this as T;
    if (widget.initState != null) widget.initState(context, _tagID, _tiker);
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _removeListner(widget.blocs, _tag, hashCode, _listener);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null)
      widget.didChangeDependencies(_tagID, _tiker);
  }

  @override
  void didUpdateWidget(_StateBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null)
      widget.didUpdateWidget(context, _tagID, oldWidget, _tiker);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _tagID);
  }
}

class _BlocProvider<T> extends InheritedWidget {
  final bloc;
  _BlocProvider({Key key, @required this.bloc, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_) => false;
}

class BlocProvider<T> extends StatefulWidget {
  final Widget child;
  final T bloc;
  BlocProvider({@required this.child, @required this.bloc});

  static T of<T>(BuildContext context) {
    final type = _typeOf<_BlocProvider<T>>();

    _BlocProvider<T> provider =
        context.ancestorInheritedElementForWidgetOfExactType(type)?.widget;
    return provider?.bloc;
  }

  static Type _typeOf<T>() => T;

  @override
  _BlocProviderState createState() => _BlocProviderState<T>();
}

class _BlocProviderState<T> extends State<BlocProvider> {
  _BlocProvider<T> _blocProvider;
  @override
  void initState() {
    super.initState();
    _blocProvider = _BlocProvider<T>(
      bloc: widget.bloc,
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _blocProvider;
  }
}
