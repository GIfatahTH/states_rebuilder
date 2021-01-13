import 'package:clean_architecture_firebase_login/domain/entities/user.dart';
import 'package:clean_architecture_firebase_login/service/exceptions/sign_in_out_exception.dart';
import 'package:clean_architecture_firebase_login/service/interfaces/i_user_repository.dart';

class FakeUserRepository implements IUserRepository {
  final dynamic error;

  FakeUserRepository({this.error});

  @override
  Future<User> currentUser() async {
    await Future.delayed(Duration(seconds: 2));
    return UnLoggedUser();
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  @override
  Future<User> signInWithApple() async {
    await Future.delayed(Duration(seconds: 1));
    return _user;
  }

  @override
  Future<User> signInWithGoogle() async {
    await Future.delayed(Duration(seconds: 1));
    return _user;
  }

  @override
  Future<User> signInAnonymously() async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    return _user;
  }

  @override
  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    return User(uid: '1', email: email);
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    throw SignInException(
      title: 'Sign in with email and password',
    );
    return User(uid: '1', email: email);
  }

  User _user = User(
    uid: '1',
    displayName: "FakeUserDisplayName",
    email: 'fake@email.com',
  );
}
