import 'package:clean_architecture_firebase_login/data_source/fake_user_repository.dart';
import 'package:clean_architecture_firebase_login/domain/entities/user.dart';
import 'package:clean_architecture_firebase_login/injected.dart';
import 'package:clean_architecture_firebase_login/main.dart';
import 'package:clean_architecture_firebase_login/ui/pages/home_page/home_page.dart';
import 'package:clean_architecture_firebase_login/ui/pages/sign_in_page/sign_in_page.dart';
import 'package:clean_architecture_firebase_login/ui/widgets/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  currentEnv = Env.dev;
  user.injectAuthMock(() => FakeUserRepository());
  canSignInWithApple.injectFutureMock(
    () => Future.delayed(Duration(seconds: 1), () => true),
  );
  testWidgets(
    'display SplashScreen and go to SignInPage after checking no current user',
    (tester) async {
      await tester.pumpWidget(MyApp());
      //At start up the app should display a SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(user.state, UnLoggedUser());
      expect(canSignInWithApple.state, false);
      //After one second of wait
      await tester.pump(Duration(seconds: 1));
      //SplashScreen should be still visible
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(user.state, UnLoggedUser());
      expect(canSignInWithApple.state, isTrue);

      //After another one second of wait
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.byType(SignInPage), findsNothing);
      await tester.pumpAndSettle(Duration(seconds: 1));
      //SignInPage should be displayed because user is null
      expect(find.byType(SignInPage), findsOneWidget);
      expect(user.state, UnLoggedUser());
      expect(canSignInWithApple.state, isTrue);
    },
  );
  testWidgets(
    'display SplashScreen and go to HomePage after successfully getting the current user',
    (tester) async {
      await tester.pumpWidget(MyApp());

      //setting the USerService to return a known user
      final repo = await user.getRepoAs<FakeUserRepository>();

      repo.fakeUser = User(
        uid: '1',
        displayName: "FakeUserDisplayName",
        email: 'fake@email.com',
      );

      //At start up the app should display a SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(user.state, UnLoggedUser());
      expect(canSignInWithApple.isWaiting, true);

      //After one second of wait
      await tester.pump(Duration(seconds: 1));
      //SplashScreen should be still visible
      expect(find.byType(SplashScreen), findsOneWidget);

      expect(user.state, UnLoggedUser());
      expect(canSignInWithApple.state, isTrue);

      //After another one second of wait
      await tester.pumpAndSettle(Duration(seconds: 2));
      //HomePage should be displayed because user is not null
      expect(find.byType(HomePage), findsOneWidget);
      //Expect to see the the logged user email displayed
      expect(find.text('Welcome fake@email.com!'), findsOneWidget);

      expect(user.state, isA<User>());
      expect(canSignInWithApple.state, isTrue);
    },
  );

  testWidgets(
    'on logout SignInPage should be displayed again',
    (tester) async {
      await tester.pumpWidget(MyApp());

      final repo = await user.getRepoAs<FakeUserRepository>();

      repo.fakeUser = User(
        uid: '1',
        displayName: "FakeUserDisplayName",
        email: 'fake@email.com',
      );

      //At start up the app should display a SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);

      //After two seconds of wait
      await tester.pumpAndSettle(Duration(seconds: 2));
      //SignInPage should be displayed because user is null
      expect(find.byType(HomePage), findsOneWidget);

      //tap on logout button
      await tester.tap(find.byType(IconButton));
      //We are still in the HomePage waiting for logout to complete
      expect(find.byType(HomePage), findsOneWidget);

      await tester.pumpAndSettle(Duration(seconds: 1));
      //Logout is completed with success
      expect(find.byType(SignInPage), findsOneWidget);
    },
  );
}
