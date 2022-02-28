import 'package:flutter/foundation.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../data_source/api.dart';
import '../domain/entities/user.dart';
import '../ui/exceptions/exception_handler.dart';
import 'common/input_parser.dart';

@immutable
class UserBloc {
  final userRM = RM.injectAuth<User?, int>(
    () => UserRepository(),
    onSigned: (_) {
      RM.navigate.toNamed(('/posts'));
    },
    sideEffects: SideEffects.onError(
      (err, refresh) => ExceptionHandler.showSnackBar(err),
    ),
    debugPrintWhenNotifiedPreMessage: '',
  );

  User? get user => userRM.state;
  void signIn(String text) {
    userRM.auth.signIn(
      (_) => InputParser.parse(text),
    );
  }
}

final userBloc = UserBloc();
