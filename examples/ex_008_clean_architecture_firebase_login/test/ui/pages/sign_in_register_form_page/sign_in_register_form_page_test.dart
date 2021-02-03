import 'package:clean_architecture_firebase_login/injected.dart';
import 'package:clean_architecture_firebase_login/service/user_service.dart';
import 'package:clean_architecture_firebase_login/ui/pages/sign_in_register_form_page/sign_in_register_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../data_source/fake_user_repository.dart';

void main() {
  userService.injectMock(() => FakeUserService());

  Widget signInRegisterFormPage;

  Finder emailTextFiled = find.byWidgetPredicate((widget) {
    return widget is TextField && widget.decoration.labelText == 'Email';
  });
  Finder passwordTextFiled = find.byWidgetPredicate((widget) {
    return widget is TextField && widget.decoration.labelText == 'Password';
  });
  Finder activeSubmitButton = find.byWidgetPredicate((widget) {
    return widget is RaisedButton && widget.enabled;
  });
  Finder uncheckedCheckBox = find.byWidgetPredicate((widget) {
    return widget is Checkbox && !widget.value;
  });

  Finder checkedCheckBox = find.byWidgetPredicate((widget) {
    return widget is Checkbox && widget.value;
  });

  setUp(
    () {
      //The first thing to do is to isolate SignInRegisterFormPage by faking its dependencies
      //There is one dependency that should be faked (UserService)
      signInRegisterFormPage = MaterialApp(
        //From SignInRegisterFormPage we have to notify StateBuilder in main.dart page (line 50)
        //I wrapped the RaisedButton with StateBuilder and subscribe it to the UserService ReactiveModel.
        home: userService.listen(
          child: On(
            () => RaisedButton(
              child: Text('Log in with email and password'),
              onPressed: () {
                Navigator.push(
                  RM.context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignInRegisterFormPage();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );

  testWidgets('Email validation', (tester) async {
    await tester.pumpWidget(signInRegisterFormPage);
    await tester.tap(find.byType(RaisedButton));
    await tester.pumpAndSettle();
    //expect that the checkBox is initially unchecked
    expect(uncheckedCheckBox, findsOneWidget);
    //expect that the submit button is initially inactive
    expect(activeSubmitButton, findsNothing);
    //expect that the submit button is shows 'Sign in' text
    expect(find.text('Sign in'), findsOneWidget);

    //Invalid email
    await tester.enterText(emailTextFiled, 'myemail.com');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(activeSubmitButton, findsNothing);

    //valid email
    await tester.enterText(emailTextFiled, 'my@email.com');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsNothing);
    expect(activeSubmitButton, findsNothing);
  });

  testWidgets('password validation', (tester) async {
    await tester.pumpWidget(signInRegisterFormPage);
    await tester.tap(find.byType(RaisedButton));
    await tester.pumpAndSettle();
    //expect that the checkBox is initially unchecked
    expect(uncheckedCheckBox, findsOneWidget);
    //expect that the submit button is initially inactive
    expect(activeSubmitButton, findsNothing);
    //expect that the submit button is shows 'Sign in' text
    expect(find.text('Sign in'), findsOneWidget);

    //Invalid password
    await tester.enterText(passwordTextFiled, 'mypassword');
    await tester.pump();
    expect(find.text('Enter a valid password'), findsOneWidget);
    expect(activeSubmitButton, findsNothing);

    //valid password
    await tester.enterText(passwordTextFiled, 'mypassword1');
    await tester.pump();
    expect(find.text('Enter a valid password'), findsNothing);
    expect(activeSubmitButton, findsNothing);
  });

  testWidgets('login with email and password', (tester) async {
    await tester.pumpWidget(signInRegisterFormPage);
    await tester.tap(find.byType(RaisedButton));
    await tester.pumpAndSettle();
    //Enter valid email and password
    await tester.enterText(emailTextFiled, 'my@email.com');
    await tester.enterText(passwordTextFiled, 'mypassword1');
    await tester.pump();

    expect(find.text('Enter a valid email'), findsNothing);
    expect(find.text('Enter a valid password'), findsNothing);
    expect(activeSubmitButton, findsOneWidget);

    //tap on the submit button
    await tester.tap(activeSubmitButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //expect to find one Scaffold. This means we are still in the SignInRegisterFormPage
    expect(find.byType(Scaffold), findsOneWidget);
    await tester.pumpAndSettle();
    //expect to find no Scaffold. This means we are poppet out from the SignInRegisterFormPage
    expect(find.byType(Scaffold), findsNothing);
    expect(find.text('Log in with email and password'), findsOneWidget);
  });

  testWidgets('Register and login with email and password', (tester) async {
    await tester.pumpWidget(signInRegisterFormPage);
    await tester.tap(find.byType(RaisedButton));
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
    expect(activeSubmitButton, findsOneWidget);

    //tap on the submit button
    await tester.tap(activeSubmitButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //expect to find one Scaffold. This means we are still in the SignInRegisterFormPage
    expect(find.byType(Scaffold), findsOneWidget);
    await tester.pumpAndSettle();
    //expect to find no Scaffold. This means we are poppet out from the SignInRegisterFormPage
    expect(find.byType(Scaffold), findsNothing);
    expect(find.text('Log in with email and password'), findsOneWidget);
  });
}
