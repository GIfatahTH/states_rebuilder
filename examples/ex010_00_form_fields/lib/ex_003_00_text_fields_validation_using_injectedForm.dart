import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(const MyApp());

class Validators {
  static String? emailValidator(String? email) {
    if (email != null && !email.contains('@')) {
      return 'A valid email must contains @';
    }
    return null;
  }

  static String? passwordValidator(String? password) {
    if (password != null && password.length < 6) {
      return 'A valid password must contains as least 6 characters';
    }
    return null;
  }
}

final form = RM.injectForm(
  // By default form validation is done after field losing focus
  // autovalidateMode: AutovalidateMode.onUserInteraction,
  submit: () async {
    await Future.delayed(const Duration(seconds: 1));
    print(emailRM.value);
    print(passwordRM.value);
  },
);

final emailRM = RM.injectTextEditing(
  validators: [
    Validators.emailValidator,
  ],
);

final passwordRM = RM.injectTextEditing(
  validators: [
    Validators.passwordValidator,
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: OnFormBuilder(
            listenTo: form,
            builder: () {
              return ListView(
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
                    child: form.isWaiting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            child: const Text("login"),
                            onPressed: form.isValid ? form.submit : null,
                          ),
                  ),
                  if (form.isDirty)
                    const Text('The form is changed but not submitted yet!')
                ],
              );
            }),
      ),
    );
  }
}
