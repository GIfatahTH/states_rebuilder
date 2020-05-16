import 'package:flutter/foundation.dart';

import '../domain/entities/user.dart';
import 'interfaces/i_auth_repository.dart';

@immutable
class AuthState {
  final IAuthRepository _authRepository;
  final User user;
  AuthState({
    @required IAuthRepository authRepository,
    @required this.user,
  }) : _authRepository = authRepository;

  static Future<AuthState> currentUser(AuthState authState) async {
    final currentUser = await authState._authRepository.currentUser();
    if (currentUser != null) {
      return authState.copyWith(
        user: currentUser,
      );
    }
    return InitAuthState(authState._authRepository);
  }

  static Future<AuthState> createUserWithEmailAndPassword(
    AuthState authState,
    String email,
    String password,
  ) async {
    final user = await authState._authRepository.createUserWithEmailAndPassword(
      email,
      password,
    );
    return authState.copyWith(user: user);
  }

  static Future<AuthState> signInWithEmailAndPassword(
    AuthState authState,
    String email,
    String password,
  ) async {
    final user = await authState._authRepository.signInWithEmailAndPassword(
      email,
      password,
    );
    return authState.copyWith(user: user);
  }

  static Future<AuthState> signOut(AuthState authState) async {
    await authState._authRepository.signOut();
    return InitAuthState(authState._authRepository);
  }

  AuthState copyWith({
    IAuthRepository authRepository,
    User user,
  }) {
    return AuthState(
      authRepository: authRepository ?? _authRepository,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AuthState && o.user == user;
  }

  @override
  int get hashCode => user.hashCode;
  @override
  String toString() => 'AuthState(user: $user)';
}

class InitAuthState extends AuthState {
  InitAuthState(IAuthRepository authRepository)
      : super(
          authRepository: authRepository,
          user: null,
        );
}
