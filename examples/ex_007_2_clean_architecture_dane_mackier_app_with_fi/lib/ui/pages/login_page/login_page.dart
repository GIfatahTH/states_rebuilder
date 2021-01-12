import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../injected.dart';
import '../../common/app_colors.dart';
import '../../exceptions/error_handler.dart';
import '../../widgets/login_header.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LoginHeader(controller: controller),
        authenticationService.whenRebuilderOr(
          onWaiting: () => CircularProgressIndicator(),
          dispose: () => controller.dispose(),
          builder: () {
            return FlatButton(
              color: Colors.white,
              child: Text(
                'Login',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                authenticationService.setState(
                  (s) => s.login(controller.text),
                  onError: ErrorHandler.showSnackBar,
                  onData: (_) {
                    RM.navigate.toNamed(('/'));
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
