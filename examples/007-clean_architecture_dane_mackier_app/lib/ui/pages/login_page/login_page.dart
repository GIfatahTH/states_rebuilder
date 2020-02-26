import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../service/authentication_service.dart';
import '../../exceptions/error_handler.dart';
import '../../common/app_colors.dart';
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
        WhenRebuilderOr<AuthenticationService>(
          models: [ReactiveModel<AuthenticationService>()],
          onWaiting: () => CircularProgressIndicator(),
          dispose: (_, __) => controller.dispose(),
          builder: (_, authServiceRM) {
            return FlatButton(
              color: Colors.white,
              child: Text(
                'Login',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                authServiceRM.setState(
                  (state) => state.login(controller.text),
                  onError: ErrorHandler.showSnackBar,
                  onData: (context, authServiceRM) {
                    Navigator.pushNamed(context, '/');
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
