import 'package:ex001_00_sync_global_and_local_state/ex_007_00_local_state_the_wrong_way.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Counter increments smoke test',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('0'), findsNWidgets(3));
      //
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      // The three counter are incremented
      expect(find.text('1'), findsNWidgets(3));
    },
  );
}
