import 'dart:async';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class MainViewModel extends StatesRebuilder {
  final emailController = StreamController<String>.broadcast();
  final passwordController = StreamController<String>.broadcast();

  Function(String) get changeEmail => emailController.sink.add;
  Function(String) get changePassword => passwordController.sink.add;

  Streaming streamer;

  AsyncSnapshot<String> get emailSnapshot => streamer.snapshots[0];
  AsyncSnapshot<String> get passwordSnapshot => streamer.snapshots[1];

  AsyncSnapshot<String> get mergedSnapshot => streamer.snapshotMerged;

  //the combined snapshot. the combination function is given in `combine` closure
  AsyncSnapshot<String> get combinedSnapshot => streamer.snapshotCombined;

  MainViewModel() {
    //The typical place to use `rebuildFromStreams`is in the constructor
    streamer = Streaming<String, String>(
      //Note that `controller`, `streams`, `transforms` and `tags` are lists.
      //The order in the lists must match.
      controllers: [emailController, passwordController],
      //Alternatively you can pass the streams
      // streams: [email, password],
      transforms: [validateEmail, validatePassword],
    )..addListener(this, ["email", "password"]);

    //the combine function. the order is the same as in `controllers` list
    streamer.combineFn = (List<AsyncSnapshot> snaps) =>
        "email: ${snaps[0].data} password: ${snaps[1].data}";
  }

  submit() {}

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

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Injector(
          models: [() => MainViewModel()],
          disposeModels: true,
          builder: (_, __) => LoginScreen(),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Injector.get<MainViewModel>();
    return Container(
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
                      hintText: "Password should be more than three characters",
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
                  Row(
                    children: <Widget>[
                      Text("Email data from snap    :"),
                      Text(model.emailSnapshot.data ?? "ERROR")
                    ],
                  ),
                  Divider(),
                  Text("Password data from snap :"),
                  Text(model.passwordSnapshot.data ?? "ERROR"),
                  Divider(),
                  Column(
                    children: <Widget>[
                      Text("Merged data from snap   :"),
                      Text(model.mergedSnapshot.hasError
                          ? model.mergedSnapshot.error
                          : model.mergedSnapshot.data ?? "NULL")
                    ],
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      Text("Combined data from snap :"),
                    ],
                  ),
                  Text(model.combinedSnapshot.hasError
                      ? model.combinedSnapshot.error
                      : model.combinedSnapshot.data ?? "NULL")
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
