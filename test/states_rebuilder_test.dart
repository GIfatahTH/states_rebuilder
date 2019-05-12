// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:states_rebuilder/states_rebuilder.dart';

// void main() {
//   testWidgets(
//       'Widgets update when the increment() is called. First alternative',
//       (WidgetTester tester) async {
//     final initialValue = 0;
//     final testBloc = TestBloc(initialValue);
//     final widget = TestWidget1stAlt(testBloc);

//     // Starts out at the initial value
//     await tester.pumpWidget(widget);

//     // Increment the model, which should notify the children to rebuild
//     testBloc.increment();

//     // Rebuild the widget
//     await tester.pumpWidget(widget);

//     expect(find.text('1'), findsOneWidget);
//   });

//   testWidgets(
//       'Widgets update when the increment(State state) is called. second alternative',
//       (WidgetTester tester) async {
//     final initialValue = 0;
//     final testBloc = TestBloc(initialValue);
//     final widget = TestWidget2sdAlt(testBloc);

//     // Starts out at the initial value
//     await tester.pumpWidget(widget);

//     // Increment the model, which should notify the children to rebuild
//     // testBloc.increment();
//     await tester.tap(find.byType(RaisedButton));

//     // Rebuild the widget
//     await tester.pumpWidget(widget);

//     expect(find.text('1'), findsOneWidget);
//   });
// }

// class TestBloc extends StatesRebuilder {
//   int _counter;

//   TestBloc([int initialValue = 0]) {
//     _counter = initialValue;
//   }

//   int get counter => _counter;

//   void increment([int value]) {
//     _counter++;
//     rebuildStates(ids: ["textCounter"]);
//   }

//   void increment2(int value, State state) {
//     _counter++;
//     rebuildStates(states: [state]);
//   }
// }

// class TestWidget1stAlt extends StatelessWidget {
//   final TestBloc testBloc;

//   TestWidget1stAlt(this.testBloc);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Container(
//         child: StateBuilder(
//           stateID: "textCounter",
//           blocs: [testBloc],
//           builder: (_) {
//             return Text(
//               testBloc.counter.toString(),
//               textDirection: TextDirection.ltr,
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class TestWidget2sdAlt extends StatelessWidget {
//   final TestBloc testBloc;
//   TestWidget2sdAlt(
//     this.testBloc,
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Directionality(
//         textDirection: TextDirection.ltr,
//         child: Container(
//           child: StateBuilder(
//             builder: (State state) {
//               return Column(children: [
//                 Text(
//                   testBloc.counter.toString(),
//                 ),
//                 RaisedButton(
//                   child: Text("Increment"),
//                   onPressed: () => testBloc.increment2(0, state),
//                 ),
//               ]);
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
