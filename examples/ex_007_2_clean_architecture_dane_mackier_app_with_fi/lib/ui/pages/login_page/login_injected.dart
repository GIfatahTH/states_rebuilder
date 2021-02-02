part of 'login_page.dart';

final userInj = RM.injectAuth<User, int>(
  () => UserRepository(),
  unsignedUser: UnSignedUser(),
  onSigned: (_) {
    RM.navigate.toNamed(('/posts'));
  },
  onSetState: On.error(ExceptionHandler.showSnackBar),
  debugPrintWhenNotifiedPreMessage: '',
);
