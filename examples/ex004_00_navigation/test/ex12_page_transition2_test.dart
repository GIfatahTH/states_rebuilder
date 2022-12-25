import 'package:ex_006_5_navigation/ex12_page_transition2.dart';
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
  testWidgets('Test navigation logic', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byIcon(Icons.keyboard_arrow_right));
    await tester.pump();
    await tester.pump();
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex11_1.png'));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex11_2.png'));
    await tester.pump(const Duration(milliseconds: 500));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex11_3.png'));
    navigator.back();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await expectLater(
        find.byType(MyApp), matchesGoldenFile('./golden_files/ex11_4.png'));
    await tester.pumpAndSettle();
  });
}
