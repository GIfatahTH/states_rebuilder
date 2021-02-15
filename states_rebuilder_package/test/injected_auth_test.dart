import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

String disposeMessage = '';

class FakeAuthRepo implements IAuth<String, String> {
  dynamic error;
  @override
  Future<void> init() async {}

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

  Future<String> futreSignIn(String user) async {
    await Future.delayed(Duration(seconds: 1));
    return user;
  }

  Stream<String> onAuthChanged() {
    return Stream.periodic(Duration(seconds: 1), (num) {
      if (num < 1) return 'user0';
      return 'user1';
    });
  }

  @override
  void dispose() {
    disposeMessage = 'isDisposed';
  }
}

int onUnSigned = 0;
int onSigned = 0;
final user = RM.injectAuth(
  () => FakeAuthRepo(),
  unsignedUser: 'user0',
  onUnsigned: () => onUnSigned++,
  onSigned: (_) => onSigned++,
);
InjectedAuth<String, String> persistedUser = RM.injectAuth(
  () => FakeAuthRepo(),
  unsignedUser: 'user0',
  persist: () => PersistState(
    key: '__user__',
    fromJson: (json) => json == 'expiredTokenUser' ? 'user0' : json,
  ),
  onSigned: (user) => RM.navigate.to(HomePage(user: user)),
  onUnsigned: () => RM.navigate.to(AuthPage(persistedUser)),
  onSetState: On.error(
    (err, _) => RM.navigate.to(
      AlertDialog(
        content: Text('${err.message}'),
      ),
    ),
  ),
);

InjectedAuth<String, String> persistedUserWithAutoDispose = RM.injectAuth(
  () => FakeAuthRepo(),
  unsignedUser: 'user0',
  persist: () => PersistState(key: '__user__'),
  onSigned: (user) => RM.navigate.toReplacement(HomePage(user: user)),
  onUnsigned: () =>
      RM.navigate.toReplacement(AuthPage(persistedUserWithAutoDispose)),
  autoSignOut: (_) => Duration(seconds: 5),
);

late Widget widget;
late Widget widgetWithAutoDispose;

class AuthPage extends StatelessWidget {
  final InjectedAuth<String, String> persistedUser;

