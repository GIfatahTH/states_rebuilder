import 'package:counter_app/states_rebuilder_basic_example/blocs/counter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class FirstAlternative extends StatelessWidget {
  final counterBloc = Injector.get<CounterBloc>();
  @override
  Widget build(BuildContext context) {
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
                IncrementFromOtherWidget(),
                StateBuilder(
                  tag: CounterState.firstAlternative,
                  viewModels: [counterBloc],
                  builder: (context, _) => Text(
                        counterBloc.counter1.toString(),
                        style: Theme.of(context).textTheme.display1,
                      ),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(firstAlternative),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class IncrementFromOtherWidget extends StatelessWidget {
  final counterBloc = Injector.get<CounterBloc>();
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      key: Key("firstAlternative"),
      child: Text("increment from other widget"),
      onPressed: counterBloc.increment1,
    );
  }
}

String firstAlternative = "First Alternative:\n\n"
    "Your UI part:\n"
    "-- Wrap the Text widget with StateBuilder widget and give it and tag of your choice.\n"
    "-- Declare the ViewModels where you want rebuild this widget from.\n"
    "--  A ViewModels is any logic class that extends the StatesRebuilder.\n"
    "StateBuilder(\n"
    "  tag: CounterState.firstAlternative,\n"
    "  viewModels: [counterBloc],\n"
    "  builder: (Context, tagID) => Text(\n"
    "        counterBloc.counter1.toString(),\n"
    "        style: Theme.of(context).textTheme.display1,\n"
    "      ),\n"
    "),\n\n"
    "Your Bloc\n"
    "void increment1() {\n"
    "_counter1++;\n\n"
    "rebuildStates([CounterState.firstAlternative, CounterState.total]);\n\n"
    "// First alternative.\n"
    "// Widgets with these tags will rebuild to reflect the new counter value.\n"
    " }";
