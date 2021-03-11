Read me to be updated
<!-- # ex_009_1_4_ca_todo_mvc_with_state_persistence_and_user_auth

 [Make sure you have read this example before going on](../ex_009_1_3_ca_todo_mvc_with_state_persistence) 


The example consists of the [Todo MVC app](https://github.com/brianegan/flutter_architecture_samples/blob/master/app_spec.md) extended to: 
* Handle dynamic dark/light theme and app internationalization.
* Users can sign up / sign in and see their proper todos.
* Sign in is done with a token that when expired the signed user automatically logs out.
* User information is persisted so user will be auto-logged when app started if token is not expired.

The app state will be stored using SharedPreferences, Hive, and sqflite for demonstration purposes.

## Setting up the Backend:
We will use Firebase as a dummy web server, knowledge here applies to any web server:
1. Create a firebase project. 
2. create a real-time database and start in test mode.
3. notice the generated URL which we will use. If your project name is YOUR_PROJECT_NAME the generated URL is https://YOUR_PROJECT_NAME.firebaseio.com/. This will be your `baseUrl` const.
5. change the security rule to read and write `auth != null` so that only authenticated users can read and write. (see here)[https://firebase.google.com/docs/database/security].
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
  }
}
```
6. under authentication tap unlock email and password sign in. (see here)[https://firebase.google.com/docs/reference/rest/auth/#section-sign-in-email-password]
7. Go to https://console.firebase.google.com/project/YOUR_PROJECT_NAME/settings/general and get `webApiKey`. This will be your `webApiKey` const.

## Authentication
After creating :
*  a `User` entity. [See here](lib/domain/entities/user.dart)
* and a `IAuthRepository` interface. [See here](lib/service/interfaces/i_auth_repository.dart)

we implement the defined `IAuthRepository` to use the firebase auth API.

[Refer to FireBaseAuth class](lib/data_source/firebase_auth_repository.dart)
```dart
const webApiKey = PUT_YOUR_WEB_API_HERE;


class FireBaseAuth implements IAuthRepository {
  @override
  Future<User> login(String email, String password) {
    return _authenticate(email, password, 'verifyPassword');
  }

  @override
  Future<User> signUp(String email, String password) {
    return _authenticate(email, password, 'signupNewUser');
  }

  @override
  Future<void> logout() async {
    //
  }

  Future<User> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=$webApiKey';
   
      var response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw AuthException(responseData['error']['message']);
      }

      return User(
          userId: responseData['localId'],
          email: email,
          token: Token(
            token: responseData['idToken'],
            expiryDate: DateTimeX.current.add(
              Duration(
                seconds: int.parse(
                  responseData['expiresIn'],
                ),
              ),
            ),
          ));
  }
}
```

Now, all we need is to inject the `IAuthRepository`, and `User` :

```dart

final authRepository = RM.inject<IAuthRepository>(() => FireBaseAuth());

//add an extension to user to handle sign up / in and logout
//We can use simple class
extension UserX on User {
  Future<User> signUp(String email, String password) async {
    return await authRepository.state.signUp(email, password);
  }

  Future<User> login(String email, String password) async {
    return await authRepository.state.login(email, password);
  }

  User logout() {
    authRepository.state.logout();
    return UnsignedUser();
  }
}

