import 'package:clean_architecture_firebase_login/service/apple_sign_in_checker_service.dart';
import 'package:clean_architecture_firebase_login/service/interfaces/i_apple_sign_in_available.dart';

class FakeAppSignInCheckerService extends AppSignInCheckerService {
  FakeAppSignInCheckerService(IAppleSignInChecker appleSignInAvailable)
      : super(appleSignInAvailable);

  @override
  Future<void> check() async {
    await Future.delayed(Duration(seconds: 1));

    canSignInWithApple = true;
  }
}
