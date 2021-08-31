//OK
Authentication and authorization are yet other common tasks that states_rebuilder encapsulates to hide their implementation details and expose a clean and simple API to handle sign up, sign in, sign out, auto-sign in with a cached user, or auto sign out when a token has expired.

# Table of Contents <!-- omit in toc --> 
- [IAuth interface](#IAuth-interface)  
- [InjectedAuth](#InjectedAuth)  
  - [repository](#repository)  
  - [unsignedUser](#unsignedUser)  
  - [param](#param)  
  - [onSigned](#onSigned)  
  - [onUnsigned](#onUnsigned)  
  - [autoSignOut](#autoSignOut)  
  - [persist](#persist)  
- [OnAuthBuilder](#OnauthBuilder)
- [signUp](#signUp)  
  - [param](#param)  
  - [onAuthenticated](#onAuthenticated)  
  - [onError](#onError)  
- [signIn](#signIn)  
- [signOut](#signOut)  
  - [onSignOut](#onSignOut)  
- [Get the repository](#Get-the-repository)  
- [Testing and injectAuthMock](#Testing-and-injectAuthMock)  




## IAuth interface:

Similar to `RM.injectCRUD`, you need to implement the` IAuth` interface.

```dart
class AuthRepository implements IAuth<User, UserParam> {
  @override
  Future<void> init() {
    // Initialize pluggings
  }

  @override
  Future<User> signUp(UserParam? param) async {
    // Sign app
    //You can call many signing up provider here.
    //use param to distinguish them
  }

  @override
  Future<User> signIn(UserParam? param) {
    // sign in
  }

  @override
  Future<void> signOut(UserParam? param) {
    // Sign out
  }

  @override
  void dispose() {
    // Dispose resources
  }
}
```


This is an example of an app that uses firebase auth.
<details>
  <summary>Click to expand!</summary>

```dart

class UserParam {
  final String email;
  final String password;
  final SignIn signIn;
  final SignUp signUp;
  UserParam({
    this.email,
    this.password,
    this.signIn,
    this.signUp,
  });
}

enum SignIn {
  anonymously,
  withApple,
  withGoogle,
  withEmailAndPassword,
  currentUser,
}
enum SignUp { withEmailAndPassword }


class UserRepository implements IAuth<User, UserParam> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<void> init() async {}

  @override
  Future<User> signUp(UserParam param) {
    switch (param.signUp) {
      case SignUp.withEmailAndPassword:
        return _createUserWithEmailAndPassword(
          param.email,
          param.password,
        );
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<User> signIn(UserParam param) {
    switch (param.signIn) {
      case SignIn.anonymously:
        return _signInAnonymously();
      case SignIn.withApple:
        return _signInWithApple();
      case SignIn.withGoogle:
        return _signInWithGoogle();
      case SignIn.withEmailAndPassword:
        return _signInWithEmailAndPassword(
          param.email,
          param.password,
        );
      case SignIn.currentUser:
        return _currentUser();

      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut(UserParam param) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    return _firebaseAuth.signOut();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  Future<User> _signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final AuthResult authResult =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw SignInException(
          title: 'Sign in with email and password',
          code: e.code,
          message: e.message,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<User> _createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      AuthResult authResult =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fromFireBaseUserToUser(authResult.user);
    } catch (e) {
      if (e is PlatformException) {
        throw SignInException(
          title: 'Create use with email and password',
          code: e.code,
          message: e.message,
        );
      } else {
        rethrow;
      }
    }
  }

    .
    .
    .


}


```
</details>

## InjectedAuth

suppose our `InjectedAuth` state is named `user`.


```dart
InjectedAuth<T, P> user =  RM.injectAuth<T, P>(
    IAuth<T, P> Function() repository, {
    required T unsignedUser,
    P Function()? param,
    void Function(T s)? onSigned,
    void Function()? onUnsigned,
    Duration Function(T auth)? autoSignOut,
    PersistState<T> Function()? persist,
    //Similar to other Injected
    SnapState<T> Function(MiddleSnapSate<T> ) middleSnapState,
    void Function(T s)? onInitialized,
    void Function(T s)? onDisposed,
    On<void>? onSetState,
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    bool autoDisposeWhenNotUsed = false,
    String? debugPrintWhenNotifiedPreMessage,
  })
```

### repository:
This is the repository that implements the `IAuth` interface.

## unsignedUser
This is the `unsignedUser` object. It is used internally in the decision logic of the library. Usually, the `UnsignedUser` extends your User class.

example:
```dart
class User{
  final String name;
  .
  .
}

class UnsignedUser extends User{}
```

### param:
This is the default param. It is used to parametrize the query that is sent to the backend to authenticate. It may be used to switch between many authentication providers. `signUp`, `signIn`, and `signOut` methods may override it. (See later).

### onSigned:
Hook to be invoked when the user is signed in or up. It exposes the current user. This is the right place to navigate to the home or user page. This `onSigned` is considered as the default callback when the user is signed. It can be overridden when calling `signIn` and `signUp` methods (See later).

### onUnsigned:
Hook to be invoked when the user is signed out. This is the right place to navigate to the auth page.

example:
```dart
final user = RM.injectAuth(
  () => UserRepository(),
  unsignedUser: UnSignedUser(),
  onSigned: (_) => RM.navigate.toReplacement(HomePage()),
  onUnsigned: () => RM.navigate.toReplacement(SignInPage()),
  //Display error message on signing failure
  onSetState: On.error(
    (err) => AlertDialog(
      title: Text(ExceptionsHandler.errorMessage(err).title),
      content: Text(ExceptionsHandler.errorMessage(err).message),
    ),
  ),
);
```
For the remainder of the parameters see [`Injected` API](rm_injected_api).
### autoSignOut
A callback that exposes the signed user and returns a duration. If defined a timer is set to the return duration, and when the timer ends, the user is signed out.

The duration information can be obtained from the exposed user token.

### persist
When persist is defined the signed user information is persisted and when the app starts up, the user information is retrieved from the local storage and it is automatically signed in if it has no expired token.

Example:

```dart
final user = RM.injectAuth<User, UserParam>(
  () => FireBaseAuth(),
  unsignedUser: UnsignedUser(),
  persist: () => PersistState<User>(
    key: '__User__',
    toJson: (user) => user.toJson(),
    fromJson: (json) {
      final user = User.fromJson(json);
      return user.token.isNotExpired ? user : UnsignedUser();
    },
  ),
  autoSignOut: (user) {
    //get time to expire from the exposed user
    final timeToExpiry = user.token.expiryDate
        .difference(
          DateTimeX.current,
        )
        .inSeconds;
    //Return a Duration object
    return Duration(seconds: timeToExpiry);
  },
  onSigned: (_) => RM.navigate.toNamedAndRemoveUntil(HomeScreen.routeName),
  onUnsigned: () => RM.navigate.toNamedAndRemoveUntil(AuthPage.routeName),
  onSetState: On.error(ErrorHandler.showErrorSnackBar),
);
```

## OnAuthBuilder
To listen to the InjectedAuth state use `On.Auth`

`OnAuthBuilder` listens to the [InjectedAuth] and waits until the authentication ends.

`onInitialWaiting` is called once when the auth state is initialized.

`onWaiting` is called whenever the auth state is waiting for authentication.

`onUnsigned` is called when the user is signed out. Typically used to render Auth page.


`onSigned` is called when the user is signed. Typically used to render User home page.

By default, the switch between the onSinged and the onUnsigned pages is a simple widget replacement. To use the navigation page transition animation, set [userRouteNavigation] to true. In this case, you need to set the [RM.navigate.navigatorKey].

```dart
OnAuthBuilder(
    listenTo: user,
    onInitialWaiting: ()=> Text('Waiting  on initial..')
    onWaiting: ()=> Text('Waiting..'),
    onUnsigned: ()=> AuthPage(),
    onSigned: ()=> HomeUserPage(),
    useRouteNavigation: false,
    dispose: (){},
    onSetState: On((){}),
    key: Key(),
);
```

## signUp
To signUp, mutate the state and notify the listener, you use the signUp method.

```dart
Future<T> user.auth.signUp(
  P Function(P? parm)? param, {
    void Function()? onAuthenticated, 
    void Function(dynamic err)? onError
  }
)
```
### param
If param is not defined the default param as defined when injecting the state is used. 

The exposed Parm in the callback is the default param, you can use it to copy it and return a new param to be used for this particular call.

### onAuthenticated
Called when use is signed up successfully. If it is defined here, it will override the onSigned callback defined globally when injecting the user.

### onError
Called when the sign up fails, it exposes the thrown error.

example:

```dart
user.auth.signUp(
  (_) => UserParam(
    signUp: SignUp.withEmailAndPassword,
    email: _email.state,
    password: _password.state,
  ),
);
```

## signIn

```dart
Future<T> signIn(
    P Function(P? param)? param, {
    void Function()? onAuthenticated,
    void Function(dynamic error)? onError,
})
```
Similar to signUp.

example:
```dart

user.auth.signIn(
  (_) => UserParam(signIn: SignIn.withApple),
),


user.auth.signIn(
  (_) => UserParam(signIn: SignIn.withGoogle),
)

user.auth.signIn(
  (_) => UserParam(
    signIn: SignIn.withEmailAndPassword,
    email: _email.state,
    password: _password.state,
  ),
)
```
## signOut
```dart
Future<void> signOut({
  P Function(P? param)? param,
  void Function()? onSignOut,
  void Function(dynamic error)? onError,
})
```
### onSignOut
Called when use is signed out successfully. If it is defined here, it will override the `onUnsigned` callback defined globally when injecting the user.

If the user is persisted, when signing out the persisted user is deleted.

## Get the repository
> Update: Before version 4.1.0 getRepoAs return a Future of the repository. And from version 4.1.0 the getRepoAs return the repository object.

If you have custom defined methods in the repository, you can invoke them after getting the repository.

Example from todo app:
```dart
//getting the repository
final repo = user.getRepoAs<FireAuthRepository>();
```
## Testing and injectAuthMock
> UPDATE: From version 4.1.0, default mock must be put inside the setUp method.


It is very easy to test an app built with states_rebuilder.
You only have to implement your repository with a fake implementation.

Example from todo app:
```dart
//Fake implementation of SqfliteRepository
class FakeAuthRepository implements FireAuthRepository {
  
  final dynamic error;
  User fakeUser;
  FakeUserRepository({this.error});

  @override
  Future<void> init() async {}

  @override
  Future<User> signUp(UserParam param) async {
    switch (param.signUp) {
      case SignUp.withEmailAndPassword:
        await Future.delayed(Duration(seconds: 1));
        if (error != null) {
          throw error;
        }
        return User(uid: '1', email: param.email);
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<User> signIn(UserParam param) async {
    switch (param.signIn) {
      case SignIn.withEmailAndPassword:
        await Future.delayed(Duration(seconds: 1));
        if (error != null) {
          throw error;
        }
        throw SignInException(
          title: 'Sign in with email and password',
        );
        return User(uid: '1', email: param.email);
      case SignIn.anonymously:
      case SignIn.withApple:
      case SignIn.withGoogle:
        await Future.delayed(Duration(seconds: 1));
        if (error != null) {
          throw error;
        }
        return _user;
      case SignIn.currentUser:
        await Future.delayed(Duration(seconds: 2));
        return fakeUser ?? UnSignedUser();

      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut(UserParam param) async {
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  void dispose() {}

  User _user = User(
    uid: '1',
    displayName: "FakeUserDisplayName",
    email: 'fake@email.com',
  );

}
```

In test:

```dart
void main() async {
  setUp((){
    //Default and cross test mock must be put in the setUp method
    user.injectAuthMock(() => FakeAuthRepository());
  });


  testWidgets('test 1', (tester) async {
    .
    .
  });

  testWidgets('test 2', (tester) async {
    //mock with some stored Todos
    user.injectCRUDMock(() => FakeAuthRepository(
       error: Exception('Invalid email or password')
       ));
    
    .
    .
  });


```
