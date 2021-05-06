part of 'auth_page.dart';

final user = RM.injectAuth<User?, UserParam>(
  () => FireBaseAuth(),
  persist: () => PersistState<User?>(
    key: '__UserToken__',
    toJson: (user) => user!.toJson(),
    fromJson: (json) {
      final user = User.fromJson(json);
      return user.token.isAuth == true ? user : null;
    },
    // debugPrintOperations: true,
  ),
  autoSignOut: (user) {
    final timeToExpiry = user!.token.expiryDate!
        .difference(
          DateTimeX.current,
        )
        .inSeconds;
    return Duration(seconds: timeToExpiry);
  },
  onSetState: On.error(
    (e, r) {
      if (e is AuthException) {
        ErrorHandler.showErrorSnackBar(e);
      }
    },
  ),
  // debugPrintWhenNotifiedPreMessage: '',
);
