import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MyApp());

class Email {
  final String email;

  Email(this.email);
}

class Password {
  final String password;

  Password(this.password);
}

//functional injection of email and password.
//email and password are global variables but their state is not.
//We do not need RMKey here.
//they are easily mocked and tested (see test folder)
final email = RM.inject<Email>(
  () => Email(''),
  stateInterceptor: (currentSnap, nextSnap) {
    //Inside the stateInterceptor we can validate the state

    //
    if (!nextSnap.hasData) {
      //At app start and when fields are empty we do not want to validate the field
      //
      //If you want to remove this if
      return null;
    }
    if (!nextSnap.data!.email.contains("@")) {
      //return a modified state with error
      return nextSnap.copyToHasError(
        Exception("Enter a valid Email"),
      );
    }
  },
);
final password = RM.inject<Password>(
  () => Password(''),
  stateInterceptor: (currentSnap, nextSnap) {
    if (nextSnap.data!.password.length < 4) {
      return nextSnap.copyToHasError(
        Exception('Enter a valid password'),
        stackTrace: StackTrace.current,
      );
    }
  },
);

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
        child: OnReactive(
          () => ListView(
            children: <Widget>[
              //use On to subscribe to the injected email
              //'On.data' do not work here, because it rebuild when model
              //has data only, whereas in our cas we want it rebuild onError also.
              TextField(
                onChanged: (String value) => email.state = Email(value),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "your@email.com. It should contain '@'",
                  labelText: "Email Address",
                  errorText: email.error?.message,
                ),
              ),

              TextField(
                onChanged: (String value) => password.state = Password(value),
                decoration: InputDecoration(
                  hintText: "Password should be more than three characters",
                  labelText: 'Password',
                  errorText: password.error?.message,
                ),
              ),
              OnBuilder.data(
                listenToMany: [email, password],
                builder:
                    //See documentation to understand more about the exposed model
                    //(in the wiki / widget listeners / The exposed state)
                    (exposedModel) {
                  return Column(
                    children: <Widget>[
                      ElevatedButton(
                        child: Text("login"),
                        onPressed: isValid
                            ? () {
                                print(email.state.email);
                                print(password.state.password);
                              }
                            : null,
                      ),
                      Text('exposedModel is :'),
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
          debugPrintWhenObserverAdd: '',
        ),
      ),
    );
  }
}
