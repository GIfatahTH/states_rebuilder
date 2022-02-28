import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/app.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/blocs/auth_bloc.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/common/extensions.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/data_source/fake_auth_repository.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/models/token.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/models/user.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/ui/auth_page/auth_page.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/ui/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  final storage = await RM.storageInitializerMock();

  setUp(() {
    authBloc().injectAuthMock(() => FakeAuthRepository());
    DateTimeX.customNow = DateTime(2020);
    storage.clear();
  });

  testWidgets('Should login  and log out after token expire', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    //
    expect(find.byType(AuthPage), findsOneWidget);
    //The default is the sign in mode
    expect(find.text('Sign in'), findsOneWidget);

    //Enter a valid email and password
    await tester.enterText(
        find.byKey(const Key('__EmailField__')), 'user1@mail.com');
    await tester.enterText(
        find.byKey(const Key('__PasswordField__')), '12345user1');
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
    await tester.pumpAndSettle(const Duration(seconds: 1));
    //User is signed up and logged and home Screen is displayed
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Token is: ${authBloc.user.token.token}'), findsOneWidget);
    //
    //Check that the signed user is persisted
    expect(
      storage.store['__authenticatedUser__']!
          .contains('"email":"user1@mail.com"'),
      isTrue,
    );
    expect(
        storage.store['__authenticatedUser__']!
            .contains('"token":"${authBloc.user.token.token}"'),
        isTrue);
    //
    //auto logout after 10 seconds
    await tester.pumpAndSettle(const Duration(seconds: 10));
    //We are it the AuthPage
    expect(find.byType(AuthPage), findsOneWidget);
    //The default is the sign in mode
    expect(find.text('Sign in'), findsOneWidget);
    //Check that the signed user is removed from storage
    expect(storage.store['__authenticatedUser__'], isNull);
  });

  testWidgets('Should refresh token', (tester) async {
    authBloc()
        .injectAuthMock(() => FakeAuthRepository(shouldRefreshToken: true));

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    //
    expect(find.byType(AuthPage), findsOneWidget);
    //The default is the sign in mode
    expect(find.text('Sign in'), findsOneWidget);

    //Enter a valid email and password
    await tester.enterText(
        find.byKey(const Key('__EmailField__')), 'user1@mail.com');
    await tester.enterText(
        find.byKey(const Key('__PasswordField__')), '12345user1');
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
    await tester.pumpAndSettle(const Duration(seconds: 1));
    //User is signed up and logged and home Screen is displayed
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Token is: ${authBloc.user.token.token}'), findsOneWidget);
    //
    //Check that the signed user is persisted
    expect(
      storage.store['__authenticatedUser__']!
          .contains('"email":"user1@mail.com"'),
      isTrue,
    );
    expect(
        storage.store['__authenticatedUser__']!
            .contains('"token":"${authBloc.user.token.token}"'),
        isTrue);
    DateTimeX.customNow = DateTimeX.customNow!.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Token expires in 8 seconds'), findsOneWidget);
    DateTimeX.customNow = DateTimeX.customNow!.add(const Duration(seconds: 7));
    await tester.pump(const Duration(seconds: 7));
    expect(find.text('Token expires in 1 seconds'), findsOneWidget);
    DateTimeX.customNow = DateTimeX.customNow!.add(const Duration(seconds: 1));
    final tokenBeforeRefreshing = authBloc.user.token;
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Refresh the token'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    //We are still in HomePage
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Token is: ${authBloc.user.token.token}'), findsOneWidget);
    expect(tokenBeforeRefreshing != authBloc.user.token, true);
    expect(find.text('Token expires in 20 seconds'), findsOneWidget);
    expect(
        storage.store['__authenticatedUser__']!
            .contains('"token":"${authBloc.user.token.token}"'),
        isTrue);
  });

  testWidgets('Should auto log if user has already logged with valid token',
      (tester) async {
    storage.store.addAll({
      '__authenticatedUser__': _user,
    });
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    //User is auto logged and home Screen is displayed
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Token is: ${authBloc.user.token.token}'), findsOneWidget);
  });
}

final _user = User(
  userId: 'user1',
  email: 'user1@mail.com',
  token: Token(
    token: 'token_user1',
    refreshToken: 'refreshToken_user1',
    expiryDate: DateTimeX.current.add(
      const Duration(seconds: 10),
    ),
  ),
).toJson();
