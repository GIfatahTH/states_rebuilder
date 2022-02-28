import 'package:flutter/material.dart';

import '../ex_003_auto_logout_and_refresh_token/app.dart';
import '../ex_003_auto_logout_and_refresh_token/blocs/auth_bloc.dart';
import '../ex_003_auto_logout_and_refresh_token/models/token.dart';
import '../ex_003_auto_logout_and_refresh_token/models/user.dart';

main() {
  authBloc().injectMock(
    () => User(
      userId: 'user_id',
      displayName: 'fake user',
      email: 'fake@email.com',
      token: Token(
        token: 'Token',
        refreshToken: 'refresh token',
        expiryDate: DateTime.now().add(const Duration(seconds: 30)),
      ),
    ),
  );

  // authBloc().injectFutureMock(
  //   () async {
  //     await Future.delayed(const Duration(seconds: 3));
  //     return User(
  //       userId: 'user_id',
  //       displayName: 'fake user',
  //       email: 'fake@email.com',
  //       token: Token(
  //         token: 'Token',
  //         refreshToken: 'refresh token',
  //         expiryDate: DateTime.now().add(const Duration(seconds: 30)),
  //       ),
  //     );
  //   },
  // );
  runApp(const MyApp());
}
