import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../models/sign_in_out_exception.dart';
import '../models/user.dart';

class FireBaseAuthRepository extends IAuth<User?, AuthParam> {
  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<User?> signUp(AuthParam? param) {
    switch (param!.signUp) {
      case SignUp.withEmailAndPassword:
        return _createUserWithEmailAndPassword(
          param.email!,
          param.password!,
        );
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<User?> signIn(AuthParam? param) {
    switch (param!.signIn) {
      case SignIn.anonymously:
        return _signInAnonymously();
      case SignIn.withApple:
        return _signInWithApple();
      case SignIn.withGoogle:
        return _signInWithGoogle();
      case SignIn.withEmailAndPassword:
        return _signInWithEmailAndPassword(
          param.email!,
          param.password!,
        );

      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut(AuthParam? param) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    return _firebaseAuth.signOut();
  }

  User? _fromFireBaseUserToUser(firebase.User? user) {
    if (user == null) {
      return null;
    }
    return User(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Stream<User?> currentUser() {
    return _firebaseAuth.authStateChanges().map(
          (user) => _fromFireBaseUserToUser(user),
        );
  }

  Future<User?> _signInAnonymously() async {
    try {
      firebase.UserCredential authResult =
          await _firebaseAuth.signInAnonymously();
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw AuthException(
          title: 'Sign in anonymously',
          code: e.code,
          message: e.message,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<User?> _signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw AuthException(
        title: 'Google sign in',
        code: '',
        message: 'Sign in with google is aborted',
      );
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final firebase.AuthCredential credential =
        firebase.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final firebase.UserCredential authResult =
          (await _firebaseAuth.signInWithCredential(credential));
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw AuthException(
          title: 'Sign in with google',
          code: e.code,
          message: e.message,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<User?> _signInWithApple() async {
    // final AuthorizationResult result = await AppleSignIn.performRequests([
    //   AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    // ]);

    // switch (result.status) {
    //   case AuthorizationStatus.authorized:
    //     final appleIdCredential = result.credential;
    //     final oAuthProvider = firebase.OAuthProvider('apple.com');
    //     final credential = oAuthProvider.credential(
    //       idToken: String.fromCharCodes(appleIdCredential.identityToken),
    //       accessToken:
    //           String.fromCharCodes(appleIdCredential.authorizationCode),
    //     );

    //     final authResult = await _firebaseAuth.signInWithCredential(credential);
    //     final firebaseUser = authResult.user;

    //     final displayName =
    //         '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';

    //     await firebaseUser?.updateProfile(displayName: displayName);
    //     return _fromFireBaseUserToUser(firebaseUser);

    //   case AuthorizationStatus.error:
    //     throw AuthException(
    //       title: 'Sing in with apple',
    //       code: result.error.code.toString(),
    //       message: result.error.localizedDescription,
    //     );
    //   case AuthorizationStatus.cancelled:
    //     throw AuthException(
    //       title: 'Sing in with apple',
    //       code: '',
    //       message: 'Sign in cancelled',
    //     );
    // }
    return null;
  }

  Future<User?> _signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final firebase.UserCredential authResult =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is firebase.FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            throw EmailException('Email address is not valid');
          case 'user-disabled':
            throw EmailException(
                'User corresponding to the given email has been disabled');
          case 'user-not-found':
            throw EmailException(
                'There is no user corresponding to the given email');
          case 'wrong-password':
            throw PasswordException('Password is invalid for the given email');
          default:
            throw AuthException(
              title: 'Create use with email and password',
              code: e.code,
              message: e.message,
            );
        }
      }
      rethrow;
    }
  }

  Future<User?> _createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      firebase.UserCredential authResult =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is firebase.FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            throw EmailException('Email address is not valid');
          case 'email-already-in-use':
            throw EmailException(
                'There already exists an account with the given email');
          case 'weak-password':
            throw EmailException(
                'There is no user corresponding to the given email');
          case 'wrong-password':
            throw PasswordException('Password is not strong enough');
          default:
            throw AuthException(
              title: 'Create use with email and password',
              code: e.code,
              message: e.message,
            );
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> init() async {}

  @override
  void dispose() {}

  @override
  Future<User?>? refreshToken(User? currentUser) {
    throw UnimplementedError();
  }
}
