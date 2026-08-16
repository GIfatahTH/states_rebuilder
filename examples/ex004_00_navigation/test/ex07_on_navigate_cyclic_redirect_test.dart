import 'package:ex_006_5_navigation/ex07_on_navigate_cyclic_redirect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'test navigation logic',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      //
      await tester.tap(find.text('to page1'));
      await tester.pumpAndSettle();
      expect(
        find.text('Infinite redirect loop: (/page1)'),
        findsOneWidget,
      );
      navigator.back();
      await tester.pumpAndSettle();
      //
      await tester.tap(find.text('to page2'));
      await tester.pumpAndSettle();
      expect(
        find.text('Infinite redirect loop: (/page2, /page3)'),
        findsOneWidget,
      );
      navigator.back();
      await tester.pumpAndSettle();
      //
      await tester.tap(find.text('to page3'));
      await tester.pumpAndSettle();
      expect(
        find.text('Infinite redirect loop: (/page3, /page2)'),
        findsOneWidget,
      );
      navigator.back();
      await tester.pumpAndSettle();
      //
      await tester.tap(find.text('to page4'));
      await tester.pumpAndSettle();
      expect(
        find.text('Infinite redirect loop: (/page4, /page5)'),
        findsOneWidget,
      );
      navigator.back();
      await tester.pumpAndSettle();
      //
      await tester.tap(find.text('to page5'));
      await tester.pumpAndSettle();
      expect(
        find.text('Infinite redirect loop: (/page5, /page4)'),
        findsOneWidget,
      );
      navigator.back();
      await tester.pumpAndSettle();
    },
  );
}
