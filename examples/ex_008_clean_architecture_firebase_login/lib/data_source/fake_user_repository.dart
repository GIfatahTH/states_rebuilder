import 'user_repository.dart';
import '../domain/entities/user.dart';
import '../service/exceptions/sign_in_out_exception.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class FakeUserRepository implements UserRepository {
  final dynamic error;
  User fakeUser;
  FakeUserRepository({this.error});

  @override
  Future<IAuth<User, UserParam>> init() async {
    return this;
  }

  @override
  Future<User> signUp(UserParam param) async {
    switch (param.signUp) {
      case SignUp.withEmailAndPassword:
        await Future.delayed(Duration(seconds: 1));
        if (error != null) {
          throw error;
        }
        return User(uid: '1', email: param.email);
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<User> signIn(UserParam param) async {
    switch (param.signIn) {
      case SignIn.withEmailAndPassword:
        await Future.delayed(Duration(seconds: 1));
        if (error != null) {
          throw error;
        }
        throw SignInException(
          title: 'Sign in with email and password',
        );
        return User(uid: '1', email: param.email);
      case SignIn.anonymously:
      case SignIn.withApple:
      case SignIn.withGoogle:
        await Future.delayed(Duration(seconds: 1));
        if (error != null) {
          throw error;
        }
        return _user;
      case SignIn.currentUser:
        await Future.delayed(Duration(seconds: 2));
        return fakeUser ?? UnLoggedUser();

      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut(UserParam param) async {
    await Future.delayed(Duration(seconds: 1));
    return null;
  }

  @override
  void dispose() {}

  User _user = User(
    uid: '1',
    displayName: "FakeUserDisplayName",
    email: 'fake@email.com',
  );
}

// class FakeUserRepository implements IUserRepository {
//   final dynamic error;

//   FakeUserRepository({this.error});

//   @override
//   Future<User> currentUser() async {
//     await Future.delayed(Duration(seconds: 2));
//     return UnLoggedUser();
//   }

//   @override
//   Future<void> signOut() async {
//     await Future.delayed(Duration(seconds: 1));
//     return null;
//   }

//   @override
//   Future<User> signInWithApple() async {
//     await Future.delayed(Duration(seconds: 1));
//     return _user;
//   }

//   @override
//   Future<User> signInWithGoogle() async {
//     await Future.delayed(Duration(seconds: 1));
//     return _user;
//   }

//   @override
//   Future<User> signInAnonymously() async {
//     await Future.delayed(Duration(seconds: 1));
//     if (error != null) {
//       throw error;
//     }
//     return _user;
//   }

//   @override
//   Future<User> createUserWithEmailAndPassword(
//       String email, String password) async {
//     await Future.delayed(Duration(seconds: 1));
//     return User(uid: '1', email: email);
//   }

//   @override
//   Future<User> signInWithEmailAndPassword(String email, String password) async {
//     await Future.delayed(Duration(seconds: 1));
//     throw SignInException(
//       title: 'Sign in with email and password',
//     );
//     return User(uid: '1', email: email);
//   }

//   User _user = User(
//     uid: '1',
//     displayName: "FakeUserDisplayName",
//     email: 'fake@email.com',
//   );
// }
