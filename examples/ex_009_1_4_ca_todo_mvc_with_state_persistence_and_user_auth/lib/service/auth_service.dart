import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/service/interfaces/i_auth_repository.dart';
import 'package:flutter/foundation.dart';

import '../domain/entities/user.dart';

class AuthService {
  final IAuthRepository authRepository;

  AuthService({@required this.authRepository});

  Future<User> signUp(String email, String password) async {
    return await authRepository.signUp(email, password);
  }

  Future<User> login(String email, String password) async {
    return await authRepository.login(email, password);
  }

  User logout() {
    authRepository.logout();
    return UnsignedUser();
  }
}
