part of 'injected_auth.dart';

///Interface to implement for authentication and authorization
///
///
///The first generic type is the user.
///
///the second generic type is for the query parameter
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

  ///It is called when the injected model is disposed
  ///
  ///This is the right place for cleaning resources.
  void dispose();
}
