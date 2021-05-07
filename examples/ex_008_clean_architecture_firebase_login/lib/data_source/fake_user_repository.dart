import '../domain/entities/user.dart';
import 'user_repository.dart';

class FakeUserRepository implements UserRepository {
  final dynamic exception;
  User? fakeUser;
  FakeUserRepository({this.exception});

  @override
  Future<void> init() async {}

  @override
  Future<User> signUp(UserParam? param) async {
    switch (param!.signUp) {
      case SignUp.withEmailAndPassword:
        await Future.delayed(Duration(seconds: 1));
        if (exception != null) {
          throw exception;
        }
        return User(uid: '1', email: param.email);
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<User> signIn(UserParam? param) async {
    switch (param!.signIn) {
      case SignIn.withEmailAndPassword:
        await Future.delayed(Duration(seconds: 1));
        if (exception != null) {
          throw exception;
        }
        return User(uid: '1', email: param.email);
      case SignIn.anonymously:
      case SignIn.withApple:
      case SignIn.withGoogle:
        await Future.delayed(Duration(seconds: 1));
        if (exception != null) {
          throw exception;
        }
        return _user;
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut(UserParam? param) async {
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  //
  @override
  void dispose() {}
  //
  User _user = User(
    uid: '1',
    displayName: "FakeUserDisplayName",
    email: 'fake@email.com',
  );
  //
  @override
  Future<User?> currentUser() async {
    await Future.delayed(Duration(seconds: 2));
    return fakeUser;
  }
}
