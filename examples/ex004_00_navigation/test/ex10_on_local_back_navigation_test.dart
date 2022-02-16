import 'package:ex_006_5_navigation/ex10_on_local_back_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'When form is not changed'
    'Then we can exit the sign in page',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.text('You can exit safely'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    },
  );

  testWidgets(
    'When form is changed'
    'Then we can not exit the sign in page '
    'And a dialog is displayed'
    'When we submit form we can exit the sign in page',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.text('You can exit safely'), findsOneWidget);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text(
            'Form is changed and not submitted yet. Do you want to exit?'),
        findsOneWidget,
      );
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.text('You can exit safely'), findsNothing);
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('You can exit safely'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    },
  );

  testWidgets(
    'When form is changed'
    'Then we can not exit the sign in page '
    'And a dialog is displayed'
    'When can for the page to exit',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsOneWidget);
      expect(find.text('You can exit safely'), findsOneWidget);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text(
            'Form is changed and not submitted yet. Do you want to exit?'),
        findsOneWidget,
      );
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    },
  );
}
