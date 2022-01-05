import 'package:ex001_00_sync_global_and_local_state/ex_008_00_local_state_the_right_way.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Counter increments smoke test',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('0'), findsNWidgets(3));
      //
      // Increment first counter
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('0'), findsNWidgets(2));
      // Increment second counter
      await tester.tap(find.byIcon(Icons.add).at(1));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add).at(1));
      await tester.pump();
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('2'), findsNWidgets(1));
      expect(find.text('0'), findsNWidgets(1));
      // Increment second counter
      await tester.tap(find.byIcon(Icons.add).at(2));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add).at(2));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add).at(2));
      await tester.pump();
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('2'), findsNWidgets(1));
      expect(find.text('3'), findsNWidgets(1));
    },
  );
}
