import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ex006_00_authentication_and_authorization/ex_000_user_authentication/app.dart';
import 'package:ex006_00_authentication_and_authorization/ex_000_user_authentication/blocs/auth_bloc.dart';
import 'package:ex006_00_authentication_and_authorization/ex_000_user_authentication/data_source/fake_user_repository.dart';
import 'package:ex006_00_authentication_and_authorization/ex_000_user_authentication/models/sign_in_out_exception.dart';
import 'package:ex006_00_authentication_and_authorization/ex_000_user_authentication/models/user.dart';
import 'package:ex006_00_authentication_and_authorization/ex_000_user_authentication/ui/home_page/home_page.dart';
import 'package:ex006_00_authentication_and_authorization/ex_000_user_authentication/ui/sign_in_page/sign_in_page.dart';
import 'package:ex006_00_authentication_and_authorization/ex_000_user_authentication/ui/sign_in_register_form_page/sign_in_register_form_page.dart';
import 'package:ex006_00_authentication_and_authorization/ex_000_user_authentication/ui/widgets/splash_screen.dart';

void main() {
  setUp(() {
    authBloc().injectAuthMock(() => FakeAuthRepository());
  });
  testWidgets(
    'display SplashScreen and go to SignInPage after checking no current user',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      //At start up the app should display a SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      //SignInPage should be displayed because user is null
      expect(find.byType(SignInPage), findsOneWidget);
      expect(authBloc.isUserAuthenticated, false);
    },
  );
  testWidgets(
    'display SplashScreen and go to HomePage after successfully getting the current user',
    (tester) async {
      await tester.pumpWidget(const MyApp());

      //setting the USerService to return a known user
      final repo = authBloc().getRepoAs<FakeAuthRepository>();

      repo.fakeUser = User(
        uid: '1',
        displayName: "FakeUserDisplayName",
        email: 'fake@email.com',
      );

      //At start up the app should display a SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);

      //After two second of wait
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      //HomePage should be displayed because user is not null
      expect(find.byType(HomePage), findsOneWidget);
      //Expect to see the the logged user email displayed
      expect(find.text('Welcome fake@email.com!'), findsOneWidget);
      expect(authBloc.user, isA<User>());
    },
  );

  testWidgets(
    'on logout SignInPage should be displayed again',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      final repo = authBloc().getRepoAs<FakeAuthRepository>();
      repo.fakeUser = User(
        uid: '1',
        displayName: "FakeUserDisplayName",
        email: 'fake@email.com',
      );

      // At start up the app should display a SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);

      // After two seconds of wait
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // SignInPage should be displayed because user is null
      expect(find.byType(HomePage), findsOneWidget);

      // logout using authStateChanges
      repo.sink.add(null);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(SignInPage), findsOneWidget);

      // login again using authStateChanges
      repo.sink.add(repo.fakeUser);
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      // tap on logout button
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      // We are still in the HomePage waiting for logout to complete
      expect(find.byType(HomePage), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Logout is completed with success
      expect(find.byType(SignInPage), findsOneWidget);
    },
  );

  testWidgets('Sign in With Google', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //check we are in the signInPage
    expect(find.text('Log in'), findsOneWidget);

    Finder signInBtn = find.byWidgetPredicate((widget) {
      return widget is ElevatedButton &&
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

    await tester.pumpAndSettle(const Duration(seconds: 1));
    //Expect to go to homepage after successfully signing in.
    expect(find.text('Welcome fake@email.com!'), findsOneWidget);
  });

  testWidgets('Sign in With anonymously', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //check we are in the signInPage
    expect(find.text('Log in'), findsOneWidget);

    Finder signInBtn = find.byWidgetPredicate((widget) {
      return widget is ElevatedButton &&
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

    await tester.pumpAndSettle(const Duration(seconds: 1));
    //Expect to go to homepage after successfully signing in.
    expect(find.text('Welcome fake@email.com!'), findsOneWidget);
  });

  testWidgets('Sign in With Email and password', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    //check we are in the signInPage
    expect(find.text('Log in'), findsOneWidget);

    Finder signInBtn = find.byWidgetPredicate((widget) {
      return widget is ElevatedButton &&
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
    authBloc().injectAuthMock(
      () => FakeAuthRepository(
        exception: AuthException(
          title: 'Sign in anonymously Alert',
          code: 'e.code',
          message: 'error message',
        ),
      ),
    );
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    Finder signInBtn = find.byWidgetPredicate((widget) {
      return widget is ElevatedButton &&
          (widget.child as Text).data == 'Sign in anonymously' &&
          //find active button
          widget.enabled;
    });

    //tap on the active to sign in
    await tester.tap(signInBtn);
    await tester.pump();
    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Sign in anonymously Alert'), findsOneWidget);
    expect(find.text('error message'), findsOneWidget);
  });

  group(
    'Sign in With Email and password',
    () {
      Finder emailTextFiled = find.byWidgetPredicate((widget) {
        return widget is TextField && widget.decoration?.labelText == 'Email';
      });
      Finder passwordTextFiled = find.byWidgetPredicate((widget) {
        return widget is TextField &&
            widget.decoration?.labelText == 'Password';
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
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle(const Duration(seconds: 2));
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
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle(const Duration(seconds: 2));
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
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle(const Duration(seconds: 2));
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
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle(const Duration(seconds: 2));
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

      testWidgets(
        'server validation',
        (tester) async {
          authBloc().injectAuthMock(
            () => FakeAuthRepository(
              exception: EmailException('InValid server email'),
            ),
          );

          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle(const Duration(seconds: 2));
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
          await tester.pumpAndSettle();
          expect(find.text('InValid server email'), findsOneWidget);
        },
      );
    },
  );
}
