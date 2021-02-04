import '../infrastructure/fake_apple_sign_in_available.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final canSignInWithApple = RM.injectFuture(
  () => FakeAppleSignInChecker().check(),
  autoDisposeWhenNotUsed: false,
);

// class AppSignInCheckerService {
//   final IAppleSignInChecker appleSignInAvailable;
//   bool canSignInWithApple;
//   AppSignInCheckerService(this.appleSignInAvailable);

//   Future<void> check() async {
//     canSignInWithApple = await appleSignInAvailable.check();
//   }
// }
