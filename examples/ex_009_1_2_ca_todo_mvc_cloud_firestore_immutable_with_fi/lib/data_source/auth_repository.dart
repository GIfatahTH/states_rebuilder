import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../domain/entities/user.dart';
import '../service/exceptions/persistance_exception.dart';
import '../service/interfaces/i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User> currentUser() async {
    final FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    return _fromFireBaseUserToUser(firebaseUser);
  }

  @override
  Future<User> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      AuthResult authResult =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw PersistanceException(e.message);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final AuthResult authResult =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw PersistanceException(e.message);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  _fromFireBaseUserToUser(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return User(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }
}
