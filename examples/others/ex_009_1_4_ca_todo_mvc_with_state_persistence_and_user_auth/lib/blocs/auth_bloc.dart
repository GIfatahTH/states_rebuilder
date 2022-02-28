import 'package:flutter/foundation.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../data_source/firebase_auth_repository.dart';
import '../domain/common/extensions.dart';
import '../domain/entities/user.dart';
import '../ui/exceptions/error_handler.dart';
import 'exceptions/auth_exception.dart';

@immutable
class AuthBloc {
  final userRM = RM.injectAuth<User?, UserParam>(
    () => FireBaseAuth(),
    persist: () => PersistState<User?>(
      key: '__UserToken__',
      toJson: (user) => user!.toJson(),
      fromJson: (json) {
        final user = User.fromJson(json);
        return user;
        // return user.token.isAuth == true ? user : null;
      },
      // debugPrintOperations: true,
    ),
    autoRefreshTokenOrSignOut: (user) {
      final timeToExpiry = user!.token.expiryDate!
          .difference(
            DateTimeX.current,
          )
          .inSeconds;
      return Duration(seconds: timeToExpiry);
    },
    sideEffects: SideEffects.onError(
      (e, r) {
        if (e is AuthException) {
          ErrorHandler.showErrorSnackBar(e);
        }
        throw e;
      },
    ),
    // debugPrintWhenNotifiedPreMessage: '',
  );
  User? get user => userRM.state;
  dynamic get authError => userRM.error;

  Future<User?> signUp(String email, String password) {
    return userRM.auth.signUp(
      (_) => UserParam(email: email, password: password),
    );
  }

  Future<User?> signIn(String email, String password) {
    return userRM.auth.signIn(
      (_) => UserParam(email: email, password: password),
    );
  }

  Future<void> signOut() {
    return userRM.auth.signOut();
  }

  Future<User?> refreshToken() {
    return userRM.auth.refreshToken();
  }
}

final authBloc = AuthBloc();
