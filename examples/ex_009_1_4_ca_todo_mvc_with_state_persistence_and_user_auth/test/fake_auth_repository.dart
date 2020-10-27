import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/common/extensions.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/entities/user.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/value_object/token.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/service/interfaces/i_auth_repository.dart';

class FakeAuthRepository extends IAuthRepository {
  dynamic exception;

  @override
  Future<User> signUp(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    return User(
      userId: 'Id_$email',
      email: email,
      token: Token(
        token: 'token_$email',
        expiryDate: DateTimeX.current.add(
          Duration(seconds: 10),
        ),
      ),
    );
  }

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    return User(
      userId: 'Id_$email',
      email: email,
      token: Token(
        token: 'token_$email',
        expiryDate: DateTimeX.current.add(
          Duration(seconds: 10),
        ),
      ),
    );
  }

  @override
  Future<void> logout() async {
    if (exception != null) {
      throw exception;
    }
  }
}
