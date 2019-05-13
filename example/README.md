# counter_app with TabView

```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// enum is preferred over String to name your `stateID` for big projects.
// The name of the enums is of your choice. You can have many enums.

// -- Conventionally for each of your BloCs you define a corresponding enum.
// -- For very large projects you can make all your enums in a single file.

enum CounterState { firstAlternative, total }

// Our logic class a counter variable and a method to increment it.
//
// It must extend from `StatesRebuilder`.
class CounterBloc extends StatesRebuilder {
  TabController _tabController;

  int _counter1 = 0;
  int _counter2 = 0;

  int get counter1 => _counter1;
  int get counter2 => _counter2;
  int get total => _counter1 + _counter2;

  initState(State state) {
    _tabController =
        TabController(vsync: state as TickerProvider, length: choices.length);
  }

  void _nextPage(int delta) {
    final int newIndex = _tabController.index + delta;
    if (newIndex < 0 || newIndex >= _tabController.length) return;
    _tabController.animateTo(newIndex);
  }

  dispose() {
    _tabController.dispose();
  }

  void increment1() {
    // Increment the counter
    _counter1++;

    // First alternative.
    // Widgets with these stateIDs will rebuild to reflect the new counter value.
    rebuildStates([CounterState.firstAlternative, CounterState.total]);
  }

  void increment2(State state) {
    // Increment the counter
    _counter2++;

    // Second alternative.
    // Widgets from which the increment2 method is called will rebuild.
    // You can mix states and stateIDs
    rebuildStates([state, CounterState.total]);
  }

  void increment3() {
    // increment the counter
    _counter1++;

    // The third alternative

    // `rebuildStates()` with no parameter: All widgets that are wrapped with `StateBuilder` and
    // are given `stateID` will rebuild to reflect the new counter value.
    //
    // you get a similar behavior like in scoped_model or provider packages
    rebuildStates();
    // in this particular example we have two widgets that have
    // a stateID (CounterState.myCounter, and CounterState.total)
  }
}

void main() {
  runApp(CounterTabApp());
}

// ************ Provide your BloC using BlocProvider ******************
class CounterTabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterBloc>(
      bloc: CounterBloc(),
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}

/*
  / ************ Provide your BloC using StateBuilder ******************
  // You can provide your BloC using StateBuilder:
  //In your BloC file declare  a variable with your BloC as type
  //Here as we are in the same file we write:

  CounterBloc counterBloc;

  //It is important to not initialize it now
  //In your UI file:
  class CounterTabApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return StateBuilder(
        initState: (_) => counterBloc = CounterBloc(),
        dispose: (_) => counterBloc = null,
        builder: (_) => MaterialApp(
              home: MyHomePage(),
            ),
      );
    }
  }
  // Now your BloC is available only to all child widgets of the MaterialApp widget
  // Your BloC is alive as long as the MaterialApp is mounted. 
  // When the MaterialApp is disposed the bloc is killed, and for this reason only child widgets can access to the BloC
  //
  // In this case you do not have to use:
  // final counterBloc = BlocProvider.of<CounterBloc>(context);
  // To try this approach comment all the "of" methods bellow.
*/

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    return StateBuilder(
      withTickerProvider: true,
      initState: (state) => counterBloc.initState(state),
      dispose: (_) => counterBloc.dispose(),
      builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('states_rebuilder'),
              leading: IconButton(
                tooltip: 'Previous choice',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  counterBloc._nextPage(-1);
                },
              ),
              actions: <Widget>[
                StateBuilder(
                  stateID: CounterState.total,
                  blocs: [counterBloc],
                  builder: (_) => CircleAvatar(
                        child: Text("${counterBloc.total}"),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Next choice',
                  onPressed: () {
                    counterBloc._nextPage(1);
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48.0),
                child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.white),
                  child: Container(
                    height: 48.0,
                    alignment: Alignment.center,
                    child:
                        TabPageSelector(controller: counterBloc._tabController),
                  ),
                ),
              ),
            ),
            body: TabBarView(
              controller: counterBloc._tabController,
              children: choices,
            ),
          ),
    );
  }
}

final List<Widget> choices = [
  FirstAlternative(),
  SecondAlternative(),
  ThirdAlternative(),
];

class FirstAlternative extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('The first alternative'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IncrementFromOtheWidget(),
                StateBuilder(
                  stateID: CounterState.firstAlternative,
                  blocs: [counterBloc],
                  builder: (State state) => Text(
                        counterBloc.counter1.toString(),
                        style: Theme.of(state.context).textTheme.display1,
                      ),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(firstAlternativeTuto),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SecondAlternative extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('The second alternative'),

            // Second Alternative:
            // -- Wrap the Text widget with StateBuilder widget without giving it an id.
            // -- Pass the state parameter to the increment2 method.
            StateBuilder(
              builder: (State state) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                        key: Key("secondAlternative"),
                        child: Text("increment from the same widget"),
                        onPressed: () => counterBloc.increment2(state),
                      ),
                      Text(
                        counterBloc.counter2.toString(),
                        style: Theme.of(state.context).textTheme.display1,
                      ),
                    ],
                  ),
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(secondAlternativeTuto),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ThirdAlternative extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('The Third alternative'),
            //All widget that has a stateID will be rebuilt.
            //look at the increment3() method in the BloC.
            RaisedButton(
              child: Text("rebuildStates()"),
              onPressed: counterBloc.increment3,
            ),
            Text(
                "Navigate back to the first tab to see that the first counter is incremented"),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(thirdAlternativeTuto),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class IncrementFromOtheWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    return RaisedButton(
      key: Key("firstAlternative"),
      child: Text("increment from other widget"),
      onPressed: counterBloc.increment1,
    );
  }
}

String firstAlternativeTuto = "First Alternative:\n\n"
    "Your UI part:\n"
    "-- Wrap the Text widget with StateBuilder widget and give it and id of your choice.\n"
    "-- Declare the blocs where you want the state to be available.\n"
    "StateBuilder(\n"
    "  stateID: CounterState.firstAlternative,\n"
    "  blocs: [counterBloc],\n"
    "  builder: (State state) => Text(\n"
    "        counterBloc.counter1.toString(),\n"
    "        style: Theme.of(state.context).textTheme.display1,\n"
    "      ),\n"
    "),\n\n"
    "Your Bloc\n"
    "void increment1() {\n"
    "_counter1++;\n\n"
    "rebuildStates([CounterState.firstAlternative, CounterState.total]);\n\n"
    "// First alternative.\n"
    "// Widgets with these stateIDs will rebuild to reflect the new counter value.\n"
    " }";

String secondAlternativeTuto = "Second Alternative:\n\n"
    "Your UI part:\n"
    "-- Wrap the Text widget with StateBuilder widget without giving it an id.\n"
    "-- Pass the state parameter to the increment2 method.\n"
    'StateBuilder(\n'
    '  builder: (State state) => Row(\n'
    '        mainAxisAlignment: MainAxisAlignment.spaceBetween,\n'
    '        children: <Widget>[\n'
    '          RaisedButton(\n'
    '            child: Text("increment from the same widget"),\n'
    '            onPressed: () => counterBloc.increment2(state),\n'
    '          ),\n'
    '          Text(\n'
    '            counterBloc.counter2.toString(),\n'
    '            style: Theme.of(state.context).textTheme.display1,\n'
    '          ),\n'
    '        ],\n'
    '      ),\n'
    '),\n\n'
    'Your BloC:'
    'void increment2(State state) {\n'
    '  _counter2++;\n'
    '  rebuildStates([state, CounterState.total]);\n\n'
    '  // Second alternative.\n'
    '  // Widgets from which the increment2 method is called will rebuild.\n'
    '  // You can mix states and stateIDs\n'
    '}\n';

String thirdAlternativeTuto = 'Third alternative\n\n'
    'Your UI part\n'
    '//All widget that has a stateID will be rebuilt.\n'
    '//look at the increment3() method in the BloC.\n'
    'RaisedButton(\n'
    '  child: Text("rebuildStates()"),\n'
    '  onPressed: counterBloc.increment3,\n'
    '),\n'
    'Your Bloc Part\n'
    'void increment3() {\n'
    '  _counter1++;\n'
    '  rebuildStates();\n\n'
    '  // `rebuildStates()` with no parameter: All widgets that are wrapped with `StateBuilder` and\n'
    '  // are given `stateID` will rebuild to reflect the new counter value.\n'
    '  //\n'
    '  // you get a similar behavior like in scoped_model or provider packages\n'
    '}\n';

```
