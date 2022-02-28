import 'package:ex010_00_form_fields/ex_001_00_text_fields_validation_with_core_state_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Finder emailTextField;
  late Finder passwordTextField;
  late Finder activeLoginButton;
  setUp(
    () {
      emailTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == "Email Address",
      );

      passwordTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == "Password",
      );

      //active login button is that with a non null onPressed parameter
      activeLoginButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.onPressed != null,
      );
    },
  );

  testWidgets('email validation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('A valid email must contains @'), findsNothing);
    expect(find.text('Email : A valid email must contains @'), findsNothing);

    //Non valid Email
    await tester.enterText(emailTextField, 'mail');
    await tester.pump();
    expect(find.text('A valid email must contains @'), findsOneWidget);
    expect(find.text('Email : A valid email must contains @'), findsOneWidget);

    //valid Email
    await tester.enterText(emailTextField, 'mail@');
    await tester.pump();
    expect(find.text('A valid email must contains @'), findsNothing);
    expect(find.text('Email : mail@'), findsOneWidget);
  });

  testWidgets('password validation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('A valid password must contains as least 6 characters'),
        findsNothing);
    expect(
        find.text(
            'password : A valid password must contains as least 6 characters'),
        findsNothing);

    //Non valid password
    await tester.enterText(passwordTextField, 'pas');
    await tester.pump();
    expect(find.text('A valid password must contains as least 6 characters'),
        findsOneWidget);
    expect(
        find.text(
            'password : A valid password must contains as least 6 characters'),
        findsOneWidget);

    //valid password
    await tester.enterText(passwordTextField, 'password');
    await tester.pump();
    expect(find.text('A valid password must contains as least 6 characters'),
        findsNothing);
    expect(find.text('password : password'), findsOneWidget);
  });

  testWidgets('active login button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    //before tapping login button is inactive
    expect(activeLoginButton, findsNothing);

    //Non valid email and valid password
    await tester.enterText(emailTextField, 'mail');
    await tester.enterText(passwordTextField, 'password');
    await tester.pump();
    //login button is inactive
    expect(activeLoginButton, findsNothing);

    //valid email and non valid password
    await tester.enterText(emailTextField, 'mail@');
    await tester.enterText(passwordTextField, 'pa');
    await tester.pump();
    //login button is inactive
    expect(activeLoginButton, findsNothing);

    //valid email and password
    await tester.enterText(emailTextField, 'mail@');
    await tester.enterText(passwordTextField, 'password');
    await tester.pump();
    //login button is active
    expect(activeLoginButton, findsOneWidget);
  });
}
