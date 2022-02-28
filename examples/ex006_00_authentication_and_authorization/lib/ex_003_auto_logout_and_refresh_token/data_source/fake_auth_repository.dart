import 'dart:convert';
import 'dart:math';

import '../common/extensions.dart';
import '../models/token.dart';
import '../models/user.dart';
import 'firebase_auth_repository.dart';

class FakeAuthRepository implements FireBaseAuthRepository {
  final bool shouldRefreshToken;
  FakeAuthRepository({this.shouldRefreshToken = false});

  String get randomString =>
      base64UrlEncode(List<int>.generate(20, (i) => Random().nextInt(255)));

  User? _user;

  @override
  void dispose() {}

  @override
  Future<void> init() async {}
  @override
  Future<User?> signUp(AuthParam? param) async {
    await Future.delayed(const Duration(seconds: 1));
    return _user = User(
      userId: '1',
      email: param!.email,
      token: Token(
        token: randomString,
        refreshToken: randomString,
        expiryDate: DateTimeX.current.add(
          const Duration(seconds: 10),
        ),
      ),
    );
  }

  @override
  Future<User?> signIn(AuthParam? param) async {
    await Future.delayed(const Duration(seconds: 1));
    return _user = User(
      userId: '1',
      email: param!.email,
      token: Token(
        token: randomString,
        refreshToken: randomString,
        expiryDate: DateTimeX.current.add(
          const Duration(seconds: 10),
        ),
      ),
    );
  }

  @override
  Future<void> signOut(AuthParam? param) async {
    _user = null;
  }

  @override
  Future<User?>? refreshToken(User? currentUser) async {
    if (!shouldRefreshToken || _user == null) return null;
    await Future.delayed(const Duration(seconds: 1));
    return User(
      userId: _user!.userId,
      email: _user!.email,
      token: Token(
        token: randomString,
        refreshToken: randomString,
        expiryDate: DateTimeX.current.add(
          const Duration(seconds: 20),
        ),
      ),
    );
  }
}
