import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../../logic/viewModels/login_form_model.dart';

class LoginFormView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<LoginFormModel>(
      models: [() => LoginFormModel()],
      builder: (context, LoginFormModel model) => Container(
            margin: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                StateBuilder(
                  viewModels: [model],
                  tag: "email",
                  builder: (_, __) => TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "your@email.com. It should contain '@'",
                          labelText: "Email Address",
                          errorText: model.emailSnapshot.error,
                        ),
                        onChanged: model.changeEmail,
                      ),
                ),
                StateBuilder(
                  viewModels: [model],
                  tag: "password",
                  builder: (_, __) => TextField(
                        onChanged: model.changePassword,
                        decoration: InputDecoration(
                            hintText:
                                "Password should be more than three characters",
                            labelText: 'Password',
                            errorText: model.passwordSnapshot.error),
                      ),
                ),
                StateBuilder(
                  viewModels: [model],
                  tag: [
                    "email",
                    "password"
                  ], //this widget will rebuild if any of these two tags is invoked
                  builder: (_, tagID) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("login"),
                          onPressed: model.combinedSnapshot.hasData
                              ? () {
                                  model.submit();
                                }
                              : null,
                        ),
                        Divider(),
                        Text("Email data from snap    :"),
                        Text(model.emailSnapshot.data ?? "ERROR"),
                        Divider(),
                        Text("Password data from snap :"),
                        Text(model.passwordSnapshot.data ?? "ERROR"),
                        Divider(),
                        Text("Merged data from snap   :"),
                        Text(model.mergedSnapshot.hasError
                            ? model.mergedSnapshot.error
                            : model.mergedSnapshot.data ?? "NULL"),
                        Divider(),
                        Text("Combined data from snap :"),
                        Text(model.combinedSnapshot.hasError
                            ? model.combinedSnapshot.error
                            : model.combinedSnapshot.data ?? "NULL")
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }
}
