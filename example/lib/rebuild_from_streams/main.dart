import 'dart:async';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class MainViewModel extends StatesRebuilder {
  final emailController = StreamController<String>.broadcast();
  final passwordController = StreamController<String>.broadcast();

  Function(String) get changeEmail => emailController.sink.add;
  Function(String) get changepassword => passwordController.sink.add;

  AsyncSnapshot<String> emailSnapshot,
      passwordSnapshot,
      combidedSnapshot,
      mergedSnapshot;

  MainViewModel() {
    //The typical place to use `rebuildFromStreams`is in the constructor
    rebuildFromStreams<String>(
      //Note that `controller`, `streams`, `transforms` and `tags` are lists.
      //The order in the lists must match.
      controllers: [emailController, passwordController],
      //Alternativally you can pass the streams
      // streams: [email, password],
      transforms: [validateEmail, validatePassword],
      initialData: ["initial Email", "initial Password"],
      //The tags to rebuild when the streams get data
      //example : ``emailController`` has `validateEmail` as `transform` and will rebuild `email` tag.
      tags: ["email", "password"],

      //List of `snapshots` in the same order in `controllers` list
      snapshots: (List<AsyncSnapshot<String>> snapshots) {
        emailSnapshot = snapshots[0];
        passwordSnapshot = snapshots[1];
      },

      //The merged snapshot of all the streams
      snapshotMerged: (AsyncSnapshot<String> snap) {
        mergedSnapshot = snap;
      },

      //the combined snapshot. the combination function is given in `combine` closuer
      snapshotCombined: (snapshot) {
        combidedSnapshot = snapshot;
      },

      //the combine function. the order is the same as in `controllers` list
      combine: (List<AsyncSnapshot<String>> snaps) =>
          "email: ${snaps[0].data} password: ${snaps[1].data}",
    );
  }

  submit() {}

  //The validatation of the email. It must containe @
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if (email.contains("@")) {
        sink.add(email);
      } else {
        sink.addError("Enter a valid Email");
      }
    },
  );

  //The validation of the password. It must have more than three caracters
  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.length > 3) {
        sink.add(password);
      } else {
        sink.addError("Enter a valid passwordd");
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
          builder: (_) => LogginScreen(),
        ),
      ),
    );
  }
}

class LogginScreen extends StatelessWidget {
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
                    hintText: "your@email.com. It sould contain '@'v",
                    labelText: "Email Aderess",
                    errorText: model.emailSnapshot.error,
                  ),
                  onChanged: model.changeEmail,
                ),
          ),
          StateBuilder(
            viewModels: [model],
            tag: "password",
            builder: (_, __) => TextField(
                  onChanged: model.changepassword,
                  decoration: InputDecoration(
                      hintText: "Password sould be more than three caracters",
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
                children: <Widget>[
                  RaisedButton(
                    child: Text("login"),
                    onPressed: model.combidedSnapshot.hasData
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
                  Row(
                    children: <Widget>[
                      Text("Password data from snap :"),
                      Text(model.passwordSnapshot.data ?? "ERROR")
                    ],
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      Text("Merged data from snap   :"),
                      Text(model.mergedSnapshot.data ?? "ERROR")
                    ],
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      Text("Combined data from snap :"),
                    ],
                  ),
                  Text(model.combidedSnapshot.data ?? "ERROR")
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
