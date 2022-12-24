import 'package:ex_006_5_navigation/ex05_to_deeply_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  setUp(() {
    //This is add to force transition to be device independent so golden test
    //works independent of device default animation
    RM.navigate.transitionsBuilder =
        RM.transitions.bottomToUp(duration: const Duration(milliseconds: 300));
  });
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_1.png'));
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
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_2.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11/page111');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_3.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_4.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_5.png'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(navigator.routeData.location, '/');
      //
      await tester.tap(find.text('Navigate using "toDeeply"'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111/Page1111'), findsNWidgets(2));
      expect(navigator.routeData.location, '/page1/page11/page111/page1111');
      //
      navigator.toAndRemoveUntil('/');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_6.png'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_7.png'));
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
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_8.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111/Page1111'), findsNWidgets(2));
      //
      navigator.back();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_9.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNWidgets(2));
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    },
  );

  testWidgets(
    'Test toReplacement',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      //
      navigator.toReplacement('/page1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_10.png'));
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
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_11.png'));
      await tester.pumpAndSettle();
      expect(find.text('Page1/Page11/Page111'), findsNWidgets(2));
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsNWidgets(2));
      await expectLater(
          find.byType(MyApp), matchesGoldenFile('./golden_files/ex05_12.png'));
    },
  );
}
