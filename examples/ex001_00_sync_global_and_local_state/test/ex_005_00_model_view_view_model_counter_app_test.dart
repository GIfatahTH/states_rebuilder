import 'package:ex001_00_sync_global_and_local_state/ex_005_00_model_view_view_model_counter_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Unit test of MyHomePageViewModel class',
    (tester) async {
      final myHomePageViewModel = MyHomePageViewModel();
      expect(myHomePageViewModel.counter, 0);
      myHomePageViewModel.increment();
      expect(myHomePageViewModel.counter, 1);
    },
  );
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
