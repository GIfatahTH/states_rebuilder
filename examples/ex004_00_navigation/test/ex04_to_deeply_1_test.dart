import 'package:ex_006_5_navigation/ex04_to_deeply_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/scr/state_management/rm.dart';

void main() {
  //This is add to force transition to be device independent so golden test
  //works independent of device default animation
  RM.navigate.transitionsBuilder = RM.transitions.bottomToUp();
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_1.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11/page111');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_2.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_3.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_4.png'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(navigator.routeData.location, '/');
      //
      await tester.tap(find.text('Navigate using "toDeeply"'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111/Page1111'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11/page111/page1111');
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_5.png'));
      //
      await tester.tap(find.byIcon(Icons.home));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_6.png'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(navigator.routeData.location, '/');
      //
    },
  );

  testWidgets(
    'test toAndRemoveUntil',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      //
      navigator.toDeeply('/page1/page11/page111');
      await tester.pumpAndSettle();
      navigator.toAndRemoveUntil('/page1/page11/page111/page1111',
          untilRouteName: '/page1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_7.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111/Page1111'), findsNWidgets(2));
      //
      navigator.back();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_8.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNWidgets(2));
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      //
    },
  );
  testWidgets(
    'Test toReplacement'
    'THEN',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      //
      navigator.toReplacement('/page1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_9.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNWidgets(2));
      //
      navigator.to('/page1/page11');
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11'), findsNWidgets(2));
      navigator.toReplacement('/page1/page11/page111');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_10.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111'), findsNWidgets(2));
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNWidgets(2));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex04_11.png'));
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
      expect(find.byType(HomePage), findsOneWidget);
      expect(navigator.routeData.location, '/');
    },
  );
}
