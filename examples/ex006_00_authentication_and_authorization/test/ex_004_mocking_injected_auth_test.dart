import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/app.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/blocs/auth_bloc.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/models/token.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/models/user.dart';
import 'package:ex006_00_authentication_and_authorization/ex_003_auto_logout_and_refresh_token/ui/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  // Mock local storage
  await RM.storageInitializerMock();

  testWidgets(
    'Mock with injectedMock',
    (tester) async {
      authBloc().injectMock(
        () => User(
          userId: 'user_id',
          displayName: 'fake user',
          email: 'fake@email.com',
          token: Token(
            token: 'Token',
            refreshToken: 'refresh token',
            expiryDate: DateTime.now().add(const Duration(seconds: 30)),
          ),
        ),
      );
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Welcome fake@email.com'), findsOneWidget);
      expect(find.text('Token is: Token'), findsOneWidget);
    },
  );

  testWidgets(
    'Mock with injectFutureMock',
    (tester) async {
      authBloc().injectFutureMock(
        () async {
          await Future.delayed(const Duration(seconds: 3));
          return User(
            userId: 'user_id',
            displayName: 'fake user',
            email: 'fake@email.com',
            token: Token(
              token: 'Token',
              refreshToken: 'refresh token',
              expiryDate: DateTime.now().add(const Duration(seconds: 30)),
            ),
          );
        },
      );
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Welcome fake@email.com'), findsOneWidget);
      expect(find.text('Token is: Token'), findsOneWidget);
    },
  );
}
