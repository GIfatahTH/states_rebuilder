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

  initState(ticker) {
    _tabController = TabController(vsync: ticker, length: choices.length);
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

    final s = DateTime.now().microsecondsSinceEpoch;
    rebuildStates(["CounterState.firstAlternative", CounterState.total]);
    print(DateTime.now().microsecondsSinceEpoch - s);
  }

  void increment2(String tagID) {
    // Increment the counter
    _counter2++;

    // Second alternative.
    // Widgets from which the increment2 method is called will rebuild.
    // You can mix states and stateIDs
    final s = DateTime.now().microsecondsSinceEpoch;

    rebuildStates([tagID, CounterState.total]);
    print(DateTime.now().microsecondsSinceEpoch - s);
  }

  void increment3() {
    // increment the counter
    _counter1++;

    // The third alternative

    // `rebuildStates()` with no parameter: All widgets that are wrapped with `StateBuilder` and
    // are given `stateID` will rebuild to reflect the new counter value.
    //
    // you get a similar behavior like in scoped_model or provider packages
    final s = DateTime.now().microsecondsSinceEpoch;

    rebuildStates();
    print(DateTime.now().microsecondsSinceEpoch - s);

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
    return StateWithMixinBuilder(
      mixinWith: MixinWith.singleTickerProviderStateMixin,
      initState: (_, ticker) => counterBloc.initState(ticker),
      dispose: (_, __) => counterBloc.dispose(),
      builder: (_, __) => Scaffold(
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
                  tag: CounterState.total,
                  blocs: [counterBloc],
                  builder: (_, __) => CircleAvatar(
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
                  tag: "CounterState.firstAlternative",
                  blocs: [counterBloc],
                  builder: (context, __) => Text(
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
              blocs: [counterBloc],
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

// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:states_rebuilder/states_rebuilder.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: "Flutter Demo",
//         theme: ThemeData(primarySwatch: Colors.blue),
//         home: RootPage());
//   }
// }

// class RootPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Root Page"),
//         ),
//         body: Center(
//           child: Column(
//             children: <Widget>[
//               StateBuilder(
//                 blocs: [counterBloc],
//                 builder: (_, __) {
//                   return Text("Count is ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                   child: Text("Increase value"),
//                   onPressed: () => counterBloc.updateValue()),
//               RaisedButton(
//                   child: Text("Go to next page"),
//                   onPressed: () => Navigator.of(context).push(MaterialPageRoute(
//                       builder: (BuildContext context) => HomePage()))),
//             ],
//           ),
//         ),
//         resizeToAvoidBottomInset: false);
//   }
// }

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       bloc: CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(title: Text("Detail Page")),
//         body: new MyBody(),
//       ),
//     );
//   }
// }

// class MyBody extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // final counterBloc = BlocProvider.of<CounterBloc>(context);
//     return Center(
//       child: ListView(
//         children: [
//           StateBuilder(
//               blocs: [counterBloc],
//               builder: (_, hashtag) {
//                 return Row(children: <Widget>[
//                   Text("Count is ${counterBloc.value}"),
//                   RaisedButton(
//                     child: Text("Increase value"),
//                     onPressed: () => counterBloc.updateValue1(hashtag),
//                   )
//                 ]);
//               }),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           StateBuilder(
//               builder: (_, hashtag) {
//                 return Row(
//                   children: <Widget>[
//                     Text("Count is ${counterBloc.value}"),
//                     RaisedButton(
//                       child: Text("Increase value 1 "),
//                       onPressed: () => counterBloc.updateValue1(hashtag),
//                     )
//                   ],
//                 );
//               },
//               tag: "value2"),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                 builder: (_, __) {
//                   return Text("Count isjjjj ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                   blocs: [counterBloc],
//                   builder: (_, __) {
//                     return Text("Count is ${counterBloc.value}");
//                   },
//                   tag: "value2"),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                 blocs: [counterBloc],
//                 builder: (_, __) {
//                   return Text("Count is ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                 blocs: [counterBloc],
//                 builder: (_, __) {
//                   return Text("Count is ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                 blocs: [counterBloc],
//                 builder: (_, __) {
//                   return Text("Count is ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                 blocs: [counterBloc],
//                 builder: (_, __) {
//                   return Text("Count is ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                 blocs: [counterBloc],
//                 builder: (_, __) {
//                   return Text("Count is ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                 blocs: [counterBloc],
//                 builder: (_, __) {
//                   return Text("Count is ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                 blocs: [counterBloc],
//                 builder: (_, __) {
//                   return Text("Count is ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                 blocs: [counterBloc],
//                 builder: (_, __) {
//                   return Text("Count is ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               StateBuilder(
//                 blocs: [counterBloc],
//                 builder: (_, __) {
//                   return Text("Count is ${counterBloc.value}");
//                 },
//               ),
//               RaisedButton(
//                 child: Text("Increase value"),
//                 onPressed: () => counterBloc.updateValue(),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// final counterBloc = CounterBloc();

// class CounterBloc extends StatesRebuilder {
//   int value = 0;

//   void updateValue() {
//     value += 1;
//     final s = DateTime.now().microsecondsSinceEpoch;
//     rebuildStates();
//     print(DateTime.now().microsecondsSinceEpoch - s);
//   }

//   void updateValue1(String hastag) {
//     value += 1;
//     final s = DateTime.now().microsecondsSinceEpoch;
//     rebuildStates([hastag]);
//     print(DateTime.now().microsecondsSinceEpoch - s);
//   }
// }
