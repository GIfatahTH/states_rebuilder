import 'package:ex_006_5_navigation/ex10_on_local_back_navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

BackButtonDispatcher dispatcher = RootBackButtonDispatcher();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routeInformationParser: navigator.routeInformationParser,
      routerDelegate: navigator.routerDelegate,
      backButtonDispatcher: dispatcher,
    );
  }
}

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
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
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
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
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
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
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
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
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

  testWidgets(
    'WHEN device back button is pressed when app is in the root widget'
    'THEN an AlertDialog is displayed'
    'AND WHEN the back button is pressed again'
    'THEN an AlertDialog is popped',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pump();
      await tester.pump();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('You are about to close the app. Do you want to continue?'),
        findsOneWidget,
      );
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pump();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'WHEN device back button is pressed when app is in the root widget'
    'THEN an AlertDialog is displayed'
    'AND WHEN "No" is chosen'
    'THEN an AlertDialog is popped',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pump();
      await tester.pump();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('You are about to close the app. Do you want to continue?'),
        findsOneWidget,
      );
      await tester.tap(find.text('No'));
      await tester.pump();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'WHEN device back button is pressed when app is in the root widget'
    'THEN an AlertDialog is displayed'
    'AND WHEN "Yes" is chosen'
    'THEN an AlertDialog is popped',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pump();
      await tester.pump();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('You are about to close the app. Do you want to continue?'),
        findsOneWidget,
      );
      await tester.tap(find.text('Yes'));
      await tester.pump();
      // TODO I do not now how to test SystemNavigator.pop(),
      // await tester.pump(const Duration(seconds: 1));
      // expect(find.byType(HomePage), findsOneWidget);
      // expect(find.byType(AlertDialog), findsNothing);
    },
  );
}
