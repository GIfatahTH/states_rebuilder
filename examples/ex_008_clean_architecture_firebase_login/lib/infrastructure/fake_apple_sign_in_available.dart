import '../service/interfaces/i_apple_sign_in_available.dart';

class FakeAppleSignInChecker implements IAppleSignInChecker {
  Future<bool> check() async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
}
