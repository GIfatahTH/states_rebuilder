import 'package:ex002_00_async_global_and_local_state/ex_010_00_local_state_in_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Test when app starts the local state are async initialized',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsNWidgets(3));
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsNWidgets(1));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsNWidgets(0));
      expect(find.text('0'), findsNWidgets(3));
      //
      await tester.tap(find.byIcon(Icons.add).last);
      await tester.pump();
      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('1'), findsNWidgets(1));
    },
  );
}
