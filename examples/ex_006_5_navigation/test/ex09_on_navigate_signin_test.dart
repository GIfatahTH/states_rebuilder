import 'package:ex_006_5_navigation/ex09_on_navigate_signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'test navigation logic',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(SignInScreen), findsOneWidget);
      //
      final userNameField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Username',
      );
      final passwordField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Password',
      );
      await tester.enterText(userNameField, 'user1');
      await tester.enterText(passwordField, '123');
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      //
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(UserInfo), findsOneWidget);
      expect(find.text('UserName: user1'), findsOneWidget);
      //
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
    },
  );

  testWidgets(
    'test deep link of unsigned user',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(navigator.routeData.uri.toString(), '/sign-in');
      //
      navigator.deepLinkTest('/user-info?q=1');
      expect(navigator.routeData.uri.toString(), '/sign-in');
      expect(
          navigator.routeData.redirectedFrom?.uri.toString(), '/user-info?q=1');
      await tester.pump();
      expect(find.byType(SignInScreen), findsOneWidget);
      //
      final userNameField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Username',
      );
      final passwordField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Password',
      );
      await tester.enterText(userNameField, 'user2');
      await tester.enterText(passwordField, '123');
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.byType(UserInfo), findsOneWidget);
      expect(find.text('UserName: user2'), findsOneWidget);
    },
  );
}
