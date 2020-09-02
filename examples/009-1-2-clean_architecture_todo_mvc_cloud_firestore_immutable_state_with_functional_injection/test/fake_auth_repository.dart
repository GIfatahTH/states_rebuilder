import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/domain/entities/user.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/service/interfaces/i_auth_repository.dart';

class FakeAuthRepository implements IAuthRepository {
  User _user;
  final String fakeUidToFetch;

  FakeAuthRepository({this.fakeUidToFetch = '1', User currentUser})
      : _user = currentUser;
  @override
  Future<User> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future.delayed(Duration(seconds: 1));
    return _user = User(
      uid: fakeUidToFetch,
      displayName: email,
      email: password,
    );
  }

  @override
  Future<User> currentUser() =>
      Future.delayed(Duration(seconds: 1), () => _user);

  @override
  Future<User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future.delayed(Duration(seconds: 1));
    return _user = User(
      uid: fakeUidToFetch,
      displayName: email,
      email: password,
    );
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(Duration(seconds: 1));
    _user = null;
  }
}
