part of 'auth_page.dart';

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
  onSigned: (_) {
    return RM.navigate.toNamedAndRemoveUntil(HomeScreen.routeName);
  },
  onUnsigned: () {
    return RM.navigate.toNamedAndRemoveUntil(AuthPage.routeName);
  },
  onSetState: On.error(ErrorHandler.showErrorSnackBar),
  debugPrintWhenNotifiedPreMessage: '',
);
