import 'package:flutter/material.dart';
import 'package:states_rebuilder/scr/development_booster/development_booster.dart';
import 'package:states_rebuilder/scr/state_management/rm.dart';

import '../common/extensions.dart';
import '../data_source/fake_auth_repository.dart';
import '../models/user.dart';

@immutable
class AuthBloc {
  final _authRM = RM.injectAuth<User?, AuthParam>(
    // () => FireBaseAuthRepository(),
    // () => FakeAuthRepository(),
    () => FakeAuthRepository(shouldRefreshToken: true),
    persist: () => PersistState<User?>(
      key: '__authenticatedUser__',
      toJson: (user) => user!.toJson(),
      fromJson: (json) {
        final user = User.fromJson(json);
        return user;
      },
    ),
    autoRefreshTokenOrSignOut: (user) {
      final timeToExpiry = user!.token.expiryDate!
          .difference(
            DateTimeX.current,
          )
          .inSeconds;
      return Duration(seconds: timeToExpiry);
    },
  );
  InjectedAuth call() => _authRM;
  User get user => _authRM.state!;
  bool get isUserAuthenticated => _authRM.isSigned;
  bool get isWaiting => _authRM.isWaiting;
  dynamic get error => _authRM.error;
  Future<User?> register(String email, String password) {
    return _authRM.auth.signUp(
      (param) => AuthParam(email: email, password: password),
    );
  }

  Future<User?> login(String email, String password) {
    return _authRM.auth.signIn(
      (param) => AuthParam(email: email, password: password),
    );
  }

  void logout() {
    _authRM.auth.signOut();
  }
}

final authBloc = AuthBloc();
