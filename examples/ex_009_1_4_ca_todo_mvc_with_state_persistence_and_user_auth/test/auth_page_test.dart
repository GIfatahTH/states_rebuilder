import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/main.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/pages/auth_page/auth_page.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/pages/home_screen/home_screen.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/common/extensions.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/value_object/token.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/entities/user.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'fake_auth_repository.dart';
import 'fake_todos_repository.dart';

void main() async {
  final storage = await RM.storageInitializerMock();

  setUp(() {
    user.injectAuthMock(() => FakeAuthRepository());
    todos.injectCRUDMock(() => FakeTodosRepository());
    DateTimeX.customNow = DateTime(2020);
    storage.clear();
  });

  testWidgets('Check form validation logic', (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    //
    expect(find.byType(AuthPage), findsOneWidget);
    //
    //Enter some invalid email
    await tester.enterText(find.byKey(Key('__EmailField__')), 'email');
    await tester.pump();
    //Not validated yet as it will validate on lose focus
    expect(find.text('Enter a valid email'), findsNothing);
    //Lose focus of the email field
    await tester.enterText(find.byKey(Key('__PasswordField__')), '');
    await tester.pump();
    //We expect to see a validation error
    expect(find.text('Enter a valid email'), findsOneWidget);
    //Enter a valid email
    await tester.enterText(find.byKey(Key('__EmailField__')), 'email@mail.com');
    await tester.pump();
    expect(find.text('Enter a valid email'), findsNothing);

    //
    //Enter some invalid password
    await tester.enterText(find.byKey(Key('__PasswordField__')), '12345');
    await tester.pump();
    //We expect to see a validation error
    expect(find.text('Enter a valid password'), findsOneWidget);
    //Enter a valid password
    await tester.enterText(find.byKey(Key('__PasswordField__')), '12345test');
    await tester.pump();
    expect(find.text('Enter a valid password'), findsNothing);

    //
    //Enter some invalid password
    await tester.enterText(find.byKey(Key('__PasswordField__')), '12345');
    await tester.pump();
    //We expect to see a validation error
    expect(find.text('Enter a valid password'), findsOneWidget);

    //Enter a valid password
    await tester.enterText(find.byKey(Key('__PasswordField__')), '12345test');
    await tester.pump();
    expect(find.text('Enter a valid password'), findsNothing);
  });

  testWidgets('Should Sign up and log out manually', (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    //
    expect(find.byType(AuthPage), findsOneWidget);
    //The default is the sign in mode
    expect(find.text('Sign in'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    //Sign up mode is activated
    expect(find.text('Sign up'), findsOneWidget);

    //Enter a valid email and password
    await tester.enterText(find.byKey(Key('__EmailField__')), 'user1@mail.com');
    await tester.enterText(find.byKey(Key('__PasswordField__')), '12345user1');
    await tester.pump();
    //Enter some invalid confirmation password
    await tester.enterText(
        find.byKey(Key('__ConfirmPasswordField__')), '12345');
    await tester.pump();
    //We expect to see a validation error
    expect(find.text('Passwords do not match'), findsOneWidget);

    //Enter a valid confirmation password
    await tester.enterText(
        find.byKey(Key('__ConfirmPasswordField__')), '12345user1');
    await tester.pump();
    expect(find.text('Passwords do not match'), findsNothing);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //ElevatedButton is hidden
    expect(find.byType(ElevatedButton), findsNothing);
    storage.isAsyncRead = true;

    //After one second
    await tester.pumpAndSettle();
    //User is signed up and logged and home Screen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);

    //
    //Check that the signed user is persisted
    expect(
      storage.store['__UserToken__']!.contains('"email":"user1@mail.com"'),
      isTrue,
    );
    expect(
        storage.store['__UserToken__']!
            .contains('"token":"token_user1@mail.com'),
        isTrue);
    //
    //Logging out
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__logout__')));
    await tester.pumpAndSettle();
    //We are it the AuthPage
    expect(find.byType(AuthPage), findsOneWidget);
    //The default is the sign in mode
    expect(find.text('Sign in'), findsOneWidget);
    //Check that the signed user is removed from storage
    expect(storage.store['__UserToken__'], isNull);
  });

  testWidgets('Should login  and log out after token expire', (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    //
    expect(find.byType(AuthPage), findsOneWidget);
    //The default is the sign in mode
    expect(find.text('Sign in'), findsOneWidget);

    //Enter a valid email and password
    await tester.enterText(find.byKey(Key('__EmailField__')), 'user1@mail.com');
    await tester.enterText(find.byKey(Key('__PasswordField__')), '12345user1');
    await tester.pump();
    //Raise button is active
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //ElevatedButton is hidden
    expect(find.byType(ElevatedButton), findsNothing);
    storage.isAsyncRead = true;
    //After one second
    await tester.pumpAndSettle(Duration(seconds: 1));
    //User is signed up and logged and home Screen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);
    //
    //Check that the signed user is persisted
    expect(
      storage.store['__UserToken__']!.contains('"email":"user1@mail.com"'),
      isTrue,
    );
    expect(
        storage.store['__UserToken__']!
            .contains('"token":"token_user1@mail.com"'),
        isTrue);
    //
    //auto logout after 10 seconds
    await tester.pumpAndSettle(Duration(seconds: 10));
    //We are it the AuthPage
    expect(find.byType(AuthPage), findsOneWidget);
    //The default is the sign in mode
    expect(find.text('Sign in'), findsOneWidget);
    //Check that the signed user is removed from storage
    expect(storage.store['__UserToken__'], isNull);
  });

  testWidgets('Should auto log if user has already logged with valid token',
      (tester) async {
    storage.store.addAll({
      '__UserToken__': _user,
    });
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    //User is auto logged and home Screen is displayed
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(TodoItem), findsNothing);
  });
}

final _user = User(
  userId: 'user1',
  email: 'user1@mail.com',
  token: Token(
    token: 'token_user1',
    expiryDate: DateTimeX.current.add(
      Duration(seconds: 10),
    ),
  ),
).toJson();
