import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('Counters increments', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(CounterTabApp());

    // Verify that our both counters start at 0.
    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('1'), findsNothing);

    // Tap  the button  with Key("firstAlternative") and trigger a frame.
    // this is the first alternative
    await tester.tap(find.byKey(Key("firstAlternative")));
    await tester.pump();

    // Verify that  counter1 and total have incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNWidgets(2));
  });
}
