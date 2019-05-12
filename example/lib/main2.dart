// import 'package:flutter/material.dart';
// import 'package:states_rebuilder/states_rebuilder.dart';

// enum MainState { TextField, Text }

// class MainBloc extends StatesRebuilder {
//   String text = "";
//   String errorMsg;

//   onChanged(String s) {
//     text = s;
//     errorMsg = s + ' is not allowed';

//     rebuildStates(ids: [MainState.TextField, MainState.Text]);
//   }
// }

// MainBloc mainBloc;

// // class MainBloc extends BloCSetting {
// //   String text = "";
// //   String errorMsg;

// //   onChanged(String s) {
// //     text = s;
// //     errorMsg = s + ' is not allowed';

// //     rebuildWidgets(ids: ["Text" , "TextField"]);
// //   }
// // }

// void main() => runApp(
//       StateBuilder(
//         initState: (_) => mainBloc = MainBloc(),
//         dispose: (_) => mainBloc = null,
//         builder: (_) => MyApp(),
//       ),
//     );

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "SetState management",
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(title: Text("State Management")),
//         body: MyHomePage(),
//       ),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   // @override
//   // Widget build(BuildContext context) {
//   //   return StateBuilder(
//   //     stateID: MainState.Column,
//   //     blocs: [mainBloc],
//   //     builder: (_) => Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: <Widget>[
//   //             TextField(
//   //               onChanged: mainBloc.onChanged,
//   //               decoration: InputDecoration(
//   //                 errorText: mainBloc.errorMsg,
//   //               ),
//   //             ),
//   //             Text(mainBloc.text),
//   //           ],
//   //         ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         StateBuilder(
//           stateID: MainState.TextField,
//           blocs: [mainBloc],
//           builder: (_) => TextField(
//                 onChanged: mainBloc.onChanged,
//                 decoration: InputDecoration(
//                   errorText: mainBloc.errorMsg,
//                 ),
//               ),
//         ),
//         StateBuilder(
//           stateID: MainState.Text,
//           blocs: [mainBloc],
//           builder: (_) => Text(mainBloc.text),
//         ),
//       ],
//     );
//   }
// }
