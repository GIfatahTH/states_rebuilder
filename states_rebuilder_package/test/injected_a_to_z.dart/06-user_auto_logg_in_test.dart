import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/* --- Models --*/
//Simple user model
class User {
  final String userId;
  final String token;

  User({required this.userId, required this.token});
}

//Null or unauthenticated user
class NullUser extends User {
  NullUser() : super(userId: '', token: '');
}

/* --- Repository --*/
abstract class ILocalStorage {
  //Almost all plugging need to be initialized before used
  Future<ILocalStorage> init();

  T? getValue<T>(String key);
  Future<bool> setValue<T>(String key, T value);
}

abstract class IAuthRepository {
  Future<User> login({required String name, required String email});
}
/* --- data source --*/

//this is an example of using SharedPreferences as our localStorage
class SharedPreferencesImp extends ILocalStorage {
  late SharedPreferences _prefs;
  @override
  Future<ILocalStorage> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  @override
  T getValue<T>(String key) {
    if (T is int) {
      return _prefs.getInt(key);
    }
    /*
    if (T is String) {
      return _prefs.getString(key);
    }
    if (T is double) {
      return _prefs.getDouble(key);
    }
    */
    throw UnimplementedError();
  }

  @override
  Future<bool> setValue<T>(String key, T value) {
    if (T is int) {
      return _prefs.setInt(key, value);
    }
    /*
    if (T is String) {
      return _prefs.setString(key, value);
    }
    if (T is double) {
      return _prefs.setDouble(key, value);
    }
    */
    throw UnimplementedError();
  }
}

class AuthRepositoryImp implements IAuthRepository {
  @override
  Future<User> login({required String name, required String email}) {
    throw UnimplementedError();
  }
}

/* --- Service class (Link between UI and data sources) -- */
class AuthService {
  final ILocalStorage localStorage;
  final IAuthRepository authRepository;
  AuthService({required this.localStorage, required this.authRepository});
  User user = NullUser();
  Future<User> autoLogin() async {
    //final token = localStorage.getValue<String>('User-token');
    //check if token is valid

    //
    //get saved use name and user email
    final userName = localStorage.getValue<String>('User-name');
    final userEmail = localStorage.getValue<String>('User-email');
    if (userName == null || userEmail == null) {
      return user = NullUser();
    }

    //try to auto log in
    return user = await authRepository.login(name: userName, email: userEmail);
  }
}

/* --- functional injection --- */

//use injectedFuture
final localStorage = RM.injectFuture<ILocalStorage>(
  () => SharedPreferencesImp().init(),
);

final authRepository = RM.inject<IAuthRepository>(() => AuthRepositoryImp());

final authService = RM.inject<AuthService>(
  () => AuthService(
    //as the state of localStorage is not available until it is initialized,
    //we have to await for it.
    localStorage: localStorage.state,
    authRepository: authRepository.state,
  ),
  dependsOn: DependsOn({localStorage}),
);

/* -- The UI --*/
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //use of futureBuilder to limit the rebuild to this widget only
    return authService.futureBuilder(
      future: (state, asyncState) => asyncState.then((s) => s.autoLogin()),
      onWaiting: () => Text('Waiting for auto login'),
      // onError: null, // if onError is null, the onData is called instead
      onError: (e) => Text(e.message),
      onData: (_) =>
          authService.state.user is NullUser ? AuthPage() : HomePage(),
    );
  }
}

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Auth Page');
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Product Page : ${authService.state.user.userId}');
  }
}
/* -- Testing --*/
// mocking

class FakeLocalStorage implements ILocalStorage {
  final bool shouldThrow;
  //FakeLocalStorage can be instantiated with initial values
  //used for test (see later)
  final Map<String, dynamic>? preFilledValue;

  FakeLocalStorage({this.preFilledValue, this.shouldThrow = false});
  //
  late Map<String, dynamic> _prefs;
  @override
  Future<ILocalStorage> init() async {
    await Future.delayed(Duration(seconds: 1));
    if (shouldThrow) {
      throw Exception('Some Error message');
    }
    _prefs = preFilledValue ?? {};
    return this;
  }

  @override
  T? getValue<T>(String key) {
    try {
      return _prefs[key];
    } catch (e) {
      throw Exception('Local storage error');
    }
  }

  @override
  Future<bool> setValue<T>(String key, T value) async {
    await Future.delayed(Duration(seconds: 1));
    _prefs[key] = value;
    return true;
  }
}

class FakeAuthRepository extends IAuthRepository {
  FakeAuthRepository();
  @override
  Future<User> login({required String name, required String email}) async {
    //
    await Future.delayed(Duration(seconds: 1));

    if (name == 'user-1') {
      return User(userId: 'user-1', token: 'token-1');
    }
    return NullUser();
  }
}

//
void main() {
  // inject the fake implementations
  localStorage.injectFutureMock(() {
    return FakeLocalStorage().init();
  });
  authRepository.injectMock(() => FakeAuthRepository());
  testWidgets('First build with no user auto logged', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: MyApp(),
    ));
    //localStorage is waiting for init method
    expect(localStorage.isWaiting, isTrue);
    expect(() => (localStorage.state as FakeLocalStorage), throwsArgumentError);
    //authService is waiting because localStorage is waiting
    expect(authService.isWaiting, isTrue);
    expect(find.text('Waiting for auto login'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    //localStorage is successfully initialized
    expect(localStorage.hasData, isTrue);
    expect((localStorage.state as FakeLocalStorage)._prefs, isNotNull);

    //No user is auto logged in, we expect to see the AuthPage
    expect(find.byType(AuthPage), findsOneWidget);
  });

  testWidgets('initial start with an auto logged user', (tester) async {
    //pre persist the auto logged user data
    localStorage.injectFutureMock(
      () {
        return FakeLocalStorage(preFilledValue: {
          'User-Token': 'user-1-token',
          'User-name': 'user-1',
          'User-email': 'user-1@mail.com'
        }).init();
      },
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MyApp(),
      ),
    );
    //
    //localStorage is waiting for init method
    expect(localStorage.isWaiting, isTrue);
    // expect(() => (localStorage.state as FakeLocalStorage), throwsArgumentError);
    //authService is waiting because localStorage is waiting
    expect(authService.isWaiting, isTrue);
    expect(find.text('Waiting for auto login'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    //localStorage is successfully initialized
    expect(localStorage.hasData, isTrue);
    expect((localStorage.state as FakeLocalStorage)._prefs, isNotNull);
    //We are waiting for autoLogin method
    expect(find.text('Waiting for auto login'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    // the user is auto logged in, we expect to see the HomePage
    expect(find.byType(HomePage), findsOneWidget);
  });

  //
  testWidgets('initial build with error ', (tester) async {
    localStorage.injectFutureMock(
      () {
        return FakeLocalStorage(shouldThrow: true).init();
      },
    );
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: MyApp(),
    ));
    //
    //localStorage is waiting for init method
    expect(localStorage.isWaiting, isTrue);
    // expect(() => (localStorage.state as FakeLocalStorage), throwsArgumentError);//TODO
    //authService is waiting because localStorage is waiting
    expect(authService.isWaiting, isTrue);
    expect(find.text('Waiting for auto login'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    //the localStorage fails to initialize and throws an error
    expect(localStorage.hasError, isTrue);
    //the authService has error because the localStorage has error
    expect(authService.hasError, isTrue);
    expect(find.text('Some Error message'), findsOneWidget);
    //
  });
}
//

//

class SharedPreferences {
  static Future<SharedPreferences> getInstance() async {
    return SharedPreferences();
  }

  getInt(String key) {}
  setInt(key, value) {}
}
