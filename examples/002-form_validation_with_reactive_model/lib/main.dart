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
  //create reactiveModels keys
  final RMKey<Email> emailRM = RMKey();
  final RMKey<Password> passwordRM = RMKey();
  // helper getter to check the validity of the form
  bool get isValid => emailRM.hasData && passwordRM.hasData;
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
            StateBuilder(
                //create and subscribe to local ReactiveModel of Email type
                observe: () => RM.create(Email('')),
                // associate the emailRM ReactiveModel key with the create ReactiveModel in observe parameter
                rmKey: emailRM,
                builder: (_, __) {
                  return TextField(
                    onChanged: (String email) {
                      //set the value of the emailRM after validation
                      emailRM.setValue(
                        () => Email(email)..validate(),
                        //catchError if validation throws
                        catchError: true,
                      );
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "your@email.com. It should contain '@'",
                      labelText: "Email Address",
                      //emailRM.error is null and if the validation throws, it will hold the error object
                      errorText: emailRM.error?.message,
                    ),
                  );
                }),
            StateBuilder(
                //create and subscribe to local ReactiveModel of Password type
                observe: () => RM.create(Password('')),
                // associate the passwordRM ReactiveModel key with the create ReactiveModel in observe parameter
                rmKey: passwordRM,
                builder: (_, __) {
                  return TextField(
                    onChanged: (String password) {
                      //set the value of passwordRM after validation
                      passwordRM.setValue(
                        () => Password(password)..validate(),
                        catchError: true,
                      );
                    },
                    decoration: InputDecoration(
                      hintText: "Password should be more than three characters",
                      labelText: 'Password',
                      errorText: passwordRM.error?.message,
                    ),
                  );
                }),
            StateBuilder(
              //subscribe to both emailRM and passwordRM ReactiveModel keys
              observeMany: [() => emailRM, () => passwordRM],
              builder: (_, exposedModel) {
                //this builder is called each time emailRM or passwordRM emit a notification
                return Column(
                  children: <Widget>[
                    RaisedButton(
                      child: Text("login"),
                      onPressed: isValid
                          ? () {
                              print(emailRM.value.email);
                              print(passwordRM.value.password);
                            }
                          : null,
                    ),
                    Text('exposedModel is :'),
                    Builder(builder: (_) {
                      if (exposedModel.value is Email) {
                        return Text('Email : '
                            '${exposedModel.hasError ? exposedModel.error.message : exposedModel.value.email}');
                      }
                      if (exposedModel.value is Password) {
                        return Text('password : '
                            '${exposedModel.hasError ? exposedModel.error.message : exposedModel.value.password}');
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
