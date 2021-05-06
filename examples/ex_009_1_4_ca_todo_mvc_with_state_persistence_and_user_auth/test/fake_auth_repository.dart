import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/data_source/firebase_auth_repository.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/common/extensions.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/entities/user.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/value_object/token.dart';

class FakeAuthRepository implements FireBaseAuth {
  dynamic exception;

  @override
  Future<void> init() async {}

  @override
  Future<User?> signUp(UserParam? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    return User(
      userId: 'Id_${param!.email}',
      email: param.email,
      token: Token(
        token: 'token_${param.email}',
        expiryDate: DateTimeX.current.add(
          Duration(seconds: 10),
        ),
      ),
    );
  }

  @override
  Future<User> signIn(UserParam? param) async {
    await Future.delayed(Duration(seconds: 1));
    if (exception != null) {
      throw exception;
    }
    return User(
      userId: 'Id_${param!.email}',
      email: param.email,
      token: Token(
        token: 'token_${param.email}',
        expiryDate: DateTimeX.current.add(
          Duration(seconds: 10),
        ),
      ),
    );
  }

  @override
  Future<void> signOut(UserParam? param) async {
    if (exception != null) {
      throw exception;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

// class FakeAuthRepository extends IAuthRepository {
//   dynamic exception;

//   @override
//   Future<User> signUp(String email, String password) async {
//     await Future.delayed(Duration(seconds: 1));
//     if (exception != null) {
//       throw exception;
//     }
//     return User(
//       userId: 'Id_$email',
//       email: email,
//       token: Token(
//         token: 'token_$email',
//         expiryDate: DateTimeX.current.add(
//           Duration(seconds: 10),
//         ),
//       ),
//     );
//   }

//   @override
//   Future<User> login(String email, String password) async {
//     await Future.delayed(Duration(seconds: 1));
//     if (exception != null) {
//       throw exception;
//     }
//     return User(
//       userId: 'Id_$email',
//       email: email,
//       token: Token(
//         token: 'token_$email',
//         expiryDate: DateTimeX.current.add(
//           Duration(seconds: 10),
//         ),
//       ),
//     );
//   }

//   @override
//   Future<void> logout() async {
//     if (exception != null) {
//       throw exception;
//     }
//   }
// }
