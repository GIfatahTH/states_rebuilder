# clean_architecture_firebase_login

![Sign in with firebase 1](https://github.com/GIfatahTH/repo_images/blob/master/009-sign_in_with_firebase2.gif).

![Sign in with firebase 2](https://github.com/GIfatahTH/repo_images/blob/master/009-sign_in_with_firebase1.gif).

The architecture consists of something like onion layers, the innermost one is the domain layer, the middle layer is the service layer and the outer layer consists of three parts: the user interface  UI, data_source and infrastructure. Each of the parts of the architecture is implemented using folders.

![Clean Architecture](https://github.com/GIfatahTH/repo_images/blob/master/008-Clean-Architecture.png).

Code dependencies can only point inwards. Nothing in an inner circle can know anything at all about something in an outer circle. In particular, the name of something declared in an outer circle must not be mentioned by the code in the inner circle.
```
**lib -**  
    | **- domain**  
    |        | **- entities :** (mutable objects with unique IDs.  
    |        |              They are the in-memory representation of   
    |        |              the data that was retrieved from the persistence   
    |        |              store (data_source))  
    |        |   
    |        | **- value objects :** (immutable objects which have value equality   
    |        |                      and self-validation but no IDs)  
    |        |   
    |        | **- exceptions :** (all custom exceptions classes that can be   
    |        |                      thrown from the domain)  
    |        |  
    |        | **- common :** (common utilities shared inside the domain)  
    |   
    | **- service**  
    |        | **- interfaces :** (interfaces that should any external service implements)  
    |        |   
    |        | **- exceptions :** (all custom exceptions classes that can be thrown   
    |        |                    from the service, infrastructure and data_source)  
    |        |   
    |        | **- common :**(common utilities shared inside the service)   
    |  
    | **-data_source** : (implements interfaces defined and throws exception defined in   
    |        |                the service layer. It is used to fetch and persist data  
    |        |                and instantiate entities and value objects)  
    |  
    | **-infrastructure** : (implements interfaces defined and throws exception defined in   
    |        |                the service layer. It is used to call third party libraries   
    |        |                to make a call or send a message or email,.... )  
    |         
    | **UI**  
    |        | **- pages** :(collection of pages the UI has).  
    |        |   
    |        | **- widgets**: (small and reusable widgets that should be app independent. 
    |        |                 If you use a widget from external libraries, put it in this folder
    |        |                 and adapt its interface, so you can change it easily later (adapter pattern)
    |        |   
    |        | **- exceptions :** (Handle exceptions)  
    |        |   
    |        | **- common :**(common utilities shared inside the ui)  
```   

For more detail on the implemented clean architecture read [this article](https://medium.com/flutter-community/clean-architecture-with-states-rebuilder-has-never-been-cleaner-6c9b91c3b9b6#a588)

# Domain
## Entities
> Entities are mutable objects with unique IDs. They are the in-memory representation of the data that was retrieved from the persistence store (data_source). They must contain all the logic it controls. They should be validated just before persistence.

There is one entity 'User'.
### User entity :
**file:lib/domain/entities/user.dart**

```dart
class User {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;

  User({
    this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}
```

## value object
>value objects are Immutable objects which have value equality and self-validation but no IDs.

There are two value objects 'Email' and 'Password'. They will be used in form validation.
**file:lib/domain/value_objects/email.dart**
```dart
class Email {
  //Constructor
  Email(this.value) {
      //Value objects are either created in the right state or throws
    if (!Validators.isValidEmail(value)) {
      throw ValidationException('Enter a valid email');
    }
  }

  final String value;
}
```

**file:lib/domain/value_objects/email.dart**
```dart
class Password {
  Password(this.value) {
    if (!Validators.isValidPassword(value)) {
      throw ValidationException('Enter a valid password');
    }
  }

  final String value;
}
```

## exceptions
**file:lib/domain/exceptions/validation_exception.dart**
```dart
class ValidationException extends Error {

  ValidationException(this.message);

  final String message;
}
```

## common
**file:lib/domain/exceptions/validator.dart**
```dart
class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return _passwordRegExp.hasMatch(password);
  }
}
```

That's all for the domain layer. It contains all the enterprise-wide logic, exceptions thrown from this layer and common methods used in this layer. It has no reference to the upper layers.

# service

## interfaces
One of the major responsibilities of the service layer is to define a set of interfaces, the data_source and the infrastructure part of the outer layer must implement to compatible to be used in the app.

We have two abstract classes: 

**file:lib/service/interfaces/i_user_repository.dart**

```dart
abstract class IUserRepository {
  Future<User> currentUser();
  Future<User> signInAnonymously();
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> createUserWithEmailAndPassword(String email, String password);
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();
  Future<void> signOut();
}
```

**file:lib/service/interfaces/i_apple_sign_in_available.dart**

Use to check if the app can sign in with apple.

```dart
abstract class IAppleSignInChecker {
  Future<bool> check();
}
```

## exceptions
The service layer must contain custom error classes to be thrown by the service layer itself and the data_source and the infrastructure.

**file:lib/service/exceptions/sign_in_out_exception.dart**

```dart
class SignInException extends Error {
  final title;
  final String code;
  final String message;
  SignInException({this.title, this.code, this.message});
}

class SignOutException extends Error {
  final title;
  final String code;
  final String message;
  SignOutException({this.title, this.code, this.message});
}
```

Typically, for each entity, there is a corresponding service class with the responsibility to instantiate and keep the entity by delegating to an external service and processing the entity so that it is suitable for use cases.

**file:lib/service/user_service.dart**

UserService role is to hole the registered user and delegate to `userRepository` for sign-in / out operations
```dart
class UserService {
  final IUserRepository userRepository;

  UserService({this.userRepository});

  User user;

  void currentUser() async {
    user = await userRepository.currentUser();
  }

  void signInAnonymously() async {
    user = await userRepository.signInAnonymously();
  }

  void signInWithGoogle() async {
    user = await userRepository.signInWithGoogle();
  }

  void signInWithApple() async {
    user = await userRepository.signInWithApple();
  }

  void createUserWithEmailAndPassword(String email, String password) async {
    user = await userRepository.createUserWithEmailAndPassword(email, password);
  }

  void signInWithEmailAndPassword(String email, String password) async {
    user = await userRepository.signInWithEmailAndPassword(email, password);
  }

  void signOut() async {
    await userRepository.signOut();
    user = null;
  }
}
```
**file:lib/service/apple_sign_in_checker.dart**

```dart
class AppSignInCheckerService {
  AppSignInCheckerService(this.appleSignInAvailable);

  final IAppleSignInChecker appleSignInAvailable;

  bool canSignInWithApple;

  void check() async {
    canSignInWithApple = await appleSignInAvailable.check();
  }
}
```

That is the application service layer which defines the use cases. It encapsulates all the exceptions thrown from the service layer as well as the data_source and the infrastructure layer.

# data_source
**file:lib/data_source/user_repository.dart**
Implement the `IUserRepository` class form the interface folder of the service layer.
Errors must be catches and custom error defined in the service layer must be thrown instead.
```dart
class UserRepository implements IUserRepository {
  final FirebaseAuth _firebaseAuth;

  final GoogleSignIn _googleSignIn;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();


  @override
  Future<User> signInWithGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
     // Throw a custom exception if googleUser is null (form docs)
      throw SignInException(
        title: 'Google sign in',
        code: '',
        message: 'Sign in with google is aborted',
      );
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final AuthResult authResult =
          (await _firebaseAuth.signInWithCredential(credential));
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      // Throw a custom exception if googleUser error is PlatformException (form docs)
      if (e is PlatformException) {
        throw SignInException(
          title: 'Sign in with google',
          code: e.code,
          message: e.message,
        );
      } else {
        rethrow;
      }
    }
  }

  //for other implementation see **file:lib/data_source/user_repository.dart** 

  //The idea here is to implement the interface defined in the service layer.
  //and catch errors thrown by the used library and throw custom error classes instead
  // (read library documentation to know about thrown errors). 

}
```
# infrastructure
**file:lib/data_source/apple_sign_in_available.dart**
This file is put in the infrastructure folder instead of the data_source folder because it does not instantiate andy entity or value object from the domain layer.

> If a class instantiated or persist an entity or a value_object put it in the data_source folder otherwise in the infrastructure folder.

```dart
class AppleSignInChecker implements IAppleSignInChecker {
  Future<bool> check() async {
    return await AppleSignIn.isAvailable();
  }
}
```
`AppleSignInChecker` and `UserRepository` can be easily mocked or replaced by other libraries without affecting the core of our app.

# UI:
**file:lib/ui/main.dart**

We want the "user" once signed in to be available in all the widget tree. For this reason, we should inject it to the topmost widget before the `MaterialApp` widget.
The UI layer never instantiates anything from the domain layer, rather it must delegate to objects in the service layer. In our case, we will inject the `UserService` because it is responsible for instantiating the `user`.

```dart
main() {
  runApp(
    Injector(
      inject: [
        //NOTE1: Injecting the apple_sign_in plugging
        Inject(() => AppSignInCheckerService(AppleSignInChecker())),
        //NOTE1: Injecting the UserService class
        Inject(() => UserService(userRepository: UserRepository()))
      ],
      builder: (context) {
        return MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  // NOTE2 Getting the ReactiveModel singletons of UserService and AppSignInCheckerService
  final userServiceRM = Injector.getAsReactive<UserService>();
  final appleCheckerRM = Injector.getAsReactive<AppSignInCheckerService>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //NOTE3: Use of WhenRebuilder to subscribe to userServiceRM and appleCheckerRM
      home: WhenRebuilder<UserService>(
        models: [userServiceRM.asNew('main_widget'), appleCheckerRM],
        //NOTE4: Check if can sign with apple and get the current registered user if any
        initState: (_, userServiceRM) {
          appleCheckerRM.setState((s) => s.check());
          userServiceRM.setState((s) => s.currentUser());
        },
        //NOTE4: If any of appleCheckerRM or userServiceRM is in the waiting state show a SplashScreen
        onWaiting: () => SplashScreen(),
        //NOTE4: If any of appleCheckerRM or userServiceRM is has error, display it
        onError: (error) => Text(error.toString()),
        //NOTE4: If Both appleCheckerRM and appleCheckerRM have date, onDate is called
        onData: (_) {
          return StateBuilder(
            //NOTE5: Subscribe to the reactiveModel singleton
            models: [userServiceRM],
            builder: (_, __) {
              //NOTE6: depending of he user we are directed to SignInPage or HomePage
              return userServiceRM.state.user == null
                  ? SignInPage()
                  : HomePage();
            },
          );
        },
      ),
    );
  }
}
```

With `states_rebuilder` plugging can be injected using `Injector` inside runApp method without the need to make the main method async and call `WidgetsFlutterBinding.ensureInitialized()` method [Note1].

after getting the ReactiveModels [NOTE2], We choose to use `WhenRebuilder` widget. It is useful if we want to register to one or many observable ReactiveModel and exhaustively define the widget to display in each of the fore status (onIdle, OnWaiting, onError, onData) [NOTE3]. If many observable ReactiveModel are defined in the `models` list as in our case, a combined state is exposed, that is the `onDate` will not be called until all models have data, and if any model has en error the onError is invoked with the error. The same with the case of one model is in the waiting state [NOTE4].

`WhenRebuilder` is a StatefulWidget and in its initState hook we check and currentUser method of the appleCheckerRM and userServiceRM respectively using the `setState` method [NOTE4].

NOTICE in the models parameter list :

```dart
models: [userServiceRM.asNew('main_widget'), appleCheckerRM],
```
We subscribe to a new reactive model of `userServiceRM`.

> `ReactiveModel.asNew([dynamic seed])` returns a new reactiveModel of the same registered row model. The seed parameter is optional and if not given a default seed is used.

>seed here has a similar meaning in random number generator. That is for the same seed we get the same new reactive instance.

This is important because we do not want the  `WhenRebuilder` to be notified by any ReactiveModel other than the ReactiveModel registered with the provided seed `main_widget`.

> In states_rebuilder one model can be wrapped with many independent ReactiveModels

If you register `WhenRebuilder` with the singleton Reactive model `userServiceRM`, any time `userServiceRM` the emits a notification even from other widgets or pages this `WhenRebuilder` will rebuild. and this is what we want for the `StateBuilder` of [NOTE5] because in the `signInPage` we want to notify this `StateBuilder` to rebuild after the signing process to display the `HomePage`.

>ReactiveModel singleton is useful for cross view and widget notification and new ReactiveModel are very useful to limit the rebuild in a single view or widget.

>If you grasp the concept of ReactiveModel (singleton and new instances) and as well as the concept of filterTags and watch, you can achieve the finest rebuild of your widget tree and this is above the bonus of boilerplateless and vanilla row models.

Depending on the current value of the `UserService.user` we are directed to `SignInPage` or `HomePage``

## pages
I suggest dedicating a folder for each page that contains dart files linked to the page. The entry file will be the will have the same name as the folder name. This improves readability because all related files are in the same place. Compare it with the case where you put all files in the widgets folder. Widgets folder should contain only small, reusable, and app independent widgets.

The first page is the login page. 
**file:lib/ui/pages/sign_in_page/sign_in_page.dart**
```dart
class SignInPage extends StatelessWidget {
  //NOTE1: Getting the bool canSignInWithApple value
  final bool canSignInWithApple =
      Injector.get<AppSignInCheckerService>().canSignInWithApple;
  //NOTE1: Getting the Singleton ReactiveModel of UserService
  final userServiceRM = Injector.getAsReactive<UserService>();
  //NOTE1: helper getter
  bool get isLoading => userServiceRM.isWaiting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log in')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: SizedBox(
                //NOTE1: Display the CircularProgressIndicator while signing in
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        'Sign In',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                height: 40.0,
              ),
            ),
            SizedBox(height: 32),
            //NOTE2: IF can log with apple 
            if (canSignInWithApple) ...[
              RaisedButton(
                child: Text('Sign in With Apple Account'),
                onPressed: isLoading
                    ? null
                    //call signInWithApple(), and setState and delegate error handling to ExceptionsHandler.showErrorDialog
                    : () => userServiceRM.setState(
                          (s) => s.signInWithApple(),
                          onError: ExceptionsHandler.showErrorDialog,
                        ),
              ),
              SizedBox(height: 8),
            ],
            RaisedButton(
              child: Text('Sign in With Google Account'),
              onPressed: isLoading
                  ? null
                  : () => userServiceRM.setState(
                        (s) => s.signInWithGoogle(),
                        onError: ExceptionsHandler.showErrorDialog,
                      ),
            ),
            SizedBox(height: 8),
            RaisedButton(
              child: Text('Sign in With Email and password'),
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            //Display form screen
                            return SignInRegisterFormPage();
                          },
                        ),
                      );
                    },
            ),
            SizedBox(height: 8),
            RaisedButton(
              child: Text('Sign in anonymously'),
              onPressed: isLoading
                  ? null
                  : () => userServiceRM.setState(
                        (s) => s.signInAnonymously(),
                        onError: ExceptionsHandler.showErrorDialog,
                      ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
```

The second page is the home page. 
**file:lib/ui/pages/home_page/home_page.dart**
```dart
class HomePage extends StatelessWidget {
  final userServiceRM = Injector.getAsReactive<UserService>();
  User get user => userServiceRM.state.user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              userServiceRM.setState((s) => s.signOut());
            },
          )
        ],
      ),
      body: Center(child: Text('Welcome ${user.email ?? user.uid}!')),
    );
  }
}
```
NOTICE that in `signInPage` and `HomePage` we mutating the value of the `UserService.user` and we are emitting notifications from the singleton reactive model. This means that we are notifying the StateBuilder of the mail.dart file that will rebuild and display `signInPage` or `HomePage` depending on the value of the user
 ```dart
