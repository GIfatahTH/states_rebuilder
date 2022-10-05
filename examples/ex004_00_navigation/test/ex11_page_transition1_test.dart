import 'package:ex_006_5_navigation/ex11_page_transition1.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  //This is add to force transition to be device independent so golden test
  //works independent of device default animation
  RM.navigate.transitionsBuilder =
      RM.transitions.bottomToUp(duration: const Duration(milliseconds: 300));
  testWidgets('Test navigation logic', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('to page1 (rotation + scaling)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex10_2.png'));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex10_3.png'));
    await tester.pumpAndSettle();
    navigator.back();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex10_4.png'));
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to page3 (slide left to right)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex10_5.png'));
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex10_6.png'));
    await tester.pumpAndSettle();
    navigator.back();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex10_7.png'));
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to page4 (no animation)'));
    await tester.pump();
    await tester.pump();
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex10_8.png'));
    navigator.back();
    await tester.pump();
    await tester.pump();
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex10_9.png'));
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to page2 (rotation + scaling)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex10_10.png'));
    await tester.pumpAndSettle();
    navigator.back();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to page5 (Nested Route: up to bottom)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex10_11.png'));
  });
}
