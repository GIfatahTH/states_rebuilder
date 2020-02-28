import 'package:double_future_counter_with_error/counter_error.dart';
import 'package:double_future_counter_with_error/counter_page_3.dart';
import 'package:double_future_counter_with_error/counter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  Widget app;
  final onIdleString =
      'Top on the plus button to start incrementing the counter';
  final errorMessage = 'A permission error, please contact your administrator';
  Finder iconButtons;
  setUp(
    () async {
      Injector.enableTestMode = true;
      app = Injector(
        inject: [Inject<CounterService>(() => FakeCounterService())],
        builder: (_) => MaterialApp(home: App()),
      );

      iconButtons = find.byIcon(Icons.add_circle);
    },
  );

  testWidgets('async increment ends with data', (tester) async {
    await tester.pumpWidget(app);
    //OnIdle:  Welcome screen
    expect(find.text(onIdleString), findsNWidgets(2));

    //Tap the first  button
    await tester.tap(iconButtons.at(0));
    await tester.pump();

    //on waiting state, one CircularProgressIndicator is expected
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //the other counter is still in the idle state
    expect(find.text(onIdleString), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    //on Data State
    //CircularProgressIndicators disappear
    expect(find.byType(CircularProgressIndicator), findsNothing);

    //one '1' are expected
    expect(find.text('1'), findsOneWidget);
    //the other counter is still in the idle state
    expect(find.text(onIdleString), findsOneWidget);

    //Tap the second  button
    await tester.tap(iconButtons.at(1));
    await tester.pump();

    //on waiting state, one CircularProgressIndicator is expected
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //No counter is in the idle state
    expect(find.text(onIdleString), findsNothing);

    await tester.pump(Duration(seconds: 3));
    //on Data State
    //CircularProgressIndicators disappear
    expect(find.byType(CircularProgressIndicator), findsNothing);

    //the first counter still holds '1'
    expect(find.text('1'), findsOneWidget);
    //the second counter updates to '2
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('async increment ends with error', (tester) async {
    await tester.pumpWidget(app);
    //OnIdle:  Welcome screen
    expect(find.text(onIdleString), findsNWidgets(2));

    //set fake model to throw an error
    (Injector.get<CounterService>() as FakeCounterService).shouldThrow = true;

    //Tap the first  button
    await tester.tap(iconButtons.at(0));
    await tester.pump();

    //on waiting state, one CircularProgressIndicator is expected
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //the other counter is still in the idle state
    expect(find.text(onIdleString), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    //on Error State
    //CircularProgressIndicators disappear
    expect(find.byType(CircularProgressIndicator), findsNothing);

    //one  errorMessage is expected
    expect(find.text(errorMessage), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
    //the other counter is still in the idle state
    expect(find.text(onIdleString), findsOneWidget);

    //Tap the second  button
    await tester.tap(iconButtons.at(1));
    await tester.pump();

    //on waiting state, one CircularProgressIndicator is expected
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    //No counter is in the idle state
    expect(find.text(onIdleString), findsNothing);

    await tester.pump(Duration(seconds: 3));

    //on Error State
    //two errorMessage are expected
    expect(find.text(errorMessage), findsNWidgets(3));
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

class FakeCounterService extends CounterService {
  bool shouldThrow = false;
  @override
  Future<void> increment(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));

    if (shouldThrow) {
      throw CounterError();
    } else {
      counter.increment();
    }
  }
}
