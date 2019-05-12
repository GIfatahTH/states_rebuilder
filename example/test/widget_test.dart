// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';

// import '../lib/main.dart';

// void main() {
//   testWidgets('Counters increments', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(MyApp());

//     // Verify that our both counters start at 0.
//     expect(find.text('0'), findsNWidgets(2));
//     expect(find.text('1'), findsNothing);

//     // Tap  the button  with Key("firstAlternative") and trigger a frame.
//     // this is the first alternative
//     await tester.tap(find.byKey(Key("firstAlternative")));
//     await tester.pump();

//     // Verify that only counter1 has incremented.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsOneWidget);

//     // Tap the button  with Key("secondAlternative") and trigger a frame.
//     // this is the second alternative
//     await tester.tap(find.byKey(Key("secondAlternative")));
//     await tester.pump();

//     // Verify that both counters have incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsNWidgets(2));
//   });
// }
