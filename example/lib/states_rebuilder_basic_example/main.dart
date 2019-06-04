import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// enum is preferred over String to name your `tag` for big projects.
// The name of the enums is of your choice. You can have many enums.

// -- Conventionally for each of your BloCs you define a corresponding enum.
// -- For very large projects you can make all your enums in a single file.

enum CounterState { firstAlternative, total }

// Our logic class a counter variable and a method to increment it.
//
// It must extend from StatesRebuilder.
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

  void nextPage(int delta) {
    final int newIndex = _tabController.index + delta;
    if (newIndex < 0 || newIndex >= _tabController.length) return;
    _tabController.animateTo(newIndex);
  }

  dispose() {
    _tabController.dispose();
    print("tab Controller is disposed");
  }

  void increment1() {
    // Increment the counter
    _counter1++;
    // First alternative.
    // Widgets with these stateIDs will rebuild to reflect the new counter value.
    rebuildStates([CounterState.firstAlternative, CounterState.total]);
  }

  void increment2(String tagID) {
    // Increment the counter
    _counter2++;

    // Second alternative.
    // Widgets from which the increment2 method is called will rebuild.
    // You can mix states and stateIDs
    rebuildStates([null, tagID, null, CounterState.total, null]);
  }

  void increment3() {
    // increment the counter
    _counter1++;
    // The third alternative

    // `rebuildStates()` with no parameter: All widgets that are wrapped with `StateBuilder` and
    // are given `tag` will rebuild to reflect the new counter value.
    //
    // you get a similar behavior like in scoped_model or provider packages
    rebuildStates();
    // in this particular example we have two widgets that have
    // a tag (CounterState.myCounter, and CounterState.total)
  }
}

// Provide your BloC using BlocProvider:
class CounterTabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => CounterBloc()],
      builder: (_) => MaterialApp(
            home: MyHomePage(),
          ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final counterBloc = Injector.get<CounterBloc>();
  @override
  Widget build(BuildContext context) {
    return StateWithMixinBuilder(
      mixinWith: MixinWith.singleTickerProviderStateMixin,
      initState: (_, __, ticker) => counterBloc.initState(ticker),
      dispose: (_, __, ___) => counterBloc.dispose(),
      builder: (_, __) => Scaffold(
            appBar: AppBar(
              title: const Text('states_rebuilder'),
              leading: IconButton(
                tooltip: 'Previous choice',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  counterBloc.nextPage(-1);
                },
              ),
              actions: <Widget>[
                StateBuilder(
                  tag: CounterState.total,
                  viewModels: [counterBloc],
                  builder: (_, __) => CircleAvatar(
                        child: Text("${counterBloc.total}"),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Next choice',
                  onPressed: () {
                    counterBloc.nextPage(1);
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
                IncrementFromOtheWidget(),
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
  final counterBloc = Injector.get<CounterBloc>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('The Third alternative'),
            //All widget that has a tag will be rebuilt.
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

String firstAlternativeTuto = "First Alternative:\n\n"
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

String secondAlternativeTuto = "Second Alternative:\n\n"
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

String thirdAlternativeTuto = 'Third alternative\n\n'
    'Your UI part\n'
    '//All widget that has a tag will be rebuilt.\n'
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
    '  // are given `tag` will rebuild to reflect the new counter value.\n'
    '  //\n'
    '  // you get a similar behavior like in scoped_model or provider packages\n'
    '}\n';
