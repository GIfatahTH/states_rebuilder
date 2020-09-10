import 'package:double_future_counter_with_error/counter_error.dart';
import 'package:double_future_counter_with_error/counter_page_1.dart';
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
    await tester.tap(iconButtons.first);
    await tester.pump();

    //on waiting state, two CircularProgressIndicators are expected
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));

    await tester.pump(Duration(seconds: 1));
    //on Data State
    //CircularProgressIndicators disappear
    expect(find.byType(CircularProgressIndicator), findsNothing);

    //Two '1' are expected
    expect(find.text('1'), findsNWidgets(2));
  });

  testWidgets('async increment ends with error', (tester) async {
    await tester.pumpWidget(app);
    //OnIdle:  Welcome screen
    expect(find.text(onIdleString), findsNWidgets(2));

    //set fake model to throw an error
    (Injector.get<CounterService>() as FakeCounterService).shouldThrow = true;

    //Tap on the second  button
    await tester.tap(iconButtons.last);
    await tester.pump();

    //on waiting state, two CircularProgressIndicators are expected
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));

    //await for 3 seconds
    await tester.pump(Duration(seconds: 3));
    //on error State,

    //expect three error message, two in the body and one in the Snackbar
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
