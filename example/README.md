# counter_app

```dart

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// Our logic class a counter variable and a method to increment it.
//
// It must extend from StatesRebuilder.
class CounterBloc extends StatesRebuilder {
  int _counter1 = 0;
  int _counter2 = 0;

  int get counter1 => _counter1;
  int get counter2 => _counter2;

  void increment1() {
    // First, increment the counter
    _counter1++;

    // First alternative.
    // Use the ids parameters to enter a list of ids.
    // Widgets with these ids will rebuild to reflect the new counter value.
    rebuildStates(ids: ["myCounter"]);
  }

  void increment2(State state) {
    // First, increment the counter
    _counter2++;

    // First alternative.
    // Use the ids parameters to enter a list of ids.
    // Widgets with these ids will rebuild to reflect the new counter value.
    rebuildStates(states: [state]);
  }
}

// For simplicity I use this method to provide the CounterBloc:
// Declare the counterBloc without instantiating it
//
// NOTE: You can use the InheritedWidget to provide the CounterBloc
CounterBloc counterBloc;



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // At the top level of our widget tree where we want to provide the CounterBloc to all its children, we create a StateBuilder Widget.
    // We instantiate the counterBloc variable in the initState parameter, and kill it in the dispose parameter.
    return StateBuilder(
      initState: (_) => counterBloc = CounterBloc(),
      dispose: (_) => counterBloc = null,
      builder: (_) => MaterialApp(
            title: 'states_rebuilder Example',
            home: Counter('States_Rebuilder demostration'),
          ),
    );
  }
}

class Counter extends StatelessWidget {
  final String title;

  Counter(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Divider(),
            Text('The first alternative'),

            // First Alternative:
            // -- Wrap the Text widget with StateBuilder widget and give it and id of your choice.
            // -- Declare the blocs where you want the state to be available.
            StateBuilder(
              stateID: 'myCounter',
              blocs: [counterBloc],
              builder: (State state) => Text(
                    counterBloc.counter1.toString(),
                    style: Theme.of(state.context).textTheme.display1,
                  ),
            ),

            // The first method is mainly useful if you want to increment the counter from other widget
            IncrementFromOtheWidget(),
            Divider(),
            Text('The second alternative'),

            // Second Alternative:
            // -- Wrap the Text widget with StateBuilder widget without giving it an id.
            // -- Declare the blocs where you want the state to be available.
            StateBuilder(
              builder: (State state) => Column(
                    children: <Widget>[
                      Text(
                        counterBloc.counter2.toString(),
                        style: Theme.of(state.context).textTheme.display1,
                      ),
                      RaisedButton(
                        key: Key("secondAlternative"),
                        child: Text("increment the same widget"),
                        onPressed: () => counterBloc.increment2(state),
                      )
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncrementFromOtheWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      key: Key("firstAlternative"),
      child: Text("increment from other widget"),
      onPressed: counterBloc.increment1,
    );
  }
}


```
