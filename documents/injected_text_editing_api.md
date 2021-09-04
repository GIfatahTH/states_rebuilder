//OK
`TextEditingController` is yet another controller that has a dedicated Injected state that will make it easier for us: 
- Create and automatically dispose of a `TextEditingController`,
- Associate the `TextEditingController` with a `TextField` or `TextFormField`,
- Change the value of the text and cache it,
- Easily work with a collection of TextFields (Form).
- Manage `FocusNote`, to dynamically change the focus to the next field to edit.

## Creation of the `InjectedTextEditing` state
Let's take the case of two `TextField`s: one for the email and the other for the password.
``` dart
final email =  RM.injectTextEditing():

final password = RM.injectTextEditing(
  text: '',
  selection: TextSelection.collapsed(offset: -1),
  composing: TextRange.empty,
  validator: (String? value) {
    if (value!.length < 6) {
      return "Password must have at least 6 characters";
    }
    return null;
  },
  validateOnTyping: true,
  validateOnLoseFocus: false,
  autoDispose: true,
  onTextEditing :(password){
    //fired when ever input text or selection changes
  }
);
```
- `text`,` selection` and `composing` used as in Flutter.
- The `validator` callback returns an error string or null if the field is valid.
- `validateOnTyping`: By default, text input is automatically validated while the user is typing. If set to false, the input text is only validated by calling the `email.validate()` method.
- `validateOnLoseFocus` if it is set to true, the field is not validated until it loses focus.
- The `InjectedTextEditing` is automatically deleted when it is no longer used. If you want to keep the data and use it in another `TextField`, set` autoDispose` to false.
- The default `validateOnTyping` and `validateOnLoseFocus` are changed when the using form. See below.

## Link the InjectedTextEditing with a TextField:
```dart
//Basically, define only the controller
//No need to define onChange nor onSave callbacks
TextField(
    controller: email.controller,
),

//Or for full features
TextField(
    controller: email.controller,
    focusNode: email.focusNode, //It is auto disposed of.
    decoration:  InputDecoration(
        errorText: email.error, //To display the error message.
    ),
    onSubmitted: (_) {
        //Focus on the password TextField after submission
        password.focusNode.requestFocus();
    },
),
```

## Consuming the valid data after submission:
```dart
_submit() {
  if (email.isValid && password.isValid) {
      print('Authenticate with ${email.text} and ${password.text}');
  }
}
```
- You can reset any `TextField` to its initial text using:
```dart
email.reset();
password.reset();
```
## Working with forms:
If the application you are working on contains dozens of TextFields, it becomes tedious to process each field individually. `Form` helps us collect many TextFields and manage them as a unit.

### Injected the form state:
```dart
final form = RM.injectForm(
  //optional parameters

  autovalidateMode: AutovalidateMode.disable,
  autoFocusOnFirstError: true,
  submit: () async {
    //This is the default submission logic,
    //It may be override when calling form.submit( () async { });
    //It may contains server validation.
   await serverError =  authRepository.signInWithEmailAndPassword(
      email: email.text,
      password: password.text,
    );
    //after server validation
    if(serverError == 'Invalid-Email'){
      email.error = 'Invalid email';
    }
    if(serverError == 'Weak-Password'){
      email.error = 'Password must have more the 6 characters';
    }
  },
  onSubmitting: () {
    // called while waiting for form submission,
  },
  onSubmitted: () {
    // called after form is successfully submitted
    // For example navigation to user page
  }

);
```
- `InjectedForm` has one optional parameter. “autovalidateMode” is of type “AutovalidateMode”. As in Flutter, It can take one of three enumeration values:
      - `AutovalidateMode.disable`: The form is validated manually by calling` form.validate()`
      - `AutovalidateMode.always`: The form is always validated
      - `AutovalidateMode.onUserInteraction`: The form is not validated until the user has started typing.
- `autoFocusOnFirstError` if set to true (default), after form validation the first non valid field is get focus.
- `submit` contains the user logic for form submission. It will be invoked whe the `form.submit()` si called without argument. (See from submission below)
- For side effects you have `onSubmitting` and `onSubmitted`.

### Link InjectedForm to InjectedTextEditing states
In the user interface, we put the `TextField`s that we want to associate with the form inside the` OnFormBuilder` widget:

```dart
OnFormBuilder(
  listenTo: form,
  builder: () => Column(
    children: <Widget>[
        TextField(
            focusNode: email.focusNode,
            controller: email.controller,
            decoration: InputDecoration(
              errorText: email.error,
            ),
            onSubmitted: (_) {
              //request the password node
              password.focusNode.requestFocus();
            },
        ),
        TextField(
            focusNode: password.focusNode,
            controller: password.controller,
            decoration: new InputDecoration(
              errorText: password.error,
            ),
            onSubmitted: (_) {
              //request the submit button node
              form.submitFocusNode.requestFocus();
            },
        ),
        OnFormSubmissionBuilder(
          listenTo: form
          onSubmitting: () => CircularProgressIndicator(),
          child : ElevatedButton(
            focusNode: form.submitFocusNode,
            onPressed: (){
                form.submit();
            },
            child: Text('Submit'),
          ),
        ),     
    ],
  ),
),
```
- We only use `TextField` widgets, no need to use` TextFormField`
- To validate all fields, use: `form.validate()`
- To reset all fields to their initial values, use: `form.reset()`
- To check that all fields are valid, use `form.isValid`
- Each `InjectedTextEditing` has an associated` FocusNode`.
- The `InjectedForm`  is associated with a FocusNote to be used in the submit button.
- All `TextEditingControllers` and `FocusNotes` are automatically disposed of when they are no longer in use.
- `OnFormSubmissionBuilder` widget is used to listen to form submission. (See below) 

### TextField validation and NodeFocus.
- `OnSubmissionBuilder` widget is used to listen to form submission. (See below) 

### TextField validation and NodeFocus.
If a TextField is put inside `OnFormBuilder` the validation logic defaults to the following:
- By default form validation mode is `AutovalidateMode.disable`.
- The `validateOnLoseFocus` is set to true and `validateOnTyping` is set to false. That is, the input text will not be validated until the field first loses focus.
- After a field loses focus, and if the input text is not valid, the `validateOnTyping` is set to true so that the field is validated on the fly.
- When the form is validated by calling f`orm.validate` or `form.submit`, and if validation fails, the first non-valid field will get focus.

### Form submission

To submit a form, you can use the `submit` method : 

```dart
//If called without argument, it will use the default submit callback defined while initializing the InjectForm
form.submit();

//Some time is is more convenient to define the submission logic inside the widget tree.
form.submit(() async {
    //submission logic,
    //It may contains server validation.
    authRepository.signInWithEmailAndPassword(
      email: email.text,
      password: password.text,
    );

    //after server response
    if(serverError == 'Invalid-Email'){
      email.error = 'Invalid email';
    }
    if(serverError == 'Weak-Password'){
      email.error = 'Password must have more the 6 characters';
    }
});
```

Here is an example take form [This auth example](https://github.com/GIfatahTH/states_rebuilder/tree/master/examples/ex_008_clean_architecture_firebase_login)

In the user repository,We sing in using `FireBaseAuth`:
```dart
  Future<User?> _signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final firebase.UserCredential authResult =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is firebase.FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            throw EmailException('Email address is not valid');
          case 'user-disabled':
            throw EmailException(
                'User corresponding to the given email has been disabled');
          case 'user-not-found':
            throw EmailException(
                'There is no user corresponding to the given email');
          case 'wrong-password':
            throw PasswordException('Password is invalid for the given email');
          default:
            throw SignInException(
              title: 'Create use with email and password',
              code: e.code,
              message: e.message,
            );
        }
      }
      rethrow;
    }
  }
```

In the UI :

```dart
final _email = RM.injectTextEditing(
  validator: (String? val) {
    //Frontend validation
    if (!Validators.isValidEmail(val!)) {
      return 'Enter a valid email';
    }
  },
);
final _password = RM.injectTextEditing(
  validator: (String? val) {
    if (!Validators.isValidPassword(val!)) {
      return 'Enter a valid password';
    }
  },
  validateOnTyping: true,
);

final _confirmationPassword = RM.injectTextEditing(
  validator: (String? val) {
    if (_password.text != val) {
      return 'Passwords do not match';
    }
  },
  validateOnTyping: true,
);

final _form = RM.injectForm();

class SignInRegisterFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormWidget(),
      ),
    );
  }
}

class FormWidget extends StatelessWidget {
  final _isRegister = false.inj();

  @override
  Widget build(BuildContext context) {
    return OnFormBuilder(
        listenTo: form,
        builder: () => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _email.controller,
              focusNode: _email.focusNode,
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
                errorText: _email.error,
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onSubmitted: (_) {
                _password.focusNode.requestFocus();
              },
            ),
            TextField(
              controller: _password.controller,
              focusNode: _password.focusNode,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'Password',
                errorText: _password.error,
              ),
              obscureText: true,
              autocorrect: false,
              onSubmitted: (_) {
                if (_isRegister.state) {
                  _confirmationPassword.focusNode.requestFocus();
                } else {
                  _form.submitFocusNode.requestFocus();
                }
              },
            ),

            OnReactive(
              () => Column(
                  children: [
                    _isRegister.state
                        ? TextField(
                            controller: _confirmationPassword.controller,
                            focusNode: _confirmationPassword.focusNode,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              labelText: 'Confirm Password',
                              errorText: _confirmationPassword.error,
                            ),
                            obscureText: true,
                            autocorrect: false,
                            onSubmitted: (_) {
                              _form.submitFocusNode.requestFocus();
                            },
                          )
                        : Container(),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _isRegister.state,
                          onChanged: (value) {
                            _isRegister.state = value!;
                          },
                        ),
                        Text(' I do not have an account')
                      ],
                    ),
                    OnFormSubmissionBuilder(
                      listenTo: form,
                      onSubmitting: () =>
                          Center(child: CircularProgressIndicator()),
                      child: ElevatedButton(
                        focusNode: _form.submitFocusNode,
                        child: _isRegister.state
                            ? Text('Register')
                            : Text('Sign in'),
                        onPressed: () {
                          _form.submit(
                            () async {
                              if (_isRegister.state) {
                                await user.auth.signUp(
                                  (_) => UserParam(
                                    signUp: SignUp.withEmailAndPassword,
                                    email: _email.state,
                                    password: _password.state,
                                  ),
                                );
                              } else {
                                await user.auth.signIn(
                                  (_) => UserParam(
                                    signIn: SignIn.withEmailAndPassword,
                                    email: _email.state,
                                    password: _password.state,
                                  ),
                                );
                                //Server validation
                                if (user.error is EmailException) {
                                  _email.error = user.error.message;
                                }
                                if (user.error is PasswordException) {
                                  _password.error = user.error.message;
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ],
        ),
    );
  }
}
```

