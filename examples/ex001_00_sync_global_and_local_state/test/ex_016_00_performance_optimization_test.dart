import 'package:ex001_00_sync_global_and_local_state/ex_016_00_performance_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Test only the tapped item is rebuilt',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(rebuiltItems.length > 10, true);
      rebuiltItems.clear();
      await tester.tap(find.text('ADD').at(5));
      await tester.pump();
      expect(rebuiltItems, [5]);
      expect(find.byIcon(Icons.check), findsOneWidget);
      //
      rebuiltItems.clear();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      expect(rebuiltItems, [5]);
      //
      rebuiltItems.clear();
      await tester.tap(find.text('ADD').at(6));
      await tester.pump();
      expect(rebuiltItems, [6]);
      expect(find.byIcon(Icons.check), findsOneWidget);
      //
      rebuiltItems.clear();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      expect(rebuiltItems, [6]);
    },
  );
}
