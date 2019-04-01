library states_rebuilder;

import 'package:flutter/material.dart';

typedef _mapValueType = void Function(VoidCallback fn);

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder extends State {
  Map<String, List<List<dynamic>>> _innerMap =
      {}; //key holds the stateID and the value holds the state

  /// Method to add state to the stateMap
  addToInnerMap({String id, State state, Function fn, bool add: false}) {
    if (add) {
      _innerMap[id] = _innerMap[id] ?? [];
      _innerMap[id].add([state, fn]);
    } else {
      _innerMap[id] = [
        [state, fn]
      ];
    }
  }

  /// stateMap getter
  Map<String, List<dynamic>> get innerMap => _innerMap;

  /// You call `rebuildState` inside any of your logic classes that extends `StatesRebuilder`.
  /// It offers you two alternatives to rebuild any of your widgets.
  ///
  ///  `setState` : an optional VoidCallback to execute inside the Flutter setState() method
  ///
  ///  `ids`: First alternative to rebuild a particular widget indirectly by giving its id
  ///
  ///  `states` : Second alternative to rebuild a particular widget directly by giving its State
  rebuildStates({VoidCallback setState, List<State> states, List<String> ids}) {
    if (states != null) {
      states.forEach((s) {
        if (s != null && s.mounted) s.setState(setState ?? () {});
      });
    }

    if (ids != null) {
      ids.forEach(
        (s) {
          final ss = _innerMap[s];
          if (ss != null) {
            final _mapValueType sss = ss[0][1];
            sss(setState ?? () {});
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //"This build function will never be called. it has to be overridden here because State interface requires this"
    return Container();
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
  final String stateID;

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
                state: this,
                fn: (fn) {
                  if (mounted) setState(fn);
                });
          },
        );
      }
    }

    if (widget.initState != null) widget.initState(this);
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
            if (b.innerMap[widget.stateID][0][0].hashCode == this.hashCode) {
              b.innerMap.remove(widget.stateID);
            }
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
