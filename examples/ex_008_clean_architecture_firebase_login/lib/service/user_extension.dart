import 'package:clean_architecture_firebase_login/data_source/fake_user_repository.dart';
import 'package:clean_architecture_firebase_login/data_source/user_repository.dart';
import 'package:clean_architecture_firebase_login/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'exceptions/exception_handler.dart';

final userRepository = RM.inject(() => FakeUserRepository());
final user = RM.inject<User>(
  () => UnLoggedUser(),
  onSetState: On.error(
    (err) => AlertDialog(
      title: Text(ExceptionsHandler.errorMessage(err).title),
      content: Text(ExceptionsHandler.errorMessage(err).message),
    ),
  ),
  debugPrintWhenNotifiedPreMessage: '',
);

extension UserX on User {
  Future<User> currentUser() async {
    return await userRepository.state.currentUser();
  }

  Future<User> signInAnonymously() async {
    return userRepository.state.signInAnonymously();
  }

  Future<User> signInWithGoogle() async {
    return userRepository.state.signInWithGoogle();
  }

  Future<User> signInWithApple() async {
    return userRepository.state.signInWithApple();
  }

  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    return userRepository.state.createUserWithEmailAndPassword(email, password);
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    return userRepository.state.signInWithEmailAndPassword(email, password);
  }

  Future<User> signOut() async {
    userRepository.state.signOut();
    return UnLoggedUser();
  }
}
