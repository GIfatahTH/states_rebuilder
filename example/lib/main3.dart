import 'dart:math';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'dart:async';

enum MainState { ListView }

class MainBloc extends StatesRebuilder {
  List<int> items = [];
  bool listIsLoading = true;

  Future<void> fetchList() async {
    items = await Future.delayed(
      Duration(seconds: 2),
      () => List<int>.generate(10, (_) => Random().nextInt(9) + 1),
    );

    listIsLoading = false;
    rebuildStates([MainState.ListView]);
  }

  void decrement(int index, state) {
    items[index]--;

    if (items[index] > 0) {
      rebuildStates([state]);
    } else {
      items.removeAt(index);
      rebuildStates([MainState.ListView]);
    }
  }
}

MainBloc mainBloc;

// // THIRD CASE
// class MainBloc extends BloCSetting {
//   List<int> items = [];
//   bool listIsLoading = true;

//   Future<void> fetchList() async {
//     items = await Future.delayed(
//       Duration(seconds: 2),
//       () => List<int>.generate(10, (_) => Random().nextInt(9) + 1),
//     );

//     listIsLoading = false;
//     rebuildWidgets(ids: ["ListView"]);
//   }

//   void decrement(int index, state) {
//     items[index]--;
//     rebuildWidgets(states: [state]);
//   }
// }

// SECOND Case
// class MainBloc extends BloCSetting {
//   List<int> items = [];
//   bool listIsLoading = true;

//   Future<void> fetchList() async {
//     items = await Future.delayed(
//       Duration(seconds: 2),
//       () => List<int>.generate(10, (_) => Random().nextInt(9) + 1),
//     );

//     listIsLoading = false;
//     rebuildWidgets(ids: ["ListView"]);
//   }

//   void decrement(int index) {
//     items[index]--;
//   }
// }

// // FIRST CASE
// class MainBloc extends BloCSetting {
//   List<int> items = [];
//   bool listIsLoading = true;

//   Future<void> fetchList(state) async {
//     items = await Future.delayed(
//       Duration(seconds: 2),
//       () => List<int>.generate(10, (_) => Random().nextInt(9) + 1),
//     );

//     listIsLoading = false;
//     rebuildWidgets(states: [state]);
//   }

//   void decrement(int index) {
//     items[index]--;
//   }
// }

// BEFORE;
// class MainBloc extends BloCSetting {
//   List<int> items = [];
//   bool listIsLoading = true;

//   Future<void> fetchList() async {
//     items = await Future.delayed(
//       Duration(seconds: 1),
//       () => List<int>.generate(10, (_) => Random().nextInt(9) + 1),
//     );

//     listIsLoading = false;
//   }

//   void deccrement(int index) {
//     items[index]--;
//   }
// }

void main() => runApp(
      StateBuilder(
        initState: (_) => mainBloc = MainBloc(),
        dispose: (_) => mainBloc = null,
        builder: (_) => MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SetState management",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("State Management")),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
        stateID: MainState.ListView,
        blocs: [mainBloc],
        initState: (_) => mainBloc.fetchList(),
        builder: (_) => mainBloc.listIsLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: mainBloc.items.length,
                itemBuilder: (_, index) => StateBuilder(
                      builder: (state) => ListTile(
                            title: Text(
                                "This is item number  ${Random().nextInt(100)}"),
                            trailing: Text(" ${mainBloc.items[index]}"),
                            onTap: () => mainBloc.decrement(index, state),
                          ),
                    ),
              ));
  }
}

// SECOND CASE
// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StateBuilder(
//         stateID: "ListView",
//         blocs: [mainBloc],
//         initState: (_) => mainBloc.fetchList(),
//         builder: (_) => mainBloc.listIsLoading
//             ? Center(child: CircularProgressIndicator())
//             : ListView.builder(
//                 itemCount: mainBloc.items.length,
//                 itemBuilder: (_, index) => ListTile(
//                       title: Text( "This is item number  ${Random().nextInt(100)}"),
//                       trailing: Text(" ${mainBloc.items[index]}"),
//                       onTap: () => mainBloc.decrement(index),
//                     ),
//               ));
//   }
// }

//  // FIRST CASE
// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StateBuilder(
//         initState: (state) => mainBloc.fetchList(state),
//         builder: (_) => mainBloc.listIsLoading
//             ? Center(child: CircularProgressIndicator())
//             : ListView.builder(
//                 itemCount: mainBloc.items.length,
//                 itemBuilder: (_, index) => ListTile(
//                       title: Text( "This is item number  ${Random().nextInt(100)}"),
//                       trailing: Text(" ${mainBloc.items[index]}"),
//                       onTap: () => mainBloc.decrement(index),
//                     ),
//               ));
//   }
// }

// // BEFORE;
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return mainBloc.listIsLoading
//         ? Center(child: CircularProgressIndicator())
//         : ListView.builder(
//             itemCount: mainBloc.items.length,
//             itemBuilder: (_, index) => ListTile(
//                   title: Text( "This is item number  ${Random().nextInt(100)}"),
//                   trailing: Text(" ${mainBloc.items[index]}"),
//                   onTap: () => mainBloc.decrement(index),
//                 ),
//           );
//   }
// }
