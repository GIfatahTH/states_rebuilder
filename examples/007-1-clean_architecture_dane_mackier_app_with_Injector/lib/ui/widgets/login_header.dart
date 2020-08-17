import 'package:clean_architecture_dane_mackier_app/service/authentication_service.dart';
import 'package:clean_architecture_dane_mackier_app/ui/exceptions/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../common/text_styles.dart';
import '../common/ui_helpers.dart';

class LoginHeader extends StatelessWidget {
  final TextEditingController controller;

  LoginHeader({@required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Login', style: headerStyle),
        UIHelper.verticalSpaceMedium(),
        Text('Enter a number between 1 - 10', style: subHeaderStyle),
        LoginTextField(controller),
        WhenRebuilderOr(
          observe: () => RM.get<AuthenticationService>(),
          onError: (error) => Text(
            ErrorHandler.errorMessage(error),
            style: TextStyle(color: Colors.red),
          ),
          builder: (_, __) => Container(),
        ),
      ],
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;

  LoginTextField(this.controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      height: 50.0,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
      child: TextField(
          decoration: InputDecoration.collapsed(hintText: 'User Id'),
          controller: controller),
    );
  }
}
