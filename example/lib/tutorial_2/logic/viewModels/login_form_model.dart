import 'dart:async';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class LoginFormModel extends StatesRebuilder {
  final emailController = StreamController<String>();
  final passwordController = StreamController<String>();

  Function(String) get changeEmail => emailController.sink.add;
  Function(String) get changePassword => passwordController.sink.add;

  Streaming<String, String> formStreaming;

  AsyncSnapshot<String> get emailSnapshot => formStreaming.snapshots[0];
  AsyncSnapshot<String> get passwordSnapshot => formStreaming.snapshots[1];

  AsyncSnapshot<String> get mergedSnapshot => formStreaming.snapshotMerged;

  //the combined snapshot. the combination function is given in `combine` closure
  AsyncSnapshot<String> get combinedSnapshot => formStreaming.snapshotCombined;

  LoginFormModel() {
    //The typical place to use `Streaming`is in the constructor
    formStreaming = Streaming(
      //Note that `controller`, `streams`, `transforms` and `tags` are lists.
      //The order in the lists must match.
      controllers: [emailController, passwordController],
      //Alternatively you can pass the streams
      // streams: [email, password],
      transforms: [validateEmail, validatePassword],
    );
    formStreaming.addListener(this, ["email", "password"]);

    //the combine function. the order is the same as in `controllers` list
    formStreaming.combineFn = (List<AsyncSnapshot> snaps) =>
        "email: ${snaps[0].data} password: ${snaps[1].data}";
  }

  submit() {
    print("form submitted");
  }

  //The validation of the email. It must contain @
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if (email.contains("@")) {
        sink.add(email);
      } else {
        sink.addError("Enter a valid Email");
      }
    },
  );

  //The validation of the password. It must have more than three characters
  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.length > 3) {
        sink.add(password);
      } else {
        sink.addError("Enter a valid password");
      }
    },
  );

  //Disposing the controllers
  dispose() {
    emailController.close();
    passwordController.close();
    print("controllers are disposed");
  }
}
