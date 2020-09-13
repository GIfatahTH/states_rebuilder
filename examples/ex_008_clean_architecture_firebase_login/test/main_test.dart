import 'package:clean_architecture_firebase_login/domain/entities/user.dart';
import 'package:clean_architecture_firebase_login/main.dart';
import 'package:clean_architecture_firebase_login/service/apple_sign_in_checker_service.dart';
import 'package:clean_architecture_firebase_login/service/user_service.dart';
import 'package:clean_architecture_firebase_login/ui/pages/home_page/home_page.dart';
import 'package:clean_architecture_firebase_login/ui/pages/sign_in_page/sign_in_page.dart';
import 'package:clean_architecture_firebase_login/ui/widgets/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/fake_user_repository.dart';
import 'infrastructure/fake_apple_sign_in_available.dart';

void main() {
  Widget myApp;

  setUp(() {
    //To isolate MyApp we inject its fake implementation of AppSignInCheckerService and UserService
    myApp = MaterialApp(
      home: Injector(
        inject: [
          Inject<AppSignInCheckerService>(
              () => FakeAppSignInCheckerService(null)),
          Inject<UserService>(() => FakeUserService())
        ],
        builder: (_) => MyApp(),
      ),
    );
  });

  testWidgets(
    'display SplashScreen and go to SignInPage after checking no current user',
    (tester) async {
      await tester.pumpWidget(myApp);
      //At start up the app should display a SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(IN.get<UserService>().user, isNull);
      expect(IN.get<AppSignInCheckerService>().canSignInWithApple, isNull);
      //After one second of wait
      await tester.pump(Duration(seconds: 1));
      //SplashScreen should be still visible
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(IN.get<UserService>().user, isNull);
      expect(IN.get<AppSignInCheckerService>().canSignInWithApple, isTrue);

      //After another one second of wait
      await tester.pump(Duration(seconds: 1));
      //SignInPage should be displayed because user is null
      expect(find.byType(SignInPage), findsOneWidget);
      expect(IN.get<UserService>().user, isNull);
      expect(IN.get<AppSignInCheckerService>().canSignInWithApple, isTrue);
    },
  );
  testWidgets(
    'display SplashScreen and go to HomePage after successfully getting the current user',
    (tester) async {
      await tester.pumpWidget(myApp);

      //setting the USerService to return a known user
      (Injector.get<UserService>() as FakeUserService).fakeUser = User(
        uid: '1',
        displayName: "FakeUserDisplayName",
        email: 'fake@email.com',
      );

      //At start up the app should display a SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(IN.get<UserService>().user, isNull);
      expect(IN.get<AppSignInCheckerService>().canSignInWithApple, isNull);

      //After one second of wait
      await tester.pump(Duration(seconds: 1));
      //SplashScreen should be still visible
      expect(find.byType(SplashScreen), findsOneWidget);

      expect(IN.get<UserService>().user, isNull);
      expect(IN.get<AppSignInCheckerService>().canSignInWithApple, isTrue);

      //After another one second of wait
      await tester.pump(Duration(seconds: 1));
      //HomePage should be displayed because user is not null
      expect(find.byType(HomePage), findsOneWidget);
      //Expect to see the the logged user email displayed
      expect(find.text('Welcome fake@email.com!'), findsOneWidget);

      expect(IN.get<UserService>().user, isA<User>());
      expect(IN.get<AppSignInCheckerService>().canSignInWithApple, isTrue);
    },
  );

  testWidgets(
    'on logout SignInPage should be displayed again',
    (tester) async {
      await tester.pumpWidget(myApp);

      //setting the USerService to return a known user
      (Injector.get<UserService>() as FakeUserService).fakeUser =
          User(uid: '1', displayName: "FakeUserDisplayName");

      //At start up the app should display a SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);

      //After two seconds of wait
      await tester.pump(Duration(seconds: 2));
      //SignInPage should be displayed because user is null
      expect(find.byType(HomePage), findsOneWidget);

      //tap on logout button
      await tester.tap(find.byType(IconButton));
      //We are still in the HomePage waiting for logout to complete
      expect(find.byType(HomePage), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      //Logout is completed with success
      expect(find.byType(SignInPage), findsOneWidget);
    },
  );
}
