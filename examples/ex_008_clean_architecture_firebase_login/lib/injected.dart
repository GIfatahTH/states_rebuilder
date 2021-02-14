import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/fake_user_repository.dart';
import 'data_source/user_repository.dart';
import 'domain/entities/user.dart';
import 'infrastructure/apple_sign_in_available.dart';
import 'service/exceptions/exception_handler.dart';
import 'ui/pages/home_page/home_page.dart';
import 'ui/pages/sign_in_page/sign_in_page.dart';

enum Env { dev, prod }
Env currentEnv = Env.dev;

final InjectedAuth<User, UserParam> user = RM.injectAuth<User, UserParam>(
  () {
    assert(currentEnv != null);
    return {
      Env.dev: FakeUserRepository(),
      Env.prod: UserRepository(),
    }[currentEnv];
  },
  unsignedUser: UnLoggedUser(),
  onAuthStream: (repo) => (repo as UserRepository).currentUser().asStream(),
  onSetState: On.error(
    (err, refresh) => RM.navigate.to(
      AlertDialog(
        title: Text(ExceptionsHandler.errorMessage(err).title),
        content: Text(ExceptionsHandler.errorMessage(err).message),
      ),
    ),
  ),
  debugPrintWhenNotifiedPreMessage: '',
);

final canSignInWithApple = RM.injectFuture(
  () => {
    Env.dev: FakeAppleSignInChecker().check(),
    Env.prod: AppleSignInChecker().check(),
  }[currentEnv],
  autoDisposeWhenNotUsed: false,
);
