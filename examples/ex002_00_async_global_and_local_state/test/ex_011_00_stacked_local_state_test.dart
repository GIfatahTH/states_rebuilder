import 'package:ex002_00_async_global_and_local_state/ex_011_00_stacked_local_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'WHEN'
    'THEN',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      //
      await tester.tap(find.text('Go to next counter'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('The global counter is 2'), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      expect(find.text('The global counter is 3'), findsOneWidget);
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
    },
  );
}
