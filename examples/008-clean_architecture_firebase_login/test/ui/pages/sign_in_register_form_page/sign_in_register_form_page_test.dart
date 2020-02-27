import 'package:clean_architecture_firebase_login/service/user_service.dart';
import 'package:clean_architecture_firebase_login/ui/pages/sign_in_register_form_page/sign_in_register_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../data_source/fake_user_repository.dart';

void main() {
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

  setUp(() {
    //The first thing to do is to isolate SignInRegisterFormPage by faking its dependencies
    //There is one dependency that should be faked (UserService)
    signInRegisterFormPage = Injector(
      inject: [Inject<UserService>(() => FakeUserService())],
      builder: (_) {
        return MaterialApp(
          home: SignInRegisterFormPage(),
        );
      },
    );
  });

  testWidgets('Email validation', (tester) async {
    await tester.pumpWidget(signInRegisterFormPage);

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
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    //expect to find no Scaffold. This means we are poppet out from the SignInRegisterFormPage
    expect(find.byType(Scaffold), findsNothing);
  });

  testWidgets('Register and login with email and password', (tester) async {
    await tester.pumpWidget(signInRegisterFormPage);

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
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    //expect to find no Scaffold. This means we are poppet out from the SignInRegisterFormPage
    expect(find.byType(Scaffold), findsNothing);
  });
}
