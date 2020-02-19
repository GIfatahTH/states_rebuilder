import 'package:apple_sign_in/apple_sign_in.dart';

import '../service/interfaces/i_apple_sign_in_available.dart';

class AppleSignInChecker implements IAppleSignInChecker {
  Future<bool> check() async {
    return await AppleSignIn.isAvailable();
  }
}
