import 'package:clean_architecture_firebase_login/domain/entities/user.dart';

import 'interfaces/i_user_repository.dart';

class UserService {
  final IUserRepository userRepository;

  UserService({this.userRepository});

  User user;

  void currentUser() async {
    user = await userRepository.currentUser();
  }

  void signInAnonymously() async {
    user = await userRepository.signInAnonymously();
  }

  void signInWithGoogle() async {
    user = await userRepository.signInWithGoogle();
  }

  void signInWithApple() async {
    user = await userRepository.signInWithApple();
  }

  void createUserWithEmailAndPassword(String email, String password) async {
    user = await userRepository.createUserWithEmailAndPassword(email, password);
  }

  void signInWithEmailAndPassword(String email, String password) async {
    user = await userRepository.signInWithEmailAndPassword(email, password);
  }

  void signOut() async {
    await userRepository.signOut();
    user = null;
  }
}
