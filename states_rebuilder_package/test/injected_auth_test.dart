import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

class FakeAuthRepo implements IAuth<String, String> {
  dynamic error;
  @override
  Future<IAuth<String, String>> init() async {
    return this;
  }

  @override
  Future<String> signUp(String? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    if (param == '1') {
      return 'user1';
    } else if (param == '2') {
      return 'user2';
    }
    return 'user0';
  }

  @override
  Future<String> signIn(String? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    if (param == '1') {
      return 'user1';
    } else if (param == '2') {
      return 'user2';
    }
    return 'user0';
  }

  @override
  Future<void> signOut(String? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
  }

  @override
  void dispose() {}
}

int onUnSigned = 0;
int onSigned = 0;
final user = RM.injectAuth(
  () => FakeAuthRepo(),
  unsignedUser: 'user0',
  onUnsigned: () => onUnSigned++,
  onSigned: (_) => onSigned++,
);
InjectedAuth<String, String> persistedUser = RM.injectAuth<String, String>(
  () => FakeAuthRepo(),
  unsignedUser: 'user0',
  persist: () => PersistState(
    key: '__user__',
    fromJson: (json) => json == 'expiredTokenUser' ? 'user0' : json,
  ),
  onSigned: (user) => RM.navigate.to(HomePage(user: user)),
  onUnsigned: () => RM.navigate.to(AuthPage()),
  onSetState: On.error(
    (err) => RM.navigate.to(
      AlertDialog(
        content: Text('${err.message}'),
      ),
    ),
  ),
);

InjectedAuth<String, String> persistedUserWithAutoDispose =
    RM.injectAuth<String, String>(
  () => FakeAuthRepo(),
  unsignedUser: 'user0',
  persist: () => PersistState(key: '__user__'),
  onSigned: (user) => RM.navigate.to(HomePage(user: user)),
  onUnsigned: () => RM.navigate.to(AuthPage()),
  autoSignOut: (_) => Duration(seconds: 5),
);

late Widget widget;
late Widget widgetWithAutoDispose;

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return On.or(
      onWaiting: () => Text('AuthPage: Waiting...'),
      or: () => Text('AuthPage'),
    ).listenTo(persistedUser);
  }
}

class HomePage extends StatelessWidget {
  final String user;

