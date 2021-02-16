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
  middleSnapState: (middleSnap) {
    ////Uncomment to see print logs
    //middleSnap.print();
    //

    //Inside the middleSnapState we can validate the state
    if (!middleSnap.nextSnap.data!.email.contains("@")) {
      //return a modified state with error
      return middleSnap.nextSnap.copyToHasError(
        Exception("Enter a valid Email"),
      );
    }
  },
);
final password = RM.inject<Password>(
  () => Password(''),
  middleSnapState: (middleSnap) {
    ////Uncomment to see print logs
    // middleSnap.print(
    //   stateToString: (s) => '${s?.password}',
    // );

    if (middleSnap.nextSnap.data!.password.length < 4) {
      return middleSnap.nextSnap.copyToHasError(
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
        child: ListView(
          children: <Widget>[
            //use On to subscribe to the injected email
            //'On.data' do not work here, because it rebuild when model
            //has data only, whereas in our cas we want it rebuild onError also.
            On(
              () => TextField(
                onChanged: (String value) => email.state = Email(value),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "your@email.com. It should contain '@'",
                  labelText: "Email Address",
                  errorText: email.error?.message,
                ),
              ),
            ).listenTo(email),
            On(
              () {
                return TextField(
                  onChanged: (String value) => password.state = Password(value),
                  decoration: InputDecoration(
                    hintText: "Password should be more than three characters",
                    labelText: 'Password',
                    errorText: password.error?.message,
                  ),
                );
              },
            ).listenTo(password),
            OnCombined(
              //See documentation to understand more about the exposed model
              //(in the wiki / widget listeners / The exposed state)
              (exposedModel) {
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
                    Builder(
                      builder: (_) {
                        if (exposedModel is Email) {
                          return Text('Email : '
                              '${email.hasError ? email.error.message : email.state.email}');
                        }
                        if (exposedModel is Password) {
                          return Text('password : '
                              '${password.hasError ? password.error.message : password.state.password}');
                        }
                        return Container();
                      },
                    )
                  ],
                );
              },
            ).listenTo([email, password]),
          ],
        ),
      ),
    );
  }
}
