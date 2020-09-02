import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MyApp());

class Email {
  final String email;

  Email(this.email);

  validate() {
    if (!email.contains("@")) {
      throw Exception("Enter a valid Email");
    }
  }
}

class Password {
  final String password;

  Password(this.password);
  validate() {
    if (password.length <= 3) {
      throw Exception('Enter a valid password');
    }
  }
}

//functional injection of email and password.
//email and password are global variables but their state is not.
//We do not need RMKey here.
//they are easily mocked and tested (see test folder)
final email = RM.inject(() => Email(''));
final password = RM.inject(() => Password(''));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  bool get isValid => email.hasData && password.hasData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            //use whenRebuilderOr to subscribe to the injected email
            email.whenRebuilderOr(
              //the builder is called whenever the email is in the idle, error or has data state.
              builder: () {
                return TextField(
                  onChanged: (String value) {
                    email.setState(
                      (_) => Email(value)..validate(),
                      catchError: true,
                    );
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "your@email.com. It should contain '@'",
                    labelText: "Email Address",
                    errorText: email.error?.message,
                  ),
                );
              },
            ),
            password.whenRebuilderOr(
              builder: () {
                return TextField(
                  onChanged: (String value) {
                    //set the value of passwordRM after validation
                    password.setState(
                      (_) => Password(value)..validate(),
                      catchError: true,
                    );
                  },
                  decoration: InputDecoration(
                    hintText: "Password should be more than three characters",
                    labelText: 'Password',
                    errorText: password.error?.message,
                  ),
                );
              },
            ),
            WhenRebuilderOr(
              //subscribe to both email and password ReactiveModel keys
              observeMany: [() => email.getRM, () => password.getRM],
              builder: (_, exposedModel) {
                //this builder is called each time email or password emit a notification
                return Column(
                  children: <Widget>[
                    RaisedButton(
                      child: Text("login"),
                      onPressed: isValid
                          ? () {
                              print(email.state.email);
                              print(password.state.password);
                            }
                          : null,
                    ),
                    Text('exposedModel is :'),
                    Builder(builder: (_) {
                      if (exposedModel.state is Email) {
                        return Text('Email : '
                            '${exposedModel.hasError ? exposedModel.error.message : exposedModel.state.email}');
                      }
                      if (exposedModel.state is Password) {
                        return Text('password : '
                            '${exposedModel.hasError ? exposedModel.error.message : exposedModel.state.password}');
                      }
                      return Container();
                    })
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
