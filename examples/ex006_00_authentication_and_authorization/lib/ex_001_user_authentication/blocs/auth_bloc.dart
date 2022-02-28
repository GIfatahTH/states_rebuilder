import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/scr/development_booster/development_booster.dart';
import 'package:states_rebuilder/scr/state_management/rm.dart';

import '../common/global.dart';
import '../data_source/fake_user_repository.dart';
import '../data_source/fire_base_auth_repository.dart';
import '../models/sign_in_out_exception.dart';
import '../models/user.dart';

@immutable
class AuthBloc {
  final _authRM = RM.injectAuth<User?, AuthParam>(
    // () => FireBaseAuthRepository(),
    () => FakeAuthRepository(),
    onAuthStream: (repo) => (repo as FireBaseAuthRepository).currentUser(),
    sideEffects: SideEffects.onError(
      (err, refresh) {
        if (err is EmailException || err is PasswordException) {
          return;
        }
        showDialog(
          context: navigationKey.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: Text(err.title!),
              content: Text(err.message!),
            );
          },
        );
        // In case you used the builtin navigatorKey
        // RM.navigate.toDialog(
        //   AlertDialog(
        //     title: Text(err.title!),
        //     content: Text(err.message!),
        //   ),
        // );
      },
    ),
  );
  InjectedAuth call() => _authRM;
  User get user => _authRM.state!;
  bool get isUserAuthenticated => _authRM.isSigned;
  bool get isWaiting => _authRM.isWaiting;
  AuthException get error => _authRM.error;
  Future<User?> register(AuthParam authParam) {
    return _authRM.auth.signUp((param) => authParam);
  }

  Future<User?> login(AuthParam authParam) {
    return _authRM.auth.signIn((param) => authParam);
  }

  void logout() {
    _authRM.auth.signOut();
  }
}

final authBloc = AuthBloc();
