import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// enum is preferred over String to name your `stateID` for big projects.
// The nume of the enum is of your choice. You can have many enums.

// -- Conventionally for each of your BloCs you define a corresponding enum.
// -- For very large projects you can make all your enums in a single file.
enum CounterState { myCounter1, total }

// Our logic class a counter variable and a method to increment it.
//
// It must extend from StatesRebuilder.
class CounterBloc extends StatesRebuilder {
  int _counter1 = 0;
  int _counter2 = 0;

  int get counter1 => _counter1;
  int get counter2 => _counter2;

  void increment1() {
    // Increment the counter
    _counter1++;

    // First alternative.
    // Widgets with these stateIDs will rebuild to reflect the new counter value.
    rebuildStates([CounterState.myCounter1, CounterState.total]);
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

    // The all alternative

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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Provide your BloC
    return BlocProvider<CounterBloc>(
      bloc: CounterBloc(),
      child: MaterialApp(
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
    final counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //All widget that has a stateID will be rebuilt.
            //look at the increment3() method in the BloC.
            Text('The all alternative'),
            RaisedButton(
              child: Text("rebuildStates()"),
              onPressed: counterBloc.increment3,
            ),

            Divider(),

            Text('The first alternative'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IncrementFromOtheWidget(),
                // First Alternative:
                // -- Wrap the Text widget with StateBuilder widget and give it and id of your choice.
                // -- Declare the blocs where you want the state to be available.
                StateBuilder(
                  stateID: CounterState.myCounter1,
                  blocs: [counterBloc],
                  builder: (State state) => Text(
                        counterBloc.counter1.toString(),
                        style: Theme.of(state.context).textTheme.display1,
                      ),
                ),
              ],
            ),

            // The first method is mainly useful if you want to increment the counter from other widget

            Divider(),

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

            StateBuilder(
              stateID: CounterState.total,
              blocs: [counterBloc],
              builder: (_) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("The sum of the two counters is"),
                      Text(
                        " ${counterBloc._counter1 + counterBloc._counter2}",
                        style: Theme.of(context).textTheme.display1,
                      )
                    ],
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
