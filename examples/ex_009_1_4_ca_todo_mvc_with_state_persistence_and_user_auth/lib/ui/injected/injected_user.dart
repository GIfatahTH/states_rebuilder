import 'dart:async';

import '../../data_source/firebase_auth_repository.dart';
import '../../domain/common/extensions.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_object/token.dart';
import '../../service/auth_service.dart';
import '../../service/interfaces/i_auth_repository.dart';
import '../exceptions/error_handler.dart';
import '../pages/auth_page/auth_page.dart';
import '../pages/home_screen/home_screen.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// final authRepository = RM.inject<IAuthRepository>(() => FireBaseAuth());

final user = RM.injectAuth<User, UserParam>(
  () => FireBaseAuth(),
  unsignedUser: UnsignedUser(),
  persist: () => PersistState<User>(
    key: '__UserToken__',
    toJson: (user) => user.toJson(),
    fromJson: (json) {
      final user = User.fromJson(json);
      return user.token?.isAuth == true ? user : UnsignedUser();
    },
    // debugPrintOperations: true,
  ),
  autoSignOut: (user) {
    final timeToExpiry = user.token.expiryDate
        .difference(
          DateTimeX.current,
        )
        .inSeconds;
    return Duration(seconds: timeToExpiry);
  },
  onSetState: On.error(ErrorHandler.showErrorSnackBar),
  onSigned: (_) => RM.navigate.toNamedAndRemoveUntil(HomeScreen.routeName),
  onUnsigned: () => RM.navigate.toNamedAndRemoveUntil(AuthPage.routeName),
  debugPrintWhenNotifiedPreMessage: '',
);

// extension UserX on User {
//   Future<User> signUp(String email, String password) async {
//     return await authRepository.state.signUp(email, password);
//   }

//   Future<User> login(String email, String password) async {
//     return await authRepository.state.login(email, password);
//   }

//   User logout() {
//     authRepository.state.logout();
//     return UnsignedUser();
//   }
// }

// final user = RM.inject<User>(
//   () => UnsignedUser(),
//   //As We want the logged use to be available throughout the whole app life cycle,
//   //we prevent it from auto disposing the injected model.
//   //
//   //As for the app, nothing will be affected. The only issue is when testing the app.
//   //To allow tests to pass, it is preferable to manually dispose the app when the app is disposed.
//   autoDisposeWhenNotUsed: false,
//   persist: () => PersistState(
//     key: '__UserToken__',
//     toJson: (user) => user.toJson(),
//     fromJson: (json) {
//       final user = User.fromJson(json);
//       return user.token?.isAuth == true ? user : null;
//     },
//     // debugPrintOperations: true,
//   ),
//   // debugPrintWhenNotifiedPreMessage: '',
//   onInitialized: (User u) {
//     if (u != null && u is! UnsignedUser) {
//       _setExpirationTimer(u.token);
//     }
//   },
//   onData: (User u) {
//     if (u is UnsignedUser) {
//       _cancelExpirationTimer();
//       RM.navigate.toNamedAndRemoveUntil(AuthPage.routeName);
//     } else {
//       _setExpirationTimer(u.token);
//       RM.navigate.toNamedAndRemoveUntil(HomeScreen.routeName);
//     }
//   },
//   onError: (e, s) {
//     ErrorHandler.showErrorSnackBar(e);
//   },
//   onDisposed: (_) {
//     _cancelExpirationTimer();
//   },
// );

// Timer _authTimer;
// void _setExpirationTimer(Token token) {
//   _cancelExpirationTimer();
//   final timeToExpiry = token.expiryDate.difference(DateTimeX.current).inSeconds;
//   _authTimer = Timer(
//     Duration(seconds: timeToExpiry),
//     () {
//       user.state = user.state.logout();
//     },
//   );
// }

// void _cancelExpirationTimer() {
//   if (_authTimer != null) {
//     _authTimer.cancel();
//     _authTimer = null;
//   }
// }
