import 'package:ex_006_5_navigation/ex02_imperative_navigation1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Test navigation logic before removing "page1"',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('Page11'), findsOneWidget);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNWidgets(2));
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Home page'), findsNWidgets(2));
    },
  );
  testWidgets(
    'Test navigation logic after removing "page1"',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('Page11'), findsOneWidget);
      //
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Page11'), findsOneWidget);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNothing);
      expect(find.text('Home page'), findsNWidgets(2));
    },
  );
}