  const HomePage({Key? key, required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text('HomePage: $user');
  }
}

void main() async {
  final store = await RM.storageInitializerMock();
  setUp(() {
    RM.disposeAll();
    store.clear();
    onUnSigned = 0;
    onSigned = 0;
    widget = MaterialApp(
      home: persistedUser.futureBuilder(
        onWaiting: null,
        onError: (_) => Text('Error'),
        onData: (_) => Text('Waiting...'),
      ),
      navigatorKey: RM.navigate.navigatorKey,
    );

    widgetWithAutoDispose = MaterialApp(
      home: persistedUserWithAutoDispose.futureBuilder(
        onWaiting: null,
        onError: (_) => Text('Error'),
        onData: (_) => Text('Waiting...'),
      ),
      navigatorKey: RM.navigate.navigatorKey,
    );
  });
  testWidgets('sign with unsigned unsigned user', (tester) async {
    await tester.pumpWidget(widget);
    expect(user.state, 'user0');
    await tester.pump();
    //
    expect(onUnSigned, 1);
    expect(onSigned, 0);
    //
    user.auth.signIn(() => '3');
    expect(user.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(user.hasData, true);
    expect(user.state, 'user0');
    //
    expect(onUnSigned, 2);
    expect(onSigned, 0);
  });
  testWidgets('Sign with signed user', (tester) async {
    await tester.pumpWidget(widget);
    expect(user.state, 'user0');
    await tester.pump();
    expect(onUnSigned, 1);
    expect(onSigned, 0);
    user.auth.signIn(() => '1');
    await tester.pump(Duration(seconds: 1));
    expect(user.state, 'user1');
    expect(onUnSigned, 1);
    expect(onSigned, 1);
  });

  testWidgets('Sign up a user', (tester) async {
    await tester.pumpWidget(widget);
    expect(user.state, 'user0');
    await tester.pump();
    expect(onUnSigned, 1);
    expect(onSigned, 0);
    user.auth.signUp(() => '2');
    await tester.pump(Duration(seconds: 1));
    expect(user.state, 'user2');
    expect(onUnSigned, 1);
    expect(onSigned, 1);
  });

  testWidgets(
    'auto sign up when persist is defined, case no user is persisted yet',
    (tester) async {
      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('AuthPage'), findsOneWidget);
    },
  );

  testWidgets(
    'sing up and log out, persist user after sign up and '
    'delete it after sign out',
    (tester) async {
      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('AuthPage'), findsOneWidget);
      persistedUser.auth.signUp(() => '1');
      await tester.pump();
      expect(find.text('AuthPage: Waiting...'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('HomePage: user1'), findsOneWidget);
      expect(store.store!['__user__'], 'user1');
      persistedUser.auth.signOut();
      await tester.pumpAndSettle();
      expect(find.text('AuthPage'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(store.store!['__user__'], null);
    },
  );

  testWidgets(
    'auto sign in when persist is defined, case a user is persisted with'
    'valid token, display home page',
    (tester) async {
      store.store = {
        '__user__': 'Persisted user',
      };
      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('HomePage: Persisted user'), findsOneWidget);
    },
  );

  testWidgets(
    'auto sign in when persist is defined, case a user is persisted with'
    'non valid token, display auth page',
    (tester) async {
      store.store = {
        '__user__': 'expiredTokenUser',
      };
      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('AuthPage'), findsOneWidget);
    },
  );

  testWidgets(
    'on sign in error, display an AlertDialog with the error',
    (tester) async {
      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('AuthPage'), findsOneWidget);
      final repo = await persistedUser.getRepoAs<FakeAuthRepo>();
      repo.error = Exception('Sign in exception');
      persistedUser.auth.signIn(() => '1');
      await tester.pump();
      expect(find.text('AuthPage: Waiting...'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Sign in exception'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    },
  );
  testWidgets(
    'onError defined in signUp and signIn override the global one',
    (tester) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      final repo = await persistedUser.getRepoAs<FakeAuthRepo>();
      repo.error = Exception('Sign in exception');
      String error = '';
      persistedUser.auth.signIn(
        () => '1',
        onError: (err) => error = err.message,
      );
      await tester.pump();
      expect(find.text('AuthPage: Waiting...'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(error, 'Sign in exception');
      expect(find.text('Sign in exception'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      error = '';
      persistedUser.auth.signUp(
        () => '1',
        onError: (err) => error = err.message,
      );
      await tester.pump();
      expect(find.text('AuthPage: Waiting...'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(error, 'Sign in exception');
      expect(find.text('Sign in exception'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'onAuthenticated defined in signIn and Up override the global one',
    (tester) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      expect(find.text('AuthPage'), findsOneWidget);
      String onAuthenticated = '';
      persistedUser.auth.signUp(
        () => '1',
        onAuthenticated: () {
          onAuthenticated = 'isCalled';
        },
      );
      await tester.pump();
      expect(find.text('AuthPage: Waiting...'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('AuthPage'), findsOneWidget);
      expect(onAuthenticated, 'isCalled');
      onAuthenticated = '';
      persistedUser.auth.signIn(
        () => '1',
        onAuthenticated: () {
          onAuthenticated = 'isCalled';
        },
      );
      await tester.pump();
      expect(find.text('AuthPage: Waiting...'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('AuthPage'), findsOneWidget);
      expect(onAuthenticated, 'isCalled');
    },
  );

  testWidgets(
    'auto logout when timer (token) expired, case state is persisted',
    (tester) async {
      store.store = {
        '__user__': 'Persisted user',
      };
      await tester.pumpWidget(widgetWithAutoDispose);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('HomePage: Persisted user'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 5));
      expect(find.text('AuthPage'), findsOneWidget);
    },
  );

  testWidgets(
    'auto logout when timer (token) expired, after sign in',
    (tester) async {
      await tester.pumpWidget(widgetWithAutoDispose);
      await tester.pumpAndSettle();
      persistedUserWithAutoDispose.auth.signIn(() => '2');
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('HomePage: user2'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 5));
      expect(find.text('AuthPage'), findsOneWidget);
    },
  );

  testWidgets(
    'auto logout when timer (token) expired, after sign up',
    (tester) async {
      await tester.pumpWidget(widgetWithAutoDispose);
      await tester.pumpAndSettle();
      persistedUserWithAutoDispose.auth.signUp(() => '2');
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('HomePage: user2'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 5));
      expect(find.text('AuthPage'), findsOneWidget);
    },
  );

  testWidgets(
    'when auto sign out is set and widget is disposed timer is canceled',
    (tester) async {
      await tester.pumpWidget(widgetWithAutoDispose);
      await tester.pumpAndSettle();
      persistedUserWithAutoDispose.auth.signIn(() => '2');
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('HomePage: user2'), findsOneWidget);
      persistedUserWithAutoDispose.dispose();
      //no timer is pending
    },
  );
}
