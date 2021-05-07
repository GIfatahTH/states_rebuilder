import 'package:clean_architecture_firebase_login/service/exceptions/sign_in_out_exception.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/fake_user_repository.dart';
import 'data_source/user_repository.dart';
import 'domain/entities/user.dart';
import 'infrastructure/apple_sign_in_available.dart';
import 'service/exceptions/exception_handler.dart';

enum Env { dev, prod }
Env currentEnv = Env.dev;

final InjectedAuth<User?, UserParam> user = RM.injectAuth<User?, UserParam>(
  () {
    return {
      //TODO: Uncomment the exception line below to see an example of server validation
      Env.dev: () => FakeUserRepository(
          // exception: PasswordException('Invalid password'),
          ),
      Env.prod: () => UserRepository(),
    }[currentEnv]!();
  },
  onAuthStream: (repo) => (repo as UserRepository).currentUser().asStream(),
  onSetState: On.error(
    (err, refresh) {
      if (err is EmailException || err is PasswordException) {
        return;
      }
      RM.navigate.to(
        AlertDialog(
          title: Text(ExceptionsHandler.errorMessage(err).title!),
          content: Text(ExceptionsHandler.errorMessage(err).message!),
        ),
      );
    },
  ),
);

final canSignInWithApple = RM.injectFuture(
  () => {
    Env.dev: FakeAppleSignInChecker().check(),
    Env.prod: AppleSignInChecker().check(),
  }[currentEnv]!,
  initialState: false,
  autoDisposeWhenNotUsed: false,
);
