library states_rebuilder;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder {
  Map<dynamic, List<Map<String, dynamic>>> _innerMap =
      {}; //key holds the stateID and the value holds the state

  /// Method to add state to the stateMap
  addToInnerMap({dynamic id, int hashCode, Function fn, bool add: false}) {
    if (add) {
      _innerMap[id] = _innerMap[id] ?? [];
      _innerMap[id].add({
        "hashCode": hashCode,
        "fn": fn,
      });
    } else {
      _innerMap[id] = [
        {
          "hashCode": hashCode,
          "fn": fn,
        }
      ];
    }
  }

  /// stateMap getter
  Map<dynamic, List<dynamic>> get innerMap => _innerMap;

  /// You call `rebuildState` inside any of your logic classes that extends `StatesRebuilder`.
  /// It offers you two alternatives to rebuild any of your widgets.
  ///
  ///  `setState` : an optional VoidCallback to execute inside the Flutter setState() method
  ///
  ///  `ids`: First alternative to rebuild a particular widget indirectly by giving its id
  ///
  ///  `states` : Second alternative to rebuild a particular widget directly by giving its State

  rebuildStates([List<dynamic> states]) {
    // final __s = new DateTime.now().microsecondsSinceEpoch;
    if (states != null) {
      for (final state in states) {
        if (state == null) continue;
        if (state is _StateBuilderState) {
          state._setState();
        } else {
          final ss = _innerMap[state];
          if (ss == null) continue;
          ss.forEach((e) {
            e["fn"]();
          });
        }
      }
    } else {
      if (_innerMap.isNotEmpty) {
        _innerMap.forEach((k, v) {
          v?.forEach((e) {
            e["fn"]();
          });
        });
      }
    }
    // print(new DateTime.now().microsecondsSinceEpoch - __s);
  }
}

typedef _StateBuildertype = Widget Function(State state);

class StateBuilder extends StatefulWidget {
  /// You wrap any part of your widgets with `StateBuilder` Widget to make it available inside your logic classes and hence can rebuild it using `rebuildState` method
  ///
  ///  `stateID`: you define the ID of the state. This is the first alternative
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
  StateBuilder({
    Key key,
    this.stateID,
    this.blocs,
    @required this.builder,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
  })  : assert(builder != null),
        assert(stateID == null ||
            blocs != null), // blocs must not be null if the stateID is given
        super(key: key);

  ///The build strategy currently used update the state.
  ///StateBuilder widget can berebuilt from the logic class using
  ///the `rebuildState` method.
  ///
  ///The builder is provided with an [State] object.
  @required
  final _StateBuildertype builder;

  ///Called when this object is inserted into the tree.
  final void Function(State state) initState;

  ///Called when this object is removed from the tree permanently.
  final void Function(State state) dispose;

  ///Called when a dependency of this [State] object changes.
  final void Function(State state) didChangeDependencies;

  ///Called whenever the widget configuration changes.
  final void Function(StateBuilder oldWidget, State state) didUpdateWidget;

  ///Uunique name of your Animator widget. It is used to rebuild this widget
  ///from your logic classes.
  final dynamic stateID;

  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extand  `StatesRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> blocs;

  @override
  _StateBuilderState createState() => _StateBuilderState();
}

class _StateBuilderState extends State<StateBuilder> {
  @override
  void initState() {
    super.initState();
    if (widget.stateID != null && widget.stateID != "") {
      if (widget.blocs != null) {
        widget.blocs.forEach(
          (b) {
            if (b == null) return;
            b.addToInnerMap(
                id: widget.stateID,
                hashCode: this.hashCode,
                fn: () {
                  if (mounted) setState(() {});
                });
            print(" initState ${b._innerMap.length}");
          },
        );
      }
    }

    if (widget.initState != null) widget.initState(this);
  }

  _setState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (widget.stateID != null && widget.stateID != "") {
      if (widget.blocs != null) {
        widget.blocs.forEach(
          (b) {
            if (b == null) return;
            if (b.innerMap[widget.stateID] == null) return;
            if (b.innerMap[widget.stateID][0] == null) return;
            print(" dispose ${b._innerMap.length}");
            if (b.innerMap[widget.stateID][0]["hashCode"] == this.hashCode) {
              b.innerMap.remove(widget.stateID);
            }
            print(" dispose ${b._innerMap.length}");
          },
        );
      }
    }

    if (widget.dispose != null) widget.dispose(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null)
      widget.didChangeDependencies(this);
  }

  @override
  void didUpdateWidget(StateBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null) widget.didUpdateWidget(oldWidget, this);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(this);
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
