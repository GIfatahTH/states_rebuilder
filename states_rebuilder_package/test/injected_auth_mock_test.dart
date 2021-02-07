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

  @override
  void dispose() {
    disposeMessage = 'isDisposed';
  }
}

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
}
