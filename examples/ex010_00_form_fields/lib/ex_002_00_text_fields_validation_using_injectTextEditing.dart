import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(const MyApp());

class Email {
  final String email;
  Email(this.email);

  static String? validator(String? email) {
    if (email != null && !email.contains('@')) {
      return 'A valid email must contains @';
    }
    return null;
  }
}

class Password {
  final String password;
  Password(this.password);

  static String? validator(String? password) {
    if (password != null && password.length < 6) {
      return 'A valid password must contains as least 6 characters';
    }
    return null;
  }
}

final emailRM = RM.injectTextEditing(
  // By default validation is done on user typing
  // validateOnTyping: false, // must validated manually
  validators: [
    Email.validator,
  ],
);

final passwordRM = RM.injectTextEditing(
  // validation is done after field loosing focus
  validateOnLoseFocus: true,
  validators: [
    Password.validator,
  ],
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

  bool get isValid => emailRM.hasData && passwordRM.hasData;
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
              controller: emailRM.controller,
              focusNode: emailRM.focusNode,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "your@email.com",
                labelText: "Email Address",
                errorText: emailRM.error,
              ),
            ),
            TextField(
              controller: passwordRM.controller,
              focusNode: passwordRM.focusNode,
              decoration: InputDecoration(
                hintText: "Password",
                labelText: 'Password',
                errorText: passwordRM.error,
              ),
            ),
            Center(
              child: ElevatedButton(
                child: const Text("login"),
                onPressed: isValid
                    ? () {
                        print(emailRM.value);
                        print(passwordRM.value);
                      }
                    : null,
              ),
            ),
            const AnotherWidget(),
          ],
        ),
      ),
    );
  }
}

class AnotherWidget extends ReactiveStatelessWidget {
  const AnotherWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Email : '
            '${emailRM.hasError ? emailRM.error : emailRM.value}'),
        Text('password : '
            '${passwordRM.hasError ? passwordRM.error : passwordRM.value}'),
      ],
    );
  }
}