return StateBuilder(
    models: [userServiceRM],
    builder: (_, __) {
        return userServiceRM.state.user == null
            ? SignInPage()
            : HomePage();
    },
);
 ```

 The last page is the form page to sign in or register.
**file:lib/ui/pages/log_in_register_page/log_in_register_page.dart**

```dart
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

//NOTE1: use of StateFulWidget only to hold states not notify them
class FormWidget extends StatefulWidget {
  @override
  _FormWidgetState createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  //NOTE2: getting the userService ReactiveModel as new instance with 'formWidget' as a seed.
  final userServiceRM =
      Injector.getAsReactive<UserService>().asNew('formWidget');

  //NOTE3: Creating a local ReactiveModel<String> for email with empty initial value
  final _emailRM = ReactiveModel.create('');
  
  //NOTE3: Creating a local ReactiveModel<String> for password with empty initial value
  final _passwordRM = ReactiveModel.create('');

  //NOTE3: Creating a local ReactiveModel<bool> for isRegister with false initial value
  final _isRegisterRM = ReactiveModel.create(false);

  //NOTE4: bool getter to check if the form is valid
  bool get _isFormValid => _passwordRM.hasData && _passwordRM.hasData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StateBuilder(
            //NOTE5: subscribe to _emailRM
          models: [_emailRM],
          builder: (_, __) {
            return TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
                //NOTE6: Delegate to ExceptionsHandler.errorMessage for error handling 
                errorText: ExceptionsHandler.errorMessage(_emailRM.error).message,
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onChanged: (email) {
                //NOTE7: set the value of email and notify observers
                _emailRM.setValue(
                  () => Email(email).value,
                  catchError: true,
                );
              },
            );
          },
        ),
        StateBuilder(
        //NOTE5: subscribe to _passwordRM
          models: [_passwordRM],
          builder: (_, __) {
            return TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'Password',
                //NOTE6: Delegate to ExceptionsHandler.errorMessage for error handling 
                errorText: ExceptionsHandler.errorMessage(_passwordRM.error).message,
              ),
              obscureText: true,
              autocorrect: false,
              onChanged: (password) {
                //NOTE7: set the value of email and notify observers
                _passwordRM.setValue(
                  () => Password(password).value,
                  catchError: true,
                );
              },
            );
          },
        ),
        SizedBox(height: 10),
        StateBuilder(
            //NOTE5: subscribe to _isRegisterRM
            models: [_isRegisterRM],
            builder: (_, __) {
              return Row(
                children: <Widget>[
                  Checkbox(
                    value: _isRegisterRM.value,
                    onChanged: (value) {
                      //NOTE7: set the value of _isRegisterRM and notify observers
                      _isRegisterRM.setValue(() => value);
                    },
                  ),
                  Text(' I do not have an account'),
                ],
              );
            },
        ),
        StateBuilder(
          //NOTE8: subscribe to all the ReactiveModels
          //_emailRM, _passwordRM: to activate/deactivate the button if the form is valid/non valid
          //_isRegisterRM: to toggle the button text between Register and sing in depending on the checkbox value
          //userServiceRM: To show CircularProgressIndicator is the state is waiting
          models: [_emailRM, _passwordRM, _isRegisterRM, userServiceRM],
          builder: (_, __) {
            //NOTE8: show CircularProgressIndicator is the userServiceRM state is waiting
            if (userServiceRM.isWaiting) {
              return Center(child: CircularProgressIndicator());
            }

            return RaisedButton(
              //NOTE8: toggle the button text between 'Register' and 'Sign in' depending on the checkbox value
              child: _isRegisterRM.value ? Text('Register') : Text('Sign in'),
              //NOTE8: activate/deactivate the button if the form is valid/non valid
              onPressed: _isFormValid
                  ? () {
                      //NOTE9: If _isRegisterRM.value is true call createUserWithEmailAndPassword,
                      if (_isRegisterRM.value) {
                        userServiceRM.setState(
                          (s) => s.createUserWithEmailAndPassword(
                            _emailRM.value,
                            _passwordRM.value,
                          ),
                          onData: (_, __) {
                            Navigator.pop(context);
                          },
                          catchError: true,
                        );
                      } else {
                      //NOTE9: If _isRegisterRM.value is true call signInWithEmailAndPassword,
                        userServiceRM.setState(
                          (s) => s.signInWithEmailAndPassword(
                            _emailRM.value,
                            _passwordRM.value,
                          ),
                          onData: (_, __) => Navigator.pop(context),
                          catchError: true,
                        );
                      }
                    }
                  : null,
            );
          },
        ),
        StateBuilder(
          models: [userServiceRM],
          builder: (_, __) {
            //NOTE10: Display an error message telling the user what goes wrong.
            if (userServiceRM.hasError) {
              return Center(
                child: Text(
                  ExceptionsHandler.errorMessage(userServiceRM.error).message,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return Text('');
          },
        ),
      ],
    );
  }
}

