import 'package:clean_architecture_dane_mackier_app/domain/entities/user.dart';
import 'package:clean_architecture_dane_mackier_app/service/authentication_service.dart';
import 'package:clean_architecture_dane_mackier_app/service/common/input_parser.dart';
import 'package:clean_architecture_dane_mackier_app/service/exceptions/fetch_exception.dart';
import 'package:clean_architecture_dane_mackier_app/service/exceptions/input_exception.dart';
import 'package:clean_architecture_dane_mackier_app/ui/pages/login_page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  Widget loginPage;
  Finder loginBtn = find.byType(FlatButton);
  Finder loginTextField = find.byType(TextField);

  setUp(() {
    Injector.enableTestMode = true;
    loginPage = Injector(
      inject: [
        Inject<AuthenticationService>(() => FakeAuthenticationService())
      ],
      builder: (_) => MaterialApp(
        initialRoute: 'login',
        routes: {
          '/': (_) => Text('This is the HomePage'),
          'login': (_) => LoginPage(),
        },
      ),
    );
  });

  testWidgets('display "The entered value is not a number" message',
      (tester) async {
    await tester.pumpWidget(loginPage);
    final String notNumberError = NotNumberException().message;
    // before tap, no error message
    expect(find.text(notNumberError), findsNothing);

    await tester.tap(loginBtn);
    await tester.pump();
    //after tap, error message appears
    expect(find.text(notNumberError), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);

    //enter non number string,
    await tester.enterText(loginTextField, '1m');

    await tester.tap(loginBtn);
    await tester.pump();
    //after tap, error message appears
    expect(find.text(notNumberError), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('display "The entered value is not between 1 and 10" message',
      (tester) async {
    await tester.pumpWidget(loginPage);
    final String notInRangeError = NotInRangeException().message;
    // before tap, no error message
    expect(find.text(notInRangeError), findsNothing);

    //enter -1,
    await tester.enterText(loginTextField, '-1');

    await tester.tap(loginBtn);
    await tester.pump();
    expect(find.text(notInRangeError), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);

    //enter 11
    await tester.enterText(loginTextField, '11');

    await tester.tap(loginBtn);
    await tester.pump();
    //after tap, error message appears
    expect(find.text(notInRangeError), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets(
      'display "A NetWork problem" after showing CircularProgressBarIndictor',
      (tester) async {
    await tester.pumpWidget(loginPage);
    final String networkErrorException = NetworkErrorException().message;
    // before tap, no error message
    expect(find.text(networkErrorException), findsNothing);

    //enter 1,
    await tester.enterText(loginTextField, '1');

    //set fake to throw networkErrorException error
    (Injector.get<AuthenticationService>() as FakeAuthenticationService).error =
        NetworkErrorException();

    await tester.tap(loginBtn);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    //expect find on in the snackBar and one under TextField
    expect(find.text(networkErrorException), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets(
      'display "No user find with this number" after showing CircularProgressBarIndictor',
      (tester) async {
    await tester.pumpWidget(loginPage);
    final String userNotFoundException = UserNotFoundException(1).message;
    // before tap, no error message
    expect(find.text(userNotFoundException), findsNothing);

    //enter 1,
    await tester.enterText(loginTextField, '1');

    //set fake to throw userNotFoundException error
    (Injector.get<AuthenticationService>() as FakeAuthenticationService).error =
        UserNotFoundException(1);

    await tester.tap(loginBtn);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    //expect find on in the snackBar and one under TextField
    expect(find.text(userNotFoundException), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets(
      'show CircularProgressBarIndictor and navigate to homePage after successful login',
      (tester) async {
    await tester.pumpWidget(loginPage);

    //enter 1,
    await tester.enterText(loginTextField, '1');

    await tester.tap(loginBtn);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(ReactiveModel<AuthenticationService>().hasData, isTrue);
    expect(ReactiveModel<AuthenticationService>().state.user.id, equals(1));

    //await page animation to finish
    await tester.pump(Duration(seconds: 1));
    expect(find.text('This is the HomePage'), findsOneWidget);
  });
}

class FakeAuthenticationService extends AuthenticationService {
  dynamic error;

  User _fetchedUser;

  @override
  User get user => _fetchedUser;

  @override
  Future<void> login(String userIdText) async {
    var userId = InputParser.parse(userIdText);

    await Future.delayed(Duration(seconds: 1));

    if (error != null) {
      throw error;
    }

    _fetchedUser = User(id: userId, name: 'fakeName', username: 'fakeUserName');
  }
}
