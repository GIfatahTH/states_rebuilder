import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../domain/entities/user.dart';
import '../service/exceptions/sign_in_out_exception.dart';

class UserRepository implements IAuth<User, UserParam> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<IAuth<User, UserParam>> init() async {
    return this;
  }

  @override
  Future<User> signUp(UserParam param) {
    switch (param.signUp) {
      case SignUp.withEmailAndPassword:
        return _createUserWithEmailAndPassword(
          param.email,
          param.password,
        );
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<User> signIn(UserParam param) {
    switch (param.signIn) {
      case SignIn.anonymously:
        return _signInAnonymously();
      case SignIn.withApple:
        return _signInWithApple();
      case SignIn.withGoogle:
        return _signInWithGoogle();
      case SignIn.withEmailAndPassword:
        return _signInWithEmailAndPassword(
          param.email,
          param.password,
        );

      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut(UserParam param) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
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

  Future<User> currentUser() async {
    final FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    return _fromFireBaseUserToUser(firebaseUser);
  }

  Future<User> _signInAnonymously() async {
    try {
      AuthResult authResult = await _firebaseAuth.signInAnonymously();
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw SignInException(
          title: 'Sign in anonymously',
          code: e.code,
          message: e.message,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<User> _signInWithGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw SignInException(
        title: 'Google sign in',
        code: '',
        message: 'Sign in with google is aborted',
      );
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final AuthResult authResult =
          (await _firebaseAuth.signInWithCredential(credential));
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw SignInException(
          title: 'Sign in with google',
          code: e.code,
          message: e.message,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<User> _signInWithApple() async {
    final AuthorizationResult result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider(providerId: 'apple.com');
        final credential = oAuthProvider.getCredential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );

        final authResult = await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = authResult.user;

        final updateUser = UserUpdateInfo();
        updateUser.displayName =
            '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';

        await firebaseUser.updateProfile(updateUser);
        return _fromFireBaseUserToUser(firebaseUser);

      case AuthorizationStatus.error:
        throw SignInException(
          title: 'Sing in with apple',
          code: result.error.code.toString(),
          message: result.error.localizedDescription,
        );
      case AuthorizationStatus.cancelled:
        throw SignInException(
          title: 'Sing in with apple',
          code: '',
          message: 'Sign in cancelled',
        );
    }
    return null;
  }

  Future<User> _signInWithEmailAndPassword(
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
        throw SignInException(
          title: 'Sign in with email and password',
          code: e.code,
          message: e.message,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<User> _createUserWithEmailAndPassword(
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
        throw SignInException(
          title: 'Create use with email and password',
          code: e.code,
          message: e.message,
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

// class UserRepository implements IUserRepository {
//   final FirebaseAuth _firebaseAuth;

//   final GoogleSignIn _googleSignIn;

//   UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignIn})
//       : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
//         _googleSignIn = googleSignIn ?? GoogleSignIn();

//   @override
//   Future<User> currentUser() async {
//     final FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
//     return _fromFireBaseUserToUser(firebaseUser);
//   }

//   @override
//   Future<User> signInAnonymously() async {
//     try {
//       AuthResult authResult = await _firebaseAuth.signInAnonymously();
//       return _fromFireBaseUserToUser(authResult.user);
//     } catch (e) {
//       if (e is PlatformException) {
//         throw SignInException(
//           title: 'Sign in anonymously',
//           code: e.code,
//           message: e.message,
//         );
//       } else {
//         rethrow;
//       }
//     }
//   }

//   @override
//   Future<User> signInWithGoogle() async {
//     GoogleSignInAccount googleUser = await _googleSignIn.signIn();

//     if (googleUser == null) {
//       throw SignInException(
//         title: 'Google sign in',
//         code: '',
//         message: 'Sign in with google is aborted',
//       );
//     }
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser.authentication;

//     final AuthCredential credential = GoogleAuthProvider.getCredential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     try {
//       final AuthResult authResult =
//           (await _firebaseAuth.signInWithCredential(credential));
//       return _fromFireBaseUserToUser(authResult.user);
//     } catch (e) {
//       if (e is PlatformException) {
//         throw SignInException(
//           title: 'Sign in with google',
//           code: e.code,
//           message: e.message,
//         );
//       } else {
//         rethrow;
//       }
//     }
//   }

//   @override
//   Future<User> signInWithApple() async {
//     final AuthorizationResult result = await AppleSignIn.performRequests([
//       AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
//     ]);

//     switch (result.status) {
//       case AuthorizationStatus.authorized:
//         final appleIdCredential = result.credential;
//         final oAuthProvider = OAuthProvider(providerId: 'apple.com');
//         final credential = oAuthProvider.getCredential(
//           idToken: String.fromCharCodes(appleIdCredential.identityToken),
//           accessToken:
//               String.fromCharCodes(appleIdCredential.authorizationCode),
//         );

//         final authResult = await _firebaseAuth.signInWithCredential(credential);
//         final firebaseUser = authResult.user;

//         final updateUser = UserUpdateInfo();
//         updateUser.displayName =
//             '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';

//         await firebaseUser.updateProfile(updateUser);
//         return _fromFireBaseUserToUser(firebaseUser);

//       case AuthorizationStatus.error:
//         throw SignInException(
//           title: 'Sing in with apple',
//           code: result.error.code.toString(),
//           message: result.error.localizedDescription,
//         );
//       case AuthorizationStatus.cancelled:
//         throw SignInException(
//           title: 'Sing in with apple',
//           code: '',
//           message: 'Sign in cancelled',
//         );
//     }
//     return null;
//   }

//   @override
//   Future<User> createUserWithEmailAndPassword(
//     String email,
//     String password,
//   ) async {
//     try {
//       AuthResult authResult =
//           await _firebaseAuth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return _fromFireBaseUserToUser(authResult.user);
//     } catch (e) {
//       if (e is PlatformException) {
//         throw SignInException(
//           title: 'Create use with email and password',
//           code: e.code,
//           message: e.message,
//         );
//       } else {
//         rethrow;
//       }
//     }
//   }

//   @override
//   Future<User> signInWithEmailAndPassword(
//     String email,
//     String password,
//   ) async {
//     try {
//       final AuthResult authResult =
//           await _firebaseAuth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return _fromFireBaseUserToUser(authResult.user);
//     } catch (e) {
//       if (e is PlatformException) {
//         throw SignInException(
//           title: 'Sign in with email and password',
//           code: e.code,
//           message: e.message,
//         );
//       } else {
//         rethrow;
//       }
//     }
//   }

//   @override
//   Future<void> signOut() async {
//     final GoogleSignIn googleSignIn = GoogleSignIn();
//     await googleSignIn.signOut();
//     return _firebaseAuth.signOut();
//   }

//   _fromFireBaseUserToUser(FirebaseUser user) {
//     if (user == null) {
//       return null;
//     }
//     return User(
//       uid: user.uid,
//       email: user.email,
//       displayName: user.displayName,
//       photoUrl: user.photoUrl,
//     );
//   }
// }
