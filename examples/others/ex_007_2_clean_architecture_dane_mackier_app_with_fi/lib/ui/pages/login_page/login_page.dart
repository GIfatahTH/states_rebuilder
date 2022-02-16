import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../blocs/user_bloc.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../exceptions/exception_handler.dart';

part 'login_header.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _LoginBody(),
    );
  }
}

class _LoginBody extends ReactiveStatelessWidget {
  static TextEditingController? controller;

  @override
  void didMountWidget(context) {
    controller = TextEditingController();
  }

  @override
  void didUnmountWidget() {
    controller?.dispose();
    controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LoginHeader(controller: controller!),
        userBloc.userRM.onOrElse(
          onWaiting: () => CircularProgressIndicator(),
          orElse: (data) => TextButton(
            // color: Colors.white,
            child: Text(
              'Login',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              userBloc.signIn(controller!.text);
            },
          ),
        ),
      ],
    );
  }
}
