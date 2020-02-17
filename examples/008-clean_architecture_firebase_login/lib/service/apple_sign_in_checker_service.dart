import 'interfaces/i_apple_sign_in_available.dart';

class AppSignInCheckerService {
  final IAppleSignInChecker appleSignInAvailable;
  bool canSignInWithApple;
  AppSignInCheckerService(this.appleSignInAvailable);

  void check() async {
    canSignInWithApple = await appleSignInAvailable.check();
  }
}
