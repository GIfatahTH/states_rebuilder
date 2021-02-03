# form_validation_with_reactive_model

> Don't forget to run `flutter create .` in the terminal in the project directory to create platform-specific files.


> You can get more information from this tutorial :[Global function injection from A to Z](https://github.com/GIfatahTH/states_rebuilder/wiki/functional_injection_form_a_to_z/00-functional_injection)

In this tutorial we will explore more feature of the `ReactiveModel` and put in practice what we have seen in the first tutorial.

Let's build a simple login form validation. It consists of two input fields and a submit button. 
* Email input field : is valid if it contains '@'.
* Password input field : is valid if it contains more than three characters.
* Submit button : is inactive unless both email and password are valid.

<image src="https://github.com/GIfatahTH/repo_images/blob/master/004-form_login_with_validation.gif" width="300"/>

First let's define Email and Password immutable class with the logic of validation:

```dart
class Email {
  final String email;

  Email(this.email);

  validate() {
    if (!email.contains("@")) {
      throw Exception("Enter a valid Email");
    }
  }
}
```

```dart
class Password {
  final String password;

  Password(this.password);
  validate() {
    if (password.length <= 3) {
      throw Exception('Enter a valid password');
    }
  }
}
```
This is the complicated part of the form validation.

The UI part:

```dart

//functional injection of email and password.
//email and password are global variables but their state is not.
//We do not need RMKey here.
//they are easily mocked and tested (see test folder)
final email = RM.inject(
  () => Email(''),
  //To console print an informative message, we use debugPrintWhenNotifiedPreMessage
  //As both email and password are Strings, we label them to distinguish them
  debugPrintWhenNotifiedPreMessage: 'email',
);
final password = RM.inject(
  () => Password(''),
  debugPrintWhenNotifiedPreMessage: 'password',
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
            //use whenRebuilderOr to subscribe to the injected email
            //'email.rebuilder' do not work here, because it rebuild when model
            //has data only, whereas in our cas we want it rebuild onError also.
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
```

## Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_validation_with_reactive_model/main.dart';

void main() {
  Finder emailTextField;
  Finder passwordTextField;
  Finder activeLoginButton;
  setUp(
    () {
      emailTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration.labelText == "Email Address",
      );

      passwordTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration.labelText == "Password",
      );

      //active login button is that with a non null onPressed parameter
      activeLoginButton = find.byWidgetPredicate(
        (widget) => widget is RaisedButton && widget.onPressed != null,
      );
    },
  );

  testWidgets('email validation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    expect(find.text('Enter a valid Email'), findsNothing);
    expect(find.text('Email : Enter a valid Email'), findsNothing);

    //Non valid Email
    await tester.enterText(emailTextField, 'mail');
    await tester.pump();
    expect(find.text('Enter a valid Email'), findsOneWidget);
    expect(find.text('Email : Enter a valid Email'), findsOneWidget);

    //valid Email
    await tester.enterText(emailTextField, 'mail@');
    await tester.pump();
    expect(find.text('Enter a valid Email'), findsNothing);
    expect(find.text('Email : mail@'), findsOneWidget);
  });

  testWidgets('password validation', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Enter a valid password'), findsNothing);
    expect(find.text('password : Enter a valid password'), findsNothing);

    //Non valid password
    await tester.enterText(passwordTextField, 'pas');
    await tester.pump();
    expect(find.text('Enter a valid password'), findsOneWidget);
    expect(find.text('password : Enter a valid password'), findsOneWidget);

    //valid password
    await tester.enterText(passwordTextField, 'password');
    await tester.pump();
    expect(find.text('Enter a valid password'), findsNothing);
    expect(find.text('password : password'), findsOneWidget);
  });

  testWidgets('active login button', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    //before tapping login button is inactive
    expect(activeLoginButton, findsNothing);

    //Non valid email and valid password
    await tester.enterText(emailTextField, 'mail');
    await tester.enterText(passwordTextField, 'password');
    await tester.pump();
    //login button is inactive
    expect(activeLoginButton, findsNothing);

    //valid email and non valid password
    await tester.enterText(emailTextField, 'mail@');
    await tester.enterText(passwordTextField, 'pa');
    await tester.pump();
    //login button is inactive
    expect(activeLoginButton, findsNothing);

    //valid email and password
    await tester.enterText(emailTextField, 'mail@');
    await tester.enterText(passwordTextField, 'password');
    await tester.pump();
    //login button is active
    expect(activeLoginButton, findsOneWidget);
  });
}
```
