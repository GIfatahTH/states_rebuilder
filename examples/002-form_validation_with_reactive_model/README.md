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
  //create reactiveModels
  final ReactiveModel<Email>  emailRM = ReactiveModel.create(Email(''));
  final ReactiveModel<Password> passwordRM = ReactiveModel.create(Password(''));
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
                models: [emailRM],
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
                //subscribe to passwordRM
                models: [passwordRM],
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
                //subscribe to both emailRM and passwordRM
                models: [emailRM, passwordRM],
                builder: (_, __) {
                  //this builder is called each time emailRM or passwordRM emit a notification
                  return RaisedButton(
                    child: Text("Submit"),
                    onPressed: isValid
                        ? () {
                            print(emailRM.value.email);
                            print(passwordRM.value.password);
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
* the email input field is subscribed to the `emailRM` so that when the `emailRM` emits a notification only this input field will rebuild.
* the password input field is subscribed to the `passwordRM` so that it is the only part of the widget that rebuilds when `passwordRM` emits a notification.
* The submit button is subscribed to both the `emailRM` and `passwordRM`. and as you may guess it, the submit button will rebuild if any of the models emits a notification.

To better understand how states_rebuilder manage the state, let's track the state of the `emailRM` :

* Before the user type any character the `emailRM` is in the idle state:
```dart
print(emailRM.isIdle); // true
```
* as soon as the user type the first character the onChange callback of the `TextField` is invoked and `setValue` will be executed.
* the `setValue` create a new instance of Email class and check for validation.
```dart
return TextField(
        onChanged: (String password) {
            //set the value of passwordRM after validation
            passwordRM.setValue(
            () => Password(password)..validate(),
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
    models: [emailRM, passwordRM],
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
    models: [emailRM, passwordRM],
    builder: (BuildContext context, ReactiveModel exposedModel) {
      print(exposedModel is ReactiveModel<Email>); // will print true
      print(exposedModel is ReactiveModel<Password>); // will print false
        // return widget
    });
```
or

```dart
StateBuilder<Password>(
    models: [emailRM, passwordRM],
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
    models: [emailRM, passwordRM],
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
    models: [emailRM, passwordRM],
    builder: (_, exposedModel) {
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
        //Display the exposed model value
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
```