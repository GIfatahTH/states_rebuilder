import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

bool _shouldRefreshToken = true;
final user = RM.injectAuth<User?, String>(
  () => Repository(),
  persist: () => PersistState(
    key: '_key_',
    fromJson: (json) => User.fromJson(json),
    toJson: (s) => s?.toJson() ?? '',
  ),
  autoRefreshTokenOrSignOut: (user) => user!.tokenExpiration,
);

void main() async {
  final store = await RM.storageInitializerMock();
  setUp(() {
    _shouldRefreshToken = true;
    _refreshTokenIsExpired = false;
    store.clear();
    user.dispose();
  });
  testWidgets(
    'WHEN autoSignOut is defined'
    'AND WHEN token expires'
    'THEN the token is refreshed',
    (tester) async {
      await tester.pumpWidget(_App());
      expect(user.isSigned, false);
      expect(find.text('UnSigned'), findsOneWidget);
      //
      user.auth.signIn(null);
      await tester.pump();
      expect(user.isSigned, true);
      expect(user.state?.token, 'token');
      expect(find.text('Signed'), findsOneWidget);
      //
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      expect(user.state?.token, 'token');
      expect(find.text('Signed'), findsOneWidget);
      //
      await tester.pump(Duration(seconds: 1));
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      expect(user.state?.token, 'new token');
      expect(find.text('Signed'), findsOneWidget);
      //
      _shouldRefreshToken = false;
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      expect(user.state?.token, 'new token');
      expect(find.text('Signed'), findsOneWidget);
      //
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, false);
      expect(find.text('UnSigned'), findsOneWidget);
      //
    },
  );

  testWidgets(
    'WHEN use is persisted with valid token'
    'THEN it will be use and refreshed',
    (tester) async {
      //
      store.store = {
        '_key_': User(
          id: 'id',
          token: 'token',
          tokenExpiration: Duration(seconds: 2),
          refreshToken: 'refreshToken',
        ).toJson(),
      };

      await tester.pumpWidget(_App());
      await tester.pump();
      expect(user.isSigned, true);
      expect(user.state?.token, 'token');
      expect(find.text('Signed'), findsOneWidget);
      //
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      expect(user.state?.token, 'token');
      expect(find.text('Signed'), findsOneWidget);
      //
      await tester.pump(Duration(seconds: 1));
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      expect(user.state?.token, 'new token');
      expect(find.text('Signed'), findsOneWidget);
      //
      _shouldRefreshToken = false;
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      expect(user.state?.token, 'new token');
      expect(find.text('Signed'), findsOneWidget);
      //
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, false);
      expect(find.text('UnSigned'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN stored user has an expired token'
    'THEN on app starts the token is refreshed',
    (tester) async {
      store.store = {
        '_key_': User(
          id: 'id',
          token: 'token',
          tokenExpiration: Duration(seconds: -10),
          refreshToken: 'refreshToken',
        ).toJson(),
      };

      await tester.pumpWidget(_App());
      await tester.pump();
      expect(user.isSigned, true);
      expect(user.state?.token, 'token');
      expect(find.text('Signed'), findsOneWidget);
      //
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      expect(user.state?.token, 'new token');
      expect(find.text('Signed'), findsOneWidget);
      //
      await tester.pump(Duration(seconds: 1));
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      expect(user.state?.token, 'new token');
      expect(find.text('Signed'), findsOneWidget);
      //
      _shouldRefreshToken = false;
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, true);
      expect(user.state?.token, 'new token');
      expect(find.text('Signed'), findsOneWidget);
      //
      await tester.pump(Duration(seconds: 1));
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, false);
      expect(find.text('UnSigned'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN stored user has an expired token'
    'AND WHEN the refresh token is expired'
    'THEN the unsigned screen is displayed',
    (tester) async {
      store.store = {
        '_key_': User(
          id: 'id',
          token: 'token',
          tokenExpiration: Duration(seconds: -10),
          refreshToken: 'refreshToken',
        ).toJson(),
      };
      _refreshTokenIsExpired = true;
      await tester.pumpWidget(_App());
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      expect(user.isSigned, false);
      expect(find.text('UnSigned'), findsOneWidget);
      //
    },
  );
}

class _App extends StatelessWidget {
  const _App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OnAuthBuilder(
        listenTo: user,
        onUnsigned: () => Text('UnSigned'),
        onSigned: () => Text('Signed'),
      ),
    );
  }
}

bool _refreshTokenIsExpired = false;

class Repository extends IAuth<User?, String> {
  @override
  void dispose() {}

  @override
  Future<void> init() async {}

  @override
  Future<User?> signIn(String? param) async {
    return User(
      id: 'id',
      token: 'token',
      tokenExpiration: Duration(seconds: 2),
      refreshToken: 'refreshToken',
    );
  }

  @override
  Future<void> signOut(String? param) async {}

  @override
  Future<User?> signUp(String? param) async {
    return User(
      id: 'id',
      token: 'token',
      tokenExpiration: Duration(seconds: 2),
      refreshToken: 'refreshToken',
    );
  }

  @override
  Future<User?>? refreshToken(User? currentUser) async {
    if (!_shouldRefreshToken) {
      return null;
    }
    await Future.delayed(Duration(seconds: 1));
    if (_refreshTokenIsExpired) {
      return null;
    }

    return currentUser!.copyWith(
      token: 'new token',
      refreshToken: 'new refreshToken',
      tokenExpiration: Duration(seconds: 2),
    );
  }
}

class User {
  final String id;
  final String token;
  final Duration tokenExpiration;
  final String refreshToken;
  User({
    required this.id,
    required this.token,
    required this.tokenExpiration,
    required this.refreshToken,
  });

  User copyWith({
    String? id,
    String? token,
    Duration? tokenExpiration,
    String? refreshToken,
  }) {
    return User(
      id: id ?? this.id,
      token: token ?? this.token,
      tokenExpiration: tokenExpiration ?? this.tokenExpiration,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'tokenExpiration': tokenExpiration.inSeconds,
      'refreshToken': refreshToken,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      token: map['token'],
      tokenExpiration: Duration(seconds: map['tokenExpiration']),
      refreshToken: map['refreshToken'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
