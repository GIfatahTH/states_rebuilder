import 'package:clean_architecture_firebase_login/service/apple_sign_in_checker_service.dart';
import 'package:clean_architecture_firebase_login/service/exceptions/sign_in_out_exception.dart';
import 'package:clean_architecture_firebase_login/service/user_service.dart';
import 'package:clean_architecture_firebase_login/ui/pages/sign_in_page/sign_in_page.dart';
import 'package:clean_architecture_firebase_login/ui/pages/sign_in_register_form_page/sign_in_register_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../data_source/fake_user_repository.dart';
import '../../../infrastructure/fake_apple_sign_in_available.dart';

void main() {
  Widget singInPage;
  bool canSignInWithApple = true;
  setUp(
    () {
      //As always with test, we have to think on how to isolate SignInPage from its dependencies:
      singInPage = Injector(
        //SignInPage depends on AppSignInCheckerService and UserService
        //these dependencies can be faked using Injector by injecting there fake equivalent
        inject: [
          Inject<AppSignInCheckerService>(() =>
              FakeAppSignInCheckerService(null)
                ..canSignInWithApple = canSignInWithApple),
          Inject<UserService>(() => FakeUserService())
        ],
        //SignInPage has another subtile dependencies.
        //The rebuild of SignInPage is controlled from the MyApp widget (lines 43-50).
        //This subtile dependencies is faked using StateBuilder
        builder: (_) => MaterialApp(
          home: StateBuilder(
            observe: () => ReactiveModel<UserService>(),
            builder: (context, userServiceRM) {
              return userServiceRM.state.user == null
                  ? SignInPage()
                  : Text('My home page');
            },
          ),
        ),
      );
    },
  );

  testWidgets('Sign in With Apple', (tester) async {
    await tester.pumpWidget(singInPage);

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

    await tester.pump(Duration(seconds: 1));
    //Expect to go to homepage after successfully signing in.
    expect(find.text('My home page'), findsOneWidget);
  });

  testWidgets('Can not sign in With Apple', (tester) async {
    canSignInWithApple = false;
    await tester.pumpWidget(singInPage);

    //check we are in the signInPage
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Sign in With Apple Account'), findsNothing);
  });

  testWidgets('Sign in With Google', (tester) async {
    await tester.pumpWidget(singInPage);

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

    await tester.pump(Duration(seconds: 1));
    //Expect to go to homepage after successfully signing in.
    expect(find.text('My home page'), findsOneWidget);
  });

  testWidgets('Sign in With anonymously', (tester) async {
    await tester.pumpWidget(singInPage);

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

    await tester.pump(Duration(seconds: 1));
    //Expect to go to homepage after successfully signing in.
    expect(find.text('My home page'), findsOneWidget);
  });

  testWidgets('Sign in With Email and password', (tester) async {
    await tester.pumpWidget(singInPage);

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
    await tester.pumpWidget(singInPage);

    //set to throw a SignInException error
    (Injector.get<UserService>() as FakeUserService).error = SignInException(
      title: 'Sign in anonymously Alert',
      code: 'e.code',
      message: 'error message',
    );

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
