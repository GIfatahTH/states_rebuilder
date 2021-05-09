import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../data_source/api.dart';
import '../../../domain/entities/user.dart';
import '../../../service/common/input_parser.dart';
import '../../common/app_colors.dart';
import '../../common/text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../exceptions/exception_handler.dart';

part 'login_header.dart';
part 'login_injected.dart';

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
        _LoginHeader(controller: controller),
        On.or(
          onWaiting: () => CircularProgressIndicator(),
          or: () => TextButton(
            // color: Colors.white,
            child: Text(
              'Login',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              userInj.auth.signIn(
                (_) => InputParser.parse(controller.text),
              );
            },
          ),
        ).listenTo(
          userInj,
          dispose: () => controller.dispose(),
        ),
      ],
    );
  }
}
