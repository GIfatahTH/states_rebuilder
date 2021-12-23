import 'package:ex_006_5_navigation/ex08_on_navigate_redirection_from.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('test navigation logic', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(HomePage), findsOneWidget);
    //
    await tester.tap(find.text('to /page1'));
    await tester.pumpAndSettle();
    expect(find.text('Redirected From: /page1'), findsOneWidget);
    expect(find.text('Path parameters : {}'), findsOneWidget);
    expect(find.text('Query parameters : {}'), findsOneWidget);
    expect(find.text('Full uri: /page1'), findsOneWidget);
    Navigator.of(RM.context!).pop();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    //
    await tester.tap(find.text('to /page1/5'));
    await tester.pumpAndSettle();
    expect(find.text('Redirected From: /page1/5'), findsOneWidget);
    expect(find.text('Path parameters : {id: 5}'), findsOneWidget);
    expect(find.text('Query parameters : {}'), findsOneWidget);
    expect(find.text('Full uri: /page1/5'), findsOneWidget);
    Navigator.of(RM.context!).pop();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to /page2'));
    await tester.pumpAndSettle();
    expect(find.text('Redirected From: /page2'), findsOneWidget);
    expect(find.text('Path parameters : {}'), findsOneWidget);
    expect(find.text('Query parameters : {}'), findsOneWidget);
    expect(find.text('Full uri: /page2'), findsOneWidget);
    Navigator.of(RM.context!).pop();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to /page3'));
    await tester.pumpAndSettle();
    expect(find.text('Redirected From: /page3'), findsOneWidget);
    expect(find.text('Path parameters : {}'), findsOneWidget);
    expect(find.text('Query parameters : {}'), findsOneWidget);
    expect(find.text('Full uri: /page3'), findsOneWidget);
    Navigator.of(RM.context!).pop();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to /page3/5'));
    await tester.pumpAndSettle();
    expect(find.byType(PageWidget), findsOneWidget);
    Navigator.of(RM.context!).pop();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to /page3/10'));
    await tester.pumpAndSettle();
    expect(find.text('Redirected From: /page3/10'), findsOneWidget);
    expect(find.text('Path parameters : {id: 10}'), findsOneWidget);
    expect(find.text('Query parameters : {}'), findsOneWidget);
    expect(find.text('Full uri: /page3/10'), findsOneWidget);
    Navigator.of(RM.context!).pop();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to /page4?q=ok'));
    await tester.pumpAndSettle();
    expect(find.byType(PageWidget), findsOneWidget);
    Navigator.of(RM.context!).pop();
    await tester.pumpAndSettle();
    //
    await tester.tap(find.text('to /page4?q=NaN'));
    await tester.pumpAndSettle();
    expect(find.text('Redirected From: /page4'), findsOneWidget);
    expect(find.text('Path parameters : {}'), findsOneWidget);
    expect(find.text('Query parameters : {q: NaN}'), findsOneWidget);
    expect(find.text('Full uri: /page4?q=NaN'), findsOneWidget);
    Navigator.of(RM.context!).pop();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Test deep link',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      navigator.deepLinkTest('/page3?q=I-do-not-know');
      await tester.pumpAndSettle();
      expect(find.text('Redirected From: /page3'), findsOneWidget);
      expect(find.text('Path parameters : {}'), findsOneWidget);
      expect(
          find.text('Query parameters : {q: I-do-not-know}'), findsOneWidget);
      expect(find.text('Full uri: /page3?q=I-do-not-know'), findsOneWidget);
    },
  );
}