final user = RM.inject<User>(
  () => UnsignedUser(),
  //As We want the logged user to be available throughout the whole app life cycle,
  //we prevent it from auto disposing of the injected model.
  //
  //As for the app, nothing will be affected. The only issue is when testing the app.
  //To allow tests to pass, it is preferable to manually dispose of the app when the app is disposed of.
  autoDisposeWhenNotUsed: false,
  //
  //We want to the logged user
  persist: () => PersistState(
    key: '__UserToken__',
    toJson: (user) => user.toJson(),
    fromJson: (json) {
      final user = User.fromJson(json);
      //Check the persisted user token validity and return null if it is expired
      return user.token?.isAuth == true ? user : null;
    },
  ),

  //Executed once the user is first initialized
  onInitialized: (User u) {
    if (u != null && u is! UnsignedUser) {
        //If we get a valid user from the persistence, we start the Expiration timer
      _setExpirationTimer(u.token);
    }
  },
  //
  //Executed each time the user state change without error
  onData: (User u) {
    if (u is UnsignedUser) {
        //If the user is logged out, stop timer and navigate to authPage
      _cancelExpirationTimer();
      //Navigate and remove all routes in the stack
      RM.navigate.toAndRemoveUntil(const AuthPage());
    } else {
        //If the user is valid, set the expiration timer and navigate to HomeScreen
      _setExpirationTimer(u.token);
      RM.navigate.toAndRemoveUntil(const HomeScreen());
    }
  },
  onError: (e, s) {
    //Show snackBar on error
    ErrorHandler.showErrorSnackBar(e);
  },
  onDisposed: (_) {
      //cancel timer on app exiting
    _cancelExpirationTimer();
  },
);

Timer _authTimer;
void _setExpirationTimer(Token token) {
  _cancelExpirationTimer();
  final timeToExpiry = token.expiryDate.difference(DateTimeX.current).inSeconds;
  _authTimer = Timer(
    Duration(seconds: timeToExpiry),
    () {
      user.state = user.state.logout();
    },
  );
}

void _cancelExpirationTimer() {
  if (_authTimer != null) {
    _authTimer.cancel();
    _authTimer = null;
  }
}
```

In the UI part:

```dart
  MaterialApp(

    //First await for the user to auto authenticate
    home: user.futureBuilder(
        //Display a splashScreen while authenticating
        onWaiting: () => SplashScreen(),
        //On Error display the authPage and a Snackbar with the error as defined
        //in onError callback of the user injected model.
        onError: (_) => AuthPage(),

        onData: (_) => Container(),//Never reached
    ),
  ),
```

For the AuthPage [see here](lib/ui/pages/auth_page/auth_page.dart).

## TODOs logic

This will be similar to  [this example](../ex_009_1_3_ca_todo_mvc_with_state_persistence) except that here todos are scoped to the users.

As todos will be stored in firebase API, we first create a class that implements the `IPersistStore`

```dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:states_rebuilder/states_rebuilder.dart';

const baseUrl = PUT_YOUR_BASE_URL; 

class FireBaseTodosRepository implements IPersistStore {
  final String authToken;

  FireBaseTodosRepository({
    @required this.authToken,
  });

  @override
  Future<void> init() async {}

  @override
  Object read(String key) async {
    final response = await http.get('$baseUrl/$key.json?auth=$authToken');
    if (response.statusCode > 400) {
      throw Exception();
    }
    return response.body;
  }

  @override
  Future<void> write<T>(String key, T value) async {
    final response =
        await http.put('$baseUrl/$key.json?auth=$authToken', body: value);
    if (response.statusCode >= 400) {
      throw Exception();
    }
  }

  @override
  Future<void> delete(String key) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll() {
    throw UnimplementedError();
  }
}

```

Compared the the [last example](../ex_009_1_3_ca_todo_mvc_with_state_persistence) , this is the only change you have to do to scop todos to users and use fireStore (or any other service) as backend:

```dart
final Injected<List<Todo>> todos = RM.inject(
    () => [],
    persist: () => PersistState(
         //The key will be dynamic and has the user id information
          key: '__Todos__/${user.state.userId}',
          toJson: (todos) => todos.toJson(),
          fromJson: (json) => ListTodoX.fromJson(json),
          //The persistState will not use the default one as use by the themeData and localization
          //Rather we will use the FireBaseTodosRepository that implements IPersistStore
          persistStateProvider: FireBaseTodosRepository(
            authToken: user.state.token.token,
          ),
        ),
    onError: (e, s) {
      ErrorHandler.showErrorSnackBar(e);
    }
);
``` -->