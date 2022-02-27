import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(const MyApp());

class Email {
  final String email;
  Email(this.email);

  static String? validator(Email email) {
    if (!email.email.contains('@')) {
      return 'A valid email must contains @';
    }
    return null;
  }
}

class Password {
  final String password;
  Password(this.password);

  static String? validator(Password password) {
    if (password.password.length < 6) {
      return 'A valid password must contains as least 6 characters';
    }
    return null;
  }
}

//injection of email and password.
//email and password are global variables but their state is not.
//We do not need RMKey here.
//they are easily mocked and tested (see test folder)
final email = RM.inject<Email>(
  () => Email(''),
  stateInterceptor: (currentSnap, nextSnap) {
    //Inside the stateInterceptor we can validate the state
    final validator = Email.validator(nextSnap.state);
    if (validator != null) {
      //return a modified state with error
      return nextSnap.copyToHasError(
        Exception(validator),
      );
    }
    return null;
  },
);
final password = RM.inject<Password>(
  () => Password(''),
  stateInterceptor: (currentSnap, nextSnap) {
    final validator = Password.validator(nextSnap.state);
    if (validator != null) {
      //return a modified state with error
      return nextSnap.copyToHasError(
        Exception(validator),
      );
    }
    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  bool get isValid => email.hasData && password.hasData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            TextField(
              onChanged: (String value) => email.state = Email(value),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "your@email.com",
                labelText: "Email Address",
                errorText: email.error?.message,
              ),
            ),
            TextField(
              onChanged: (String value) => password.state = Password(value),
              decoration: InputDecoration(
                hintText: "Password",
                labelText: 'Password',
                errorText: password.error?.message,
              ),
            ),
            OnBuilder.orElse(
              listenToMany: [email, password],
              orElse:
                  //See documentation to understand more about the exposed model
                  //(in the wiki / widget listeners / The exposed state)
                  (exposedModel) {
                return Column(
                  children: <Widget>[
                    ElevatedButton(
                      child: const Text("login"),
                      onPressed: isValid
                          ? () {
                              print(email.state.email);
                              print(password.state.password);
                            }
                          : null,
                    ),
                    const Text('exposedModel is :'),
                    if (exposedModel is Email)
                      Text('Email : '
                          '${email.hasError ? email.error.message : email.state.email}'),
                    if (exposedModel is Password)
                      Text('password : '
                          '${password.hasError ? password.error.message : password.state.password}'),
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
