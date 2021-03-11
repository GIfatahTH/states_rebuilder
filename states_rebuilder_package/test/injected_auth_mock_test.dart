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
);

void main() async {
  final store = await RM.storageInitializerMock();
  user.injectAuthMock(() => FakeAuthRepo());
  setUp(() {
    RM.disposeAll();
    store.clear();
    disposeMessage = '';
    onUnSigned = 0;
    onSigned = 0;
  });
  testWidgets('sign with unsigned unsigned user', (tester) async {
    expect(user.state, 'user0');
    await tester.pump();
    //

    //
    user.auth.signIn((_) => '3');
    expect(user.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(user.hasData, true);
    expect(user.state, 'user0');
    expect(user.isSigned, false);
    //
    expect(disposeMessage, '');
    user.dispose();
    await tester.pump();
    expect(disposeMessage, 'isDisposed');
  });
  testWidgets('Sign with signed user', (tester) async {
    expect(user.state, 'user0');
    await tester.pump();

    user.auth.signIn((_) => '1');
    await tester.pump(Duration(seconds: 1));
    expect(user.state, 'user1');
    expect(user.isSigned, true);
  });

  testWidgets('Sign up a user', (tester) async {
    expect(user.state, 'user0');
    await tester.pump();

    user.auth.signUp((_) => '2');
    await tester.pump(Duration(seconds: 1));
    expect(user.state, 'user2');
  });

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
}
