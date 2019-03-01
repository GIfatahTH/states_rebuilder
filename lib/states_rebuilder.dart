library states_rebuilder;

import 'package:flutter/material.dart';

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder extends State {
  Map<String, State> _stateMap =
      {}; //key holds the stateID and the value holds the state

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
          final State ss = _stateMap[s];print(ss);
          if (ss != null && ss.mounted) ss.setState(setState ?? () {});
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
class StateBuilder extends StatefulWidget {
  @required
  final _StateBuildertype builder;
  final void Function(State state) initState, dispose, didChangeDependencies;
  final void Function(StateBuilder oldWidget, State state) didUpdateWidget;
  final String stateID;
  final List<StatesRebuilder> blocs;

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
            b._stateMap[widget.stateID] = this;
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
            if (b._stateMap[widget.stateID].hashCode == this.hashCode) {
              b._stateMap.remove(widget.stateID);
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
