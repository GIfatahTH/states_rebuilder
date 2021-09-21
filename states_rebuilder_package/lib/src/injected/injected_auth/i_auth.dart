part of 'injected_auth.dart';

/// Interface to implement for authentication and authorization
///
///
/// The first generic type is the user.
///
/// the second generic type is for the query parameter
///
/// This is an example:
/// ```dart
/// class UserParam {
///   final String email;
///   final String password;
///   final SignIn signIn;
///   final SignUp signUp;
///   UserParam({
///     this.email,
///     this.password,
///     this.signIn,
///     this.signUp,
///   });
/// }
///
/// enum SignIn {
///   anonymously,
///   withApple,
///   withGoogle,
///   withEmailAndPassword,
///   currentUser,
/// }
/// enum SignUp { withEmailAndPassword }
///
///
/// class UserRepository implements IAuth<User, UserParam> {
///   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
///   final GoogleSignIn _googleSignIn = GoogleSignIn();
///
///   @override
///   Future<void> init() async {}
///
///   @override
///   Future<User> signUp(UserParam param) {
///     switch (param.signUp) {
///       case SignUp.withEmailAndPassword:
///         return _createUserWithEmailAndPassword(
///           param.email,
///           param.password,
///         );
///       default:
///         throw UnimplementedError();
///     }
///   }
///
///   @override
///   Future<User> signIn(UserParam param) {
///     switch (param.signIn) {
///       case SignIn.anonymously:
///         return _signInAnonymously();
///       case SignIn.withApple:
///         return _signInWithApple();
///       case SignIn.withGoogle:
///         return _signInWithGoogle();
///       case SignIn.withEmailAndPassword:
///         return _signInWithEmailAndPassword(
///           param.email,
///           param.password,
///         );
///       case SignIn.currentUser:
///         return _currentUser();
///
///       default:
///         throw UnimplementedError();
///     }
///   }
///
///   @override
///   Future<void> signOut(UserParam param) async {
///     final GoogleSignIn googleSignIn = GoogleSignIn();
///     await googleSignIn.signOut();
///     return _firebaseAuth.signOut();
///   }
///
///   @override
///   void dispose() {
///     // TODO: implement dispose
///   }
///
///   Future<User> _signInWithEmailAndPassword(
///     String email,
///     String password,
///   ) async {
///     try {
///       final AuthResult authResult =
///           await _firebaseAuth.signInWithEmailAndPassword(
///         email: email,
///         password: password,
///       );
///       return _fromFireBaseUserToUser(authResult.user);
///     } catch (e) {
///       if (e is PlatformException) {
///         throw SignInException(
///           title: 'Sign in with email and password',
///           code: e.code,
///           message: e.message,
///         );
///       } else {
///         rethrow;
///       }
///     }
///   }
///
///   Future<User> _createUserWithEmailAndPassword(
///     String email,
///     String password,
///   ) async {
///     try {
///       AuthResult authResult =
///           await _firebaseAuth.createUserWithEmailAndPassword(
///         email: email,
///         password: password,
///       );
///       return _fromFireBaseUserToUser(authResult.user);
///     } catch (e) {
///       if (e is PlatformException) {
///         throw SignInException(
///           title: 'Create use with email and password',
///           code: e.code,
///           message: e.message,
///         );
///       } else {
///         rethrow;
///       }
///     }
///   }
///
///     .
///     .
///     .
/// }
/// ```
abstract class IAuth<T, P> {
  ///It is called and awaited to finish when
  ///the state is first created
  ///
  ///Here is the right place to initialize plugins
  Future<void> init();

  ///Sign in
  Future<T> signIn(P? param);

  ///Sign up
  Future<T> signUp(P? param);

  ///Sign out
  Future<void> signOut(P? param);

  Future<T>? refreshToken(T currentUser) {}

  ///It is called when the injected model is disposed
  ///
  ///This is the right place for cleaning resources.
  void dispose();
}
