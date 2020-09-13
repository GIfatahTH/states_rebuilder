import 'package:clean_architecture_firebase_login/domain/entities/user.dart';
import 'package:clean_architecture_firebase_login/service/user_service.dart';

class FakeUserService extends UserService {
  User fakeUser;

  var error;

  @override
  Future<void> currentUser() async {
    await Future.delayed(Duration(seconds: 2));
    user = fakeUser;
  }

  @override
  void signOut() async {
    await Future.delayed(Duration(seconds: 1));
    user = null;
  }

  @override
  void signInWithApple() async {
    await Future.delayed(Duration(seconds: 1));
    user = _user;
  }

  @override
  void signInWithGoogle() async {
    await Future.delayed(Duration(seconds: 1));
    user = _user;
  }

  @override
  void signInAnonymously() async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    user = _user;
  }

  void createUserWithEmailAndPassword(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    user = User(uid: '1', email: email);
  }

  void signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    user = User(uid: '1', email: email);
  }

  User _user = User(
    uid: '1',
    displayName: "FakeUserDisplayName",
    email: 'fake@email.com',
  );
}
