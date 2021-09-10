part of 'login_page.dart';

final userInj = RM.injectAuth<User?, int>(
  () => UserRepository(),
  onSigned: (_) {
    RM.navigate.toNamed(('/posts'));
  },
  sideEffects: SideEffects.onError(
    (err, refresh) => ExceptionHandler.showSnackBar(err),
  ),
  debugPrintWhenNotifiedPreMessage: '',
);
