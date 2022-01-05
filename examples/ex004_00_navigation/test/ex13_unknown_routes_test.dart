import 'package:ex_006_5_navigation/ex13_unknown_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test navigation logic', (tester) async {
    await tester.pumpWidget(const MyApp());
    //
    await tester.tap(find.text('to unknownPage'));
    await tester.pumpAndSettle();
    expect(find.text('/unknownPage not found'), findsOneWidget);
    navigator.back();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to /page1/1'));
    await tester.pumpAndSettle();
    expect(find.text('This is Item 2'), findsOneWidget);
    navigator.back();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to /page1/2 (out of range)'));
    await tester.pumpAndSettle();
    expect(find.text('/page1/2 not found'), findsOneWidget);
    navigator.back();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to /page2/1'));
    await tester.pumpAndSettle();
    expect(find.text('This is Item 2'), findsOneWidget);
    navigator.back();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to /page1/string (Non number)'));
    await tester.pumpAndSettle();
    expect(find.text('/page2/string not found'), findsOneWidget);
    navigator.back();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'test deep links',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      navigator.deepLinkTest('/unknownPage');
      await tester.pumpAndSettle();
      expect(find.text('/unknownPage not found'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      //
      navigator.deepLinkTest('/page1/1');
      await tester.pumpAndSettle();
      expect(find.text('This is Item 2'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      //
      navigator.deepLinkTest('/page1/2');
      await tester.pumpAndSettle();
      expect(find.text('/page1/2 not found'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      //
      navigator.deepLinkTest('/page2/1');
      await tester.pumpAndSettle();
      expect(find.text('This is Item 2'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      //
      navigator.deepLinkTest('/page2/string');
      await tester.pumpAndSettle();
      expect(find.text('/page2/string not found'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
    },
  );
}
