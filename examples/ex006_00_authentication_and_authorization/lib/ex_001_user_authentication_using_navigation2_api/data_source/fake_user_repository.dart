import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../models/user.dart';
import 'fire_base_auth_repository.dart';

class FakeAuthRepository implements FireBaseAuthRepository {
  final dynamic exception;
  User? fakeUser;
  FakeAuthRepository({this.exception}) {
    Future.delayed(const Duration(seconds: 2), () => sink.add(fakeUser));
  }

  @override
  Future<void> init() async {}

  @override
  Future<User> signUp(AuthParam? param) async {
    switch (param!.signUp) {
      case SignUp.withEmailAndPassword:
        await Future.delayed(const Duration(seconds: 1));
        if (exception != null) {
          throw exception;
        }
        return User(uid: '1', email: param.email);
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<User> signIn(AuthParam? param) async {
    switch (param!.signIn) {
      case SignIn.withEmailAndPassword:
        await Future.delayed(const Duration(seconds: 1));
        if (exception != null) {
          throw exception;
        }
        return User(uid: '1', email: param.email);
      case SignIn.anonymously:
      case SignIn.withApple:
      case SignIn.withGoogle:
        await Future.delayed(const Duration(seconds: 1));
        if (exception != null) {
          throw exception;
        }
        return _user;
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut(AuthParam? param) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  //
  final _user = User(
    uid: '1',
    displayName: "FakeUserDisplayName",
    email: 'fake@email.com',
  );
  //
  @override
  Stream<User?> currentUser() {
    return _controller.stream;
  }

  @visibleForTesting
  StreamSink<User?> get sink => _controller.sink;

  final _controller = StreamController<User?>();

  @override
  Future<User?>? refreshToken(User? currentUser) async {
    return null;
  }

  //
  @override
  void dispose() {
    _controller.close();
  }
}
