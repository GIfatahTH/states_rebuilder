# form_validation_with_reactive_model

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
```
`MyApp` is a simple StatelessWidget.

```dart
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
            //subscribe to emailRM
            StateBuilder(
                //create and subscribe to local ReactiveModel of Email type
                observe: () => RM.create(Email('')),
                // associate the emailRM ReactiveModel key with the create ReactiveModel in observe parameter
                rmKey: emailRM,
                builder: (_, __) {
                  return TextField(
                    onChanged: (String email) {
                      //set the value of the emailRM after validation
                      emailRM.setState(
                        (Email currentState) => Email(email)..validate(),
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
                      passwordRM.setState(
                        (_) => Password(password)..validate(),
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
                //subscribe to both emailRM and passwordRM
                models: [emailRM, passwordRM],
                builder: (_, __) {
                  //this builder is called each time emailRM or passwordRM emit a notification
                  return RaisedButton(
                    child: Text("Submit"),
                    onPressed: isValid
                        ? () {
                            print(emailRM.state.email);
                            print(passwordRM.state.password);
                          }
                        : null,
                  );
                })
          ],
        ),
      ),
    );
  }
}
```

The point here is that each of the email, password input fields and the submit button are wrapped within a `StateBuilder` widget.
* the email input field is subscribed to the laically created ReactiveModel`emailRM` so that when the `emailRM` emits a notification only this input field will rebuild.
* the password input field is subscribed to the `passwordRM` so that it is the only part of the widget that rebuilds when `passwordRM` emits a notification.
* The submit button is subscribed to both the `emailRM` and `passwordRM` ReactiveModel keys. and as you may guess it, the submit button will rebuild if any of the models emits a notification.

To better understand how states_rebuilder manage the state, let's track the state of the `emailRM` :

* Before the user type any character the `emailRM` is in the idle state:
```dart
print(emailRM.isIdle); // true
```
* as soon as the user type the first character the onChange callback of the `TextField` is invoked and `setState` will be executed.
* the `setState` create a new instance of Email class and check for validation.
```dart
return TextField(
        onChanged: (String password) {
            //set the state of passwordRM after validation
            passwordRM.setState(
            (_) => Password(password)..validate(),
            catchError: true,
            );
        },
```
* If an Exception is thrown, it will be caught, and the state of the `emailRM` is changed to be `hasError` and notification is emitted to observer widgets.
```dart
print(emailRM.hasError); // true
```
* The email TextField will rebuild and a red error message will appear underneath.
* At the same time the submit button will rebuild and stay inactive because `isValid` is false.

This the all for the validation with states_rebuilder.

## Note on the exposed model.
You may not need this now, but I find it the right palace to invoke this point.

What I call exposed model is the second parameter of the builder callback.

```dart
StateBuilder(
    observeMany: [()=> emailRM,()=> passwordRM],
    builder: (BuildContext context, ReactiveModel exposedModel) {
                                                        ^
                                                        |
                                            //This is the exposed model
        // return widget
    });
```
The instance that holds the exposedModel depends on the generic type of the `StatesRebuilder`.
for example:

```dart
StateBuilder<Email>(
    observeMany: [()=> emailRM,()=> passwordRM],
    builder: (BuildContext context, ReactiveModel exposedModel) {
      print(exposedModel is ReactiveModel<Email>); // will print true
      print(exposedModel is ReactiveModel<Password>); // will print false
        // return widget
    });
```
or

```dart
StateBuilder<Password>(
    observeMany: [()=> emailRM,()=> passwordRM],
    builder: (BuildContext context, ReactiveModel exposedModel) {
      print(exposedModel is ReactiveModel<Email>); // will print false
      print(exposedModel is ReactiveModel<Password>); // will print true
        // return widget
    });
```

Cool, What if the generic type is dynamic (or omitted)?
Then the exposed model is also dynamic. By dynamic I mean it will hold the instance of the reactive model that is emitting the notification.

```dart
StateBuilder(
    observeMany: [()=> emailRM,()=> passwordRM],
    builder: (BuildContext context, ReactiveModel exposedModel) {

      //exposedModel is neither  ReactiveModel<Email> nor ReactiveModel<Password>

      //BUT

     // if emailRM emits a notification :
      print(exposedModel is ReactiveModel<Email>); // will print true
      print(exposedModel is ReactiveModel<Password>); // will print false

      //whereas if password emits a notification
      print(exposedModel is ReactiveModel<Email>); // will print false
      print(exposedModel is ReactiveModel<Password>); // will print true


        // return widget
    });
```

How match practice this is, I do not know, I choose to make it like this. And this is works wherever there is an exposed model in `StateBuilder`, `WhenRebuilder` and `OnSetStateListener`.

To see this in practice let's return to our example and add:


```dart
StateBuilder(
    observeMany: [()=> emailRM,()=> passwordRM],
    builder: (_, exposedModel) {
    return Column(
        children: <Widget>[
        RaisedButton(
            child: Text("login"),
            onPressed: isValid
                ? () {
                    print(emailRM.state.email);
                    print(passwordRM.state.password);
                }
                : null,
        ),
        //Display the exposed model value
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
```

# Test

Although the UI and the business logic are tightly coupled, the UI is easily tested because the behavior of the validation is expected.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_validation_with_reactive_model/main.dart';

void main() {
  //To reduce the boilerplate we define our textFields and button binder in the setUp method.
  Finder emailTextField;
  Finder passwordTextField;
  Finder activeLoginButton;
  setUp(
    () {
      //email textField finder
      emailTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration.labelText == "Email Address",
      );
      //password TextField finder
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

  testWidgets('login button activation', (WidgetTester tester) async {
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