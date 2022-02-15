import 'package:flutter/material.dart';
import 'package:states_rebuilder/scr/development_booster/development_booster.dart';
import 'package:states_rebuilder/scr/state_management/rm.dart';

import '../data_source/fake_user_repository.dart';
import '../data_source/fire_base_auth_repository.dart';
import '../models/sign_in_out_exception.dart';
import '../models/user.dart';
import '../navigator.dart';

@immutable
class AuthBloc {
  final _authRM = RM.injectAuth<User?, AuthParam>(
    // () => FireBaseAuthRepository(),
    () => FakeAuthRepository(),
    onAuthStream: (repo) => (repo as FireBaseAuthRepository).currentUser(),
    onSigned: (_) {
      navigator.onNavigate();
    },
    onUnsigned: () {
      navigator.onNavigate();
    },
    sideEffects: SideEffects.onError(
      (err, refresh) {
        if (err is EmailException || err is PasswordException) {
          return;
        }
        // In case you used the builtin navigatorKey
        RM.navigate.toDialog(
          AlertDialog(
            title: Text(err.title!),
            content: Text(err.message!),
          ),
        );
      },
    ),
  );
  InjectedAuth call() => _authRM;
  User get user => _authRM.state!;
  bool get isUserAuthenticated => _authRM.isSigned;
  bool get isWaiting => _authRM.isWaiting;
  AuthException get error => _authRM.error;

  Future<void> init() async {
    await _authRM.initializeState();
  }

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
