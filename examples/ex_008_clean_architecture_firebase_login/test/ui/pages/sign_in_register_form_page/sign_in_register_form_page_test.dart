import 'package:clean_architecture_firebase_login/data_source/fake_user_repository.dart';
import 'package:clean_architecture_firebase_login/injected.dart';
import 'package:clean_architecture_firebase_login/main.dart';
import 'package:clean_architecture_firebase_login/service/exceptions/sign_in_out_exception.dart';
import 'package:clean_architecture_firebase_login/ui/pages/sign_in_register_form_page/sign_in_register_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  currentEnv = Env.dev;
  setUp(() {
    user.injectAuthMock(() => FakeUserRepository());
    canSignInWithApple.injectMock(() => true);
  });

  Finder emailTextFiled = find.byWidgetPredicate((widget) {
    return widget is TextField && widget.decoration?.labelText == 'Email';
  });
  Finder passwordTextFiled = find.byWidgetPredicate((widget) {
    return widget is TextField && widget.decoration?.labelText == 'Password';
  });
  Finder confirmPasswordTextFiled = find.byWidgetPredicate((widget) {
    return widget is TextField &&
        widget.decoration?.labelText == 'Confirm Password';
  });
  Finder activeSubmitButton = find.byWidgetPredicate((widget) {
    return widget is ElevatedButton && widget.enabled;
  });
  Finder uncheckedCheckBox = find.byWidgetPredicate((widget) {
    return widget is Checkbox && !widget.value!;
  });

  Finder checkedCheckBox = find.byWidgetPredicate((widget) {
    return widget is Checkbox && widget.value!;
  });

  testWidgets('Email validation', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.text('Sign in With Email and password'));
    await tester.pumpAndSettle();

    //expect that the checkBox is initially unchecked
    expect(uncheckedCheckBox, findsOneWidget);

    //expect that the submit button is shows 'Sign in' text
    expect(find.text('Sign in'), findsOneWidget);

    //Invalid email
    await tester.enterText(emailTextFiled, 'myemail.com');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsNothing);
    //change focus
    await tester.enterText(passwordTextFiled, '');
    expect(find.text('Enter a valid email'), findsOneWidget);

    //valid email
    await tester.enterText(emailTextFiled, 'my@email.com');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsNothing);
  });

  testWidgets('password validation', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.text('Sign in With Email and password'));
    await tester.pumpAndSettle();
    //expect that the checkBox is initially unchecked
    expect(uncheckedCheckBox, findsOneWidget);

    //expect that the submit button is shows 'Sign in' text
    expect(find.text('Sign in'), findsOneWidget);

    //Invalid password
    await tester.enterText(passwordTextFiled, 'mypassword');
    await tester.pump();
    expect(find.text('Enter a valid password'), findsOneWidget);

    //valid password
    await tester.enterText(passwordTextFiled, 'mypassword1');
    await tester.pump();
    expect(find.text('Enter a valid password'), findsNothing);
  });

  testWidgets('login with email and password', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.text('Sign in With Email and password'));
    await tester.pumpAndSettle();
    //Enter valid email and password
    await tester.enterText(emailTextFiled, 'my@email.com');
    await tester.enterText(passwordTextFiled, 'mypassword1');
    await tester.pump();

    expect(find.text('Enter a valid email'), findsNothing);
    expect(find.text('Enter a valid password'), findsNothing);

    //tap on the submit button
    await tester.tap(activeSubmitButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //expect to find one Scaffold. This means we are still in the MyApp()
    expect(find.byType(Scaffold), findsOneWidget);
    await tester.pumpAndSettle();
    //Expect to go to homepage after successfully signing in.
    expect(find.text('Welcome my@email.com!'), findsOneWidget);
  });

  testWidgets('Register and login with email and password', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.text('Sign in With Email and password'));
    await tester.pumpAndSettle();
    expect(uncheckedCheckBox, findsOneWidget);

    //check the CheckBox
    await tester.tap(find.byType(Checkbox));
    //expect that the submit button is shows 'Sign in' text
    expect(find.text('Sign in'), findsOneWidget);
    await tester.pump();
    expect(checkedCheckBox, findsOneWidget);
    //expect that the submit button is shows 'Register' text
    expect(find.text('Register'), findsOneWidget);

    //Enter valid email and password
    await tester.enterText(emailTextFiled, 'my@email.com');
    await tester.enterText(passwordTextFiled, 'mypassword1');
    await tester.pump();

    expect(find.text('Enter a valid email'), findsNothing);
    expect(find.text('Enter a valid password'), findsNothing);

    //tap on the submit button
    await tester.tap(activeSubmitButton);
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);

    await tester.enterText(confirmPasswordTextFiled, 'mypassword1');
    await tester.tap(activeSubmitButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //expect to find one Scaffold. This means we are still in the MyApp()
    expect(find.byType(Scaffold), findsOneWidget);
    await tester.pumpAndSettle();
    //Expect to go to homepage after successfully signing in.
    expect(find.text('Welcome my@email.com!'), findsOneWidget);
  });

  testWidgets('server validation', (tester) async {
    user.injectAuthMock(() =>
        FakeUserRepository(exception: EmailException('InValid server email')));

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.text('Sign in With Email and password'));
    await tester.pumpAndSettle();
    //Enter valid email and password
    await tester.enterText(emailTextFiled, 'my@email.com');
    await tester.enterText(passwordTextFiled, 'mypassword1');
    await tester.pump();

    expect(find.text('Enter a valid email'), findsNothing);
    expect(find.text('Enter a valid password'), findsNothing);

    //tap on the submit button
    await tester.tap(activeSubmitButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //expect to find one Scaffold. This means we are still in the MyApp()
    await tester.pumpAndSettle();
    expect(find.text('InValid server email'), findsOneWidget);
  });
}
