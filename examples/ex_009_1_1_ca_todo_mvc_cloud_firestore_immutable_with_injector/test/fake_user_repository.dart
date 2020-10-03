import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/domain/entities/user.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/service/interfaces/i_auth_repository.dart';

class AuthRepository extends IAuthRepository {
  @override
  Future<User> createUserWithEmailAndPassword(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<User> currentUser() {
    return Future.value(
      User(
        uid: '1',
        displayName: 'user1',
        email: 'user1@email',
      ),
    );
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }
}