  const AuthPage(this.persistedUser);

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
    disposeMessage = '';
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
    user.auth.signIn((_) => '3');
    expect(user.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(user.hasData, true);
    expect(user.state, 'user0');
    //
    expect(onUnSigned, 2);
    expect(onSigned, 0);

    expect(disposeMessage, '');
    user.dispose();
    await tester.pump();
    expect(disposeMessage, 'isDisposed');
  });
  testWidgets('Sign with signed user', (tester) async {
    await tester.pumpWidget(widget);
    expect(user.state, 'user0');
    await tester.pump();
    expect(onUnSigned, 1);
    expect(onSigned, 0);
    user.auth.signIn((_) => '1');
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
    user.auth.signUp((_) => '2');
    await tester.pump(Duration(seconds: 1));
    expect(user.state, 'user2');
    expect(onUnSigned, 1);
    expect(onSigned, 1);
    expect(disposeMessage, '');
    user.dispose();
    await tester.pump();
    expect(disposeMessage, 'isDisposed');
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
      persistedUser.auth.signUp((_) => '1');
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
      persistedUser.auth.signIn((_) => '1');
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
        (_) => '1',
        onError: (err, _) => error = err.message,
      );
      await tester.pump();
      expect(find.text('AuthPage: Waiting...'), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(error, 'Sign in exception');
      expect(find.text('Sign in exception'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      error = '';
      persistedUser.auth.signUp(
        (_) => '1',
        onError: (err, _) => error = err.message,
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
        (_) => '1',
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
        (_) => '1',
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
        '__user__': 'Persisted user with auto signOut',
      };
      await tester.pumpWidget(widgetWithAutoDispose);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('HomePage: Persisted user with auto signOut'),
          findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('AuthPage'), findsOneWidget);
    },
  );

  testWidgets(
    'auto logout when timer (token) expired, after sign in',
    (tester) async {
      await tester.pumpWidget(widgetWithAutoDispose);
      await tester.pumpAndSettle();
      persistedUserWithAutoDispose.auth.signIn((_) => '2');
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
      persistedUserWithAutoDispose.auth.signUp((_) => '2');
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
      persistedUserWithAutoDispose.auth.signIn((_) => '2');
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('HomePage: user2'), findsOneWidget);
      persistedUserWithAutoDispose.dispose();
      //no timer is pending
    },
  );
  testWidgets(
      'WHEN onAuthStream is defined'
      'THEN user listens to it and authenticate accordingly', (tester) async {
    final user = RM.injectAuth(
      () => FakeAuthRepo(),
      unsignedUser: 'user0',
      onUnsigned: () => onUnSigned++,
      onSigned: (_) => onSigned++,
      onAuthStream: (repo) => (repo as FakeAuthRepo).onAuthChanged(),
    );

    expect(user.isSigned, false);
    expect(onUnSigned, 0);
    expect(onSigned, 0);
    await tester.pump(Duration(seconds: 1));
    expect(user.isSigned, false);
    expect(onUnSigned, 1);
    expect(onSigned, 0);
    await tester.pump(Duration(seconds: 1));
    expect(user.isSigned, true);
    expect(onUnSigned, 1);
    expect(onSigned, 1);
    await tester.pump(Duration(seconds: 1));
    expect(user.isSigned, true);
    expect(onUnSigned, 1);
    expect(onSigned, 1);
    user.dispose();
  });

  testWidgets(
      'WHEN onAuthStream is defined'
      'AND WHEN the stream emits an error'
      'THEN user state has the same error'
      'AND sign out', (tester) async {
    final user = RM.injectAuth(
      () => FakeAuthRepo(),
      unsignedUser: 'user0',
      onUnsigned: () => onUnSigned++,
      onSigned: (_) => onSigned++,
      onAuthStream: (repo) => Stream.periodic(Duration(seconds: 1), (num) {
        if (num == 1) return 'user1';
        throw Exception('Stream Error');
      }),
    );

    expect(user.isSigned, false);
    expect(onUnSigned, 0);
    expect(onSigned, 0);
    await tester.pump(Duration(seconds: 1));
    expect(user.isSigned, false);
    expect(onUnSigned, 1);
    expect(onSigned, 0);
    await tester.pump(Duration(seconds: 1));
    expect(user.isSigned, true);
    expect(onUnSigned, 1);
    expect(onSigned, 1);
    await tester.pump(Duration(seconds: 1));
    expect(user.error.message, 'Stream Error');
    expect(user.isSigned, false);
    expect(onUnSigned, 2);
    expect(onSigned, 1);
    user.dispose();
  });

  testWidgets(
    'WHEN onAuthStream is defined'
    'AND autoSignout is defined '
    'THEN autoSignout will work',
    (tester) async {
      final user = RM.injectAuth(
        () => FakeAuthRepo(),
        unsignedUser: 'user0',
        autoSignOut: (_) => Duration(seconds: 2),
        onAuthStream: (repo) => (repo as FakeAuthRepo).onAuthChanged(),
      );
      expect(user.isSigned, false);
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, false);

      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, false);
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);

      user.dispose();
    },
  );

  testWidgets(
    'WHEN onInitialWaiting of On.auth  is defined'
    'AND WHEN onAuthStream is defined'
    'THEN onInitialWaiting is invoked only one time the app starts',
    (tester) async {
      final user = RM.injectAuth(
        () => FakeAuthRepo(),
        unsignedUser: 'user0',
        autoSignOut: (_) => Duration(seconds: 1),
        onAuthStream: (repo) =>
            (repo as FakeAuthRepo).futreSignIn('user0').asStream(),
      );

      final widget = Directionality(
        textDirection: TextDirection.rtl,
        child: On.auth(
          onInitialWaiting: () => Text('Initial Waiting...'),
          onWaiting: () => Text('Waiting...'),
          onUnsigned: () => Text('Unsigned'),
          onSigned: () => Text('Signed'),
        ).listenTo(user),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Initial Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Unsigned'), findsOneWidget);
      //
      user.setState((s) async {
        await Future.delayed(Duration(seconds: 1));
        return 'user1';
      });
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Signed'), findsOneWidget);
      //auto sign out
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Unsigned'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
    },
  );

  testWidgets(
    'WHEN useRouteNavigation is true'
    'The transition between onSignedIn and onSignedOut is done using navigation',
    (tester) async {
      final widget = MaterialApp(
        home: On.auth(
          onInitialWaiting: () => Text('Initial Waiting...'),
          onUnsigned: () => Text('Unsigned'),
          onSigned: () => Text('Signed'),
        ).listenTo(
          user,
          useRouteNavigation: true,
        ),
        navigatorKey: RM.navigate.navigatorKey,
      );

      await tester.pumpWidget(widget);
      expect(find.text('Unsigned'), findsOneWidget);
      user.auth.signUp((param) => '1');
      expect(find.text('Unsigned'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      await tester.pump();
      expect(find.text('Unsigned'), findsOneWidget);
      expect(find.text('Signed'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Unsigned'), findsNothing);
      expect(find.text('Signed'), findsOneWidget);
      //
      user.auth.signOut();
      await tester.pump();
      await tester.pump();
      //expect(find.text('Unsigned'), findsOneWidget);
      expect(find.text('Signed'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Unsigned'), findsOneWidget);
      expect(find.text('Signed'), findsNothing);
      await tester.pump(Duration(seconds: 1));
    },
  );

  testWidgets(
    'WHEN useRouteNavigation is true'
    'AND WHEN user is persisted'
    'THEN The transition between onSignedIn and onSignedOut is done using navigation'
    'AND onSignedIn is rendered first ',
    (tester) async {
      store.store?.addAll({'__user__': 'user1'});
      final InjectedAuth<String, String> user = RM.injectAuth(
        () => FakeAuthRepo(),
        unsignedUser: 'user0',
        persist: () => PersistState(
          key: '__user__',
        ),
      );

      final widget = MaterialApp(
        home: On.auth(
          onInitialWaiting: () => Text('Initial Waiting...'),
          onUnsigned: () => Text('Unsigned'),
          onSigned: () => Text('Signed'),
        ).listenTo(
          user,
          useRouteNavigation: true,
        ),
        navigatorKey: RM.navigate.navigatorKey,
      );

      await tester.pumpWidget(widget);
      expect(find.text('Signed'), findsOneWidget);

      //
      user.auth.signOut();

      expect(find.text('Signed'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Unsigned'), findsOneWidget);
      expect(find.text('Signed'), findsNothing);
      await tester.pump(Duration(seconds: 1));
    },
  );

  testWidgets(
    'WHEN middleSnapState is defined '
    'THEN we can control how snapState is mutated',
    (tester) async {
      SnapState<String>? _snapState;
      late SnapState<String> _nextSnapState;

      final InjectedAuth<String, String> user = RM.injectAuth(
        () => FakeAuthRepo(),
        unsignedUser: 'user0',
        onAuthStream: (_) => Future.delayed(
          Duration(seconds: 1),
          () => 'user1',
        ).asStream(),
        middleSnapState: (snapState, nextSnapState) {
          _snapState = snapState;
          _nextSnapState = nextSnapState;
          if (nextSnapState.hasData && nextSnapState.data == 'user1') {
            return nextSnapState.copyWith(data: 'user100');
          }
        },
      );
      expect(user.isWaiting, true);
      expect(_snapState, isNotNull);
      expect(_snapState?.isIdle, true);
      expect(_snapState?.data, 'user0');
      //
      expect(_nextSnapState.isWaiting, true);
      expect(_nextSnapState.data, 'user0');
      await tester.pump(Duration(seconds: 1));
      expect(_snapState?.isWaiting, true);
      expect(_snapState?.data, 'user0');
      //
      expect(_nextSnapState.hasData, true);
      expect(_nextSnapState.data, 'user1');
      //
      expect(user.state, 'user100');
    },
  );

  // testWidgets(
  //   'call refresh on persited signed user',
  //   (tester) async {
  //     store.store = {
  //       '__user__': 'Persisted user',
  //     };
  //     await tester.pumpWidget(widget);
  //     expect(find.text('Waiting...'), findsOneWidget);
  //     await tester.pumpAndSettle();
  //     expect(find.text('HomePage: Persisted user'), findsOneWidget);
  //     user.refresh();
  //     await tester.pump();
  //   },
  // );

  // testWidgets('Refresh signed user', (tester) async {
  //   await tester.pumpWidget(widget);
  //   expect(user.state, 'user0');
  //   await tester.pump();
  //   expect(onUnSigned, 1);
  //   expect(onSigned, 0);
  //   user.auth.signIn((_) => '1');
  //   await tester.pump(Duration(seconds: 1));
  //   expect(user.state, 'user1');
  //   expect(onUnSigned, 1);
  //   expect(onSigned, 1);
  //   user.refresh();
  //   await tester.pump();
  // });
}
