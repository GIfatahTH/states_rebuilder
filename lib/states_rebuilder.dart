library states_rebuilder;

import 'package:flutter/widgets.dart';

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder {
  Map<dynamic, List<VoidCallback>> _listeners =
      {}; //key holds the listener tags and the value holds the listeners
  // String _defaultTag;

  /// Method to add listener to the _listeners
  addToListeners({dynamic tag, VoidCallback listener}) {
    _listeners[tag] ??= [];
    _listeners[tag].add(listener);
  }

  /// listeners getter
  Map<dynamic, List<dynamic>> get listeners => _listeners;

  /// You call `rebuildState` inside any of your logic classes that extends `StatesRebuilder`.
  rebuildStates([List<dynamic> tags]) {
    if (tags == null) {
      _listeners.forEach((k, v) {
        v?.forEach((listener) {
          if (listener != null) listener();
        });
      });
    } else {
      for (final tag in tags) {
        if (tag is String) {
          final split = tag?.split("|#$hashCode#|");
          if (split.length > 1) {
            _listeners[split[0]][int.parse(split[1])]();
            return;
          }
        }
        final listenerList = _listeners[tag];
        listenerList?.forEach((listener) {
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
        // assert(stateID == null ||
        //     blocs != null), // blocs must not be null if the stateID is given
        super(key: key);
  final _StateBuildertype builder;
  final dynamic tag;
  final List<StatesRebuilder> blocs;
}

class StateBuilder extends _StateBuilder {
  /// You wrap any part of your widgets with `StateBuilder` Widget to make it available inside your logic classes and hence can rebuild it using `rebuildState` method
  ///
  ///  `tag`: you define the tag of the state. This is the first alternative
  ///  `blocs`: You give a list of the logic classes (BloC) you want this ID will be available.
  ///
  ///  `builder` : You define your top most Widget
  ///
  ///  `initState` : for code to be executed in the initState of a StatefulWidget
  ///
  ///  `dispose`: for code to be executed in the dispose of a StatefulWidget
  ///
  ///  `didChangeDependencies`: for code to be executed in the didChangeDependencies of a StatefulWidget
  ///
  ///  `didUpdateWidget`: for code to be executed in the didUpdateWidget of a StatefulWidget
  ///
  /// `withTickerProvider`

  StateBuilder({
    Key key,
    this.tag,
    this.blocs,
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

  ///The build strategy currently used ot rebuild the state.
  ///StateBuilder widget can berebuilt from the logic class using
  ///the `rebuildState` method.
  ///
  ///The builder is provided with an [BuildContext] and [String] parameters.
  final _StateBuildertype builder;

  ///Called when this object is inserted into the tree.
  final void Function(String tagID) initState;

  ///Called when this object is removed from the tree permanently.
  final void Function(String tagID) dispose;

  ///Called when a dependency of this [State] object changes.
  final void Function(String tagID) didChangeDependencies;

  ///Called whenever the widget configuration changes.
  final void Function(_StateBuilder oldWidget, String tagID) didUpdateWidget;

  ///Unique name of your widget. It is used to rebuild this widget
  ///from your logic classes.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  final dynamic tag;

  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extand  `StatesRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> blocs;

  _StateBuilderState createState() {
    return _StateBuilderState();
  }
}

String _addListener(List<StatesRebuilder> widgetBlocs, dynamic widgetTag,
    dynamic tag, VoidCallback listener) {
  if (widgetBlocs != null) {
    widgetBlocs.forEach(
      (b) {
        if (b == null) return null;
        tag = (widgetTag != null && widgetTag != "")
            ? widgetTag
            : "#@dFaLt${b.hashCode}TaG30";
        final _tagID = "$tag|#${b.hashCode}#|${b._listeners[tag]?.length ?? 0}";

        b.addToListeners(
          tag: tag,
          listener: listener,
        );
        return _tagID;
      },
    );
  }
  return null;
}

void _removeListner(widgetBlocs, dynamic tag, VoidCallback listener) {
  if (widgetBlocs != null) {
    widgetBlocs.forEach(
      (b) {
        if (b == null) return;
        if (tag == null) return;
        final entry = b.listeners[tag];
        if (entry == null) return;
        for (var e in entry) {
          if (e == listener) {
            entry.remove(e);
            break;
          }
        }
        if (entry.isEmpty) {
          b.listeners.remove(tag);
        }
      },
    );
  }
}

class _StateBuilderState extends State<StateBuilder> {
  dynamic _tag;
  String _tagID;

  @override
  void initState() {
    super.initState();
    _tagID = _addListener(widget.blocs, widget.tag, _tag, _listener);

    if (widget.initState != null) widget.initState(_tagID);
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _removeListner(widget.blocs, _tag, _listener);

    if (widget.dispose != null) widget.dispose(_tagID);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null)
      widget.didChangeDependencies(_tagID);
  }

  @override
  void didUpdateWidget(_StateBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null)
      widget.didUpdateWidget(oldWidget, _tagID);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _tagID);
  }
}

class StateWithMixinBuilder<T> extends _StateBuilder {
  /// You wrap any part of your widgets with `StateBuilder` Widget to make it available inside your logic classes and hence can rebuild it using `rebuildState` method
  ///
  ///  `tag`: you define the tag of the Listener. This is the first alternative
  ///  `blocs`: You give a list of the logic classes (BloC) you want this ID will be available.
  ///
  ///  `builder` : You define your top most Widget
  ///
  ///  `initState` : for code to be executed in the initState of a StatefulWidget
  ///
  ///  `dispose`: for code to be executed in the dispose of a StatefulWidget
  ///
  ///  `didChangeDependencies`: for code to be executed in the didChangeDependencies of a StatefulWidget
  ///
  ///  `didUpdateWidget`: for code to be executed in the didUpdateWidget of a StatefulWidget
  ///
  /// `withMixin`

  StateWithMixinBuilder({
    Key key,
    this.tag,
    this.blocs,
    @required this.builder,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    @required this.mixinWith,
  }) : super(
          key: key,
          tag: tag,
          blocs: blocs,
          builder: builder,
        );

  ///The build strategy currently used update the state.
  ///StateBuilder widget can berebuilt from the logic class using
  ///the `rebuildState` method.
  ///
  ///The builder is provided with an [State] object.
  @required
  final _StateBuildertype builder;

  ///Called when this object is inserted into the tree.
  final void Function(String tagID, T mix) initState;

  ///Called when this object is removed from the tree permanently.
  final void Function(String tagID, T mix) dispose;

  ///Called when a dependency of this [State] object changes.
  final void Function(String tagID, T mix) didChangeDependencies;

  ///Called whenever the widget configuration changes.
  final void Function(_StateBuilder oldWidget, String tagID, T mix)
      didUpdateWidget;

  ///Unique name of your widget. It is used to rebuild this widget
  ///from your logic classes.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  final dynamic tag;

  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extand  `StatesRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> blocs;

  ///set to true if you want your state class to mix with `TickerProviderStateMixin`
  ///Default value is false.
  final MixinWith mixinWith;

  createState() {
    switch (mixinWith) {
      case MixinWith.tickerProviderStateMixin:
        assert(() {
          if (initState == null || dispose == null) {
            throw FlutterError('`initState` `dispose` must not be null\n'
                'You are using `TickerProviderStateMixin` so you have to instantiate \n'
                'your controllers in the initState() and dispose them in the dispose() method\n'
                'If you do not need to use any controller set `withTickerProvider` to false');
          }
          return true;
        }());
        return _StateBuilderStateTickerMix();
        break;
      case MixinWith.singleTickerProviderStateMixin:
        assert(() {
          if (initState == null || dispose == null) {
            throw FlutterError('`initState` `dispose` must not be null\n'
                'You are using `TickerProviderStateMixin` so you have to instantiate \n'
                'your controllers in the initState() and dispose them in the dispose() method\n'
                'If you do not need to use any controller set `withTickerProvider` to false');
          }
          return true;
        }());
        return _StateBuilderStateSingleTickerMix();
        break;
      default:
        return _StateBuilderState();
    }
  }
}

enum MixinWith { tickerProviderStateMixin, singleTickerProviderStateMixin }

class _StateBuilderStateTickerMix
    extends _StateBuilderStateWithMixin<TickerProviderStateMixin>
    with TickerProviderStateMixin {
  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose(_tagID, _tiker);
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
      widget.dispose(_tagID, _tiker);
    }
    super.dispose();
  }
}

class _StateBuilderStateWithMixin<T> extends State<StateWithMixinBuilder> {
  String _tag;
  String _tagID;
  T _tiker;
  @override
  void initState() {
    super.initState();

    _tagID = _addListener(widget.blocs, widget.tag, _tag, _listener);
    _tiker = this as T;
    if (widget.initState != null) widget.initState(_tagID, _tiker);
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _removeListner(widget.blocs, _tag, _listener);
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
      widget.didUpdateWidget(oldWidget, _tagID, _tiker);
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

    _BlocProvider<T> provider = context.inheritFromWidgetOfExactType(type);
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
