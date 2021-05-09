part of 'login_page.dart';

final userInj = RM.injectAuth<User?, int>(
  () => UserRepository(),
  onSigned: (_) {
    RM.navigate.toNamed(('/posts'));
  },
  onSetState: On.error((err, refresh) => ExceptionHandler.showSnackBar(err)),
  debugPrintWhenNotifiedPreMessage: '',
);
