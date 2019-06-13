import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../blocs/counter_bloc.dart';

class SecondAlternative extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterBloc = Injector.get<CounterBloc>();
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
              viewModels: [counterBloc],
              builder: (context, tagID) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                        key: Key("secondAlternative"),
                        child: Text("increment from the same widget"),
                        onPressed: () => counterBloc.increment2(tagID),
                      ),
                      Text(
                        counterBloc.counter2.toString(),
                        style: Theme.of(context).textTheme.display1,
                      ),
                    ],
                  ),
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(secondAlternative),
              ),
            )
          ],
        ),
      ),
    );
  }
}

String secondAlternative = "Second Alternative:\n\n"
    "Your UI part:\n"
    "-- Wrap the Text widget with StateBuilder.\n"
    "-- Pass the state parameter to the increment2 method.\n"
    'StateBuilder(\n'
    '  builder: (Context, tagID) => Row(\n'
    '        mainAxisAlignment: MainAxisAlignment.spaceBetween,\n'
    '        children: <Widget>[\n'
    '          RaisedButton(\n'
    '            child: Text("increment from the same widget"),\n'
    '            onPressed: () => counterBloc.increment2(tagID),\n'
    '          ),\n'
    '          Text(\n'
    '            counterBloc.counter2.toString(),\n'
    '            style: Theme.of(context).textTheme.display1,\n'
    '          ),\n'
    '        ],\n'
    '      ),\n'
    '),\n\n'
    'Your BloC:'
    'void increment2(String tagID) {\n'
    '  _counter2++;\n'
    '  rebuildStates([tagID, CounterState.total]);\n\n'
    '  // Second alternative.\n'
    '  // Widgets from which the increment2 method is called will rebuild.\n'
    '}\n';