```
First, we are using StatefulWidget here not for state management but only as a state holder [NOTE1].

a new instance of the userService Reactive model is obtained using `Injector.getAsReactive` providing a seed value 'formWidget' [NOTE2]. We get a new reactive model instance because the `FormWidget` should not be affected by other `userServiceRM` declared in other widgets and at the same time, we don't want the `userServiceRM` declared here to affect other widgets.

In other words, If `userServiceRM` declared here issues a notification, it will notify only observers subscribed to this `userServiceRM` instance and will not notify observers subscribed to other instances of `userServiceRM`.

In [NOTE3] we are creating local ReactiveModel form primitive values:
* emailRM: to hold the email,
* passwordRM: to hold the password,
* isRegisterRM: to hold a bool value telling if the user wants to register or sign in.

The `ReactiveModel.create` constructor is useful with primitive values, enumerations, and immutable objects. It makes them reactive so that observer widgets can subscribe to them,[NOTE5], and receive notification from them to rebuild [NOTE7]. 

> Reactive models created using `ReactiveModel.create` has all the features the reactive models created using `Injector` have.

>`setValue` is similar to `setState` but it is more convenient for mutating primitives or immutable objects.

The StateBuilder that wraps the RaisedButton is special because it needs to rebuild:
* Each time the value of the email changes
* Each time the value of the password changes
* Each time the checkbox state is changed
* Each time the userServiceRM status change 

For these purposes, it is subscribed to all four ReactiveModels [NOTE8]: 
* _emailRM, _passwordRM: to activate/deactivate the button if the form is valid/non valid
* _isRegisterRM: to toggle the button text between Register and sing in depending on the checkbox value
* userServiceRM: To show CircularProgressIndicator is the state is waiting

And finally, errors are displayed under the RaisedButton [NOTE10].

## exceptions
Here we will handle errors thrown from inner layers.

there is one class:
**file:lib/ui/exceptions/exceptions_handler.dart**

```dart

class ExceptionsHandler {
  static ErrorMessage errorMessage(dynamic error) {
    if (error == null) {
      return ErrorMessage();
    }
    if (error is SignInException) {
      return ErrorMessage(message: error.message, title: error.title);
    }

    if (error is ValidationException) {
      return ErrorMessage(message: error.message);
    }
    throw error;
  }

  static void showErrorDialog(BuildContext context, dynamic error) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(errorMessage(error).title),
          content: Text(errorMessage(error).message),
        );
      },
    );
  }
}

class ErrorMessage {
  final String title;
  final String message;

  ErrorMessage({this.title, this.message});
}
```