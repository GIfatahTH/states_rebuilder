import 'package:async_counter_app_with_injector/counter_with_injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  Widget myApp;

  setUp(() {
    //set enableTestModel to true so that injector will inject the fake class and ignore there real class
    Injector.enableTestMode = true;
    myApp = Injector(
      //Injecting the fake class but register it with the real class type
      //fake class must extends the real class
      inject: [Inject<CounterStore>(() => FakeCounterStore(0))],
      builder: (_) => MyApp(),
    );
    //whenever Inject.get<CounterStore>() or Inject.getAsReactive<CounterStore>() are called
    // inside MyApp they will return the fake instance
  });

  testWidgets('async counter without error', (tester) async {
    await tester.pumpWidget(myApp);
    //on Idle state, we expect to see the welcoming text
    expect(
      find.text('Tap on the FAB to increment the counter'),
      findsOneWidget,
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    //on Waiting state, we expect to see a CircularProgressIndicator
    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );

    await tester.pump(Duration(seconds: 1));

    //on data state, we expect to see the value of 1.
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('async counter with error', (tester) async {
    await tester.pumpWidget(myApp);

    //Fake class behavior is predictable. we set shouldThrow to true to expect en error
    (Injector.get<CounterStore>() as FakeCounterStore).shouldThrow = true;

    //on Idle state
    expect(
      find.text('Tap on the FAB to increment the counter'),
      findsOneWidget,
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    //on Waiting state
    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );

    await tester.pump(Duration(seconds: 1));

    //on error state, we expect to see the error message
    expect(find.text('A Counter Error'), findsOneWidget);
  });
}

//fake class must extends the real class
class FakeCounterStore extends CounterStore {
  FakeCounterStore(int count) : super(count);

  bool shouldThrow = false;

  @override
  void increment() async {
    await Future.delayed(Duration(seconds: 1));

    //use shouldThrow instead of random in real class to control the behavior of the fake class
    if (shouldThrow) {
      throw Exception('A Counter Error');
    }
    count++;
  }
}
