import 'package:ex_006_5_navigation/ex04_to_deeply_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Test Navigation logic',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      expect(navigator.routeData.location, '/');
      //
      await tester.tap(find.text('Navigate using "to"'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111/Page1111'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11/page111/page1111');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(navigator.routeData.location, '/');
      //
      await tester.tap(find.text('Navigate using "toDeeply"'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111/Page1111'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11/page111/page1111');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11/page111');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(navigator.routeData.location, '/');
      //
      await tester.tap(find.text('Navigate using "toDeeply"'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111/Page1111'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11/page111/page1111');
      //
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(navigator.routeData.location, '/');
    },
  );

  testWidgets(
    'Test deep link',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      navigator.deepLinkTest('/page1/page11/page111/page1111');
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111/Page1111'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11/page111/page1111');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11/page111');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(navigator.routeData.location, '/');
    },
  );
}
