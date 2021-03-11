import 'package:clean_architecture_firebase_login/data_source/fake_user_repository.dart';
import 'package:clean_architecture_firebase_login/injected.dart';
import 'package:clean_architecture_firebase_login/main.dart';
import 'package:clean_architecture_firebase_login/service/exceptions/sign_in_out_exception.dart';
import 'package:clean_architecture_firebase_login/ui/pages/sign_in_register_form_page/sign_in_register_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  currentEnv = Env.dev;
  user.injectAuthMock(() => FakeUserRepository());
  canSignInWithApple.injectFutureMock(
    () => Future.delayed(Duration(seconds: 1), () => true),
  );

  testWidgets('Sign in With Apple', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));

    //check we are in the signInPage
    expect(find.text('Log in'), findsOneWidget);

    Finder signInBtn = find.byWidgetPredicate((widget) {
      return widget is RaisedButton &&
          (widget.child as Text).data == 'Sign in With Apple Account' &&
          //find active button
          widget.enabled;
    });

    //tap on the active sign in with apple button
    await tester.tap(signInBtn);
    await tester.pump();
    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //Expect the sign in with apple button to be inactive
    expect(signInBtn, findsNothing);

    await tester.pumpAndSettle(Duration(seconds: 1));
    //Expect to go to homepage after successfully signing in.
    expect(find.text('Welcome fake@email.com!'), findsOneWidget);
  });

  testWidgets('Can not sign in With Apple', (tester) async {
    canSignInWithApple.injectMock(() => false);

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 3));

    //check we are in the signInPage
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Sign in With Apple Account'), findsNothing);
  });

  testWidgets('Sign in With Google', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));

    //check we are in the signInPage
    expect(find.text('Log in'), findsOneWidget);

    Finder signInBtn = find.byWidgetPredicate((widget) {
      return widget is RaisedButton &&
          (widget.child as Text).data == 'Sign in With Google Account' &&
          //find active button
          widget.enabled;
    });

    //tap on the active to sign in
    await tester.tap(signInBtn);
    await tester.pump();
    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //Expect the sign in with apple button to be inactive
    expect(signInBtn, findsNothing);

    await tester.pumpAndSettle(Duration(seconds: 1));
    //Expect to go to homepage after successfully signing in.
    expect(find.text('Welcome fake@email.com!'), findsOneWidget);
  });

  testWidgets('Sign in With anonymously', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));

    //check we are in the signInPage
    expect(find.text('Log in'), findsOneWidget);

    Finder signInBtn = find.byWidgetPredicate((widget) {
      return widget is RaisedButton &&
          (widget.child as Text).data == 'Sign in anonymously' &&
          //find active button
          widget.enabled;
    });

    //tap on the active to sign in
    await tester.tap(signInBtn);
    await tester.pump();
    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //Expect the sign in with apple button to be inactive
    expect(signInBtn, findsNothing);

    await tester.pumpAndSettle(Duration(seconds: 1));
    //Expect to go to homepage after successfully signing in.
    expect(find.text('Welcome fake@email.com!'), findsOneWidget);
  });

  testWidgets('Sign in With Email and password', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));

    //check we are in the signInPage
    expect(find.text('Log in'), findsOneWidget);

    Finder signInBtn = find.byWidgetPredicate((widget) {
      return widget is RaisedButton &&
          (widget.child as Text).data == 'Sign in With Email and password' &&
          //find active button
          widget.enabled;
    });

    //tap on the active to sign in
    await tester.tap(signInBtn);
    //pump until page animation finishes
    await tester.pumpAndSettle();
    //Expect to navigate to SignInRegisterFormPage
    expect(find.byType(SignInRegisterFormPage), findsOneWidget);
  });

  testWidgets('display alertDialog on SignInException', (tester) async {
    user.injectAuthMock(
      () => FakeUserRepository(
        error: SignInException(
          title: 'Sign in anonymously Alert',
          code: 'e.code',
          message: 'error message',
        ),
      ),
    );
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));

    Finder signInBtn = find.byWidgetPredicate((widget) {
      return widget is RaisedButton &&
          (widget.child as Text).data == 'Sign in anonymously' &&
          //find active button
          widget.enabled;
    });

    //tap on the active to sign in
    await tester.tap(signInBtn);
    await tester.pump();
    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Sign in anonymously Alert'), findsOneWidget);
    expect(find.text('error message'), findsOneWidget);
  });
}
