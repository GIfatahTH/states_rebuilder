import 'package:clean_architecture_firebase_login/data_source/fake_user_repository.dart';

import 'package:clean_architecture_firebase_login/domain/entities/user.dart';
import 'package:clean_architecture_firebase_login/ui/pages/home_page/home_page.dart';
import 'package:clean_architecture_firebase_login/ui/pages/sign_in_page/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'exceptions/exception_handler.dart';

final user = RM.injectAuth(
  () => FakeUserRepository(),
  unsignedUser: UnLoggedUser(),
  onSigned: (_) => RM.navigate.toReplacement(HomePage()),
  onUnsigned: () => RM.navigate.toReplacement(SignInPage()),
  onSetState: On.error(
    (err) => AlertDialog(
      title: Text(ExceptionsHandler.errorMessage(err).title),
      content: Text(ExceptionsHandler.errorMessage(err).message),
    ),
  ),
);