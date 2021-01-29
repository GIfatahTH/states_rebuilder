import 'package:clean_architecture_firebase_login/infrastructure/fake_apple_sign_in_available.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../infrastructure/apple_sign_in_available.dart';
import 'interfaces/i_apple_sign_in_available.dart';

final appleSignInCheckerService = RM.inject(
  () => AppSignInCheckerService(FakeAppleSignInChecker()),
  autoDisposeWhenNotUsed: false,
);

class AppSignInCheckerService {
  final IAppleSignInChecker appleSignInAvailable;
  bool canSignInWithApple;
  AppSignInCheckerService(this.appleSignInAvailable);

  Future<void> check() async {
    canSignInWithApple = await appleSignInAvailable.check();
  }
}
