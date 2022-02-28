// import 'package:apple_sign_in/apple_sign_in.dart';

class AppleSignInChecker {
  Future<bool> check() async {
    // return await AppleSignIn.isAvailable();
    return true;
  }
}

class FakeAppleSignInChecker implements AppleSignInChecker {
  Future<bool> check() async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
}
