import 'package:async_counter_app_with_injector/counter_with_functional_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  counter.injectMock(() => FakeCounterStore(0));

  testWidgets('async counter without error', (tester) async {
    await tester.pumpWidget(MyApp());
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
    //Fake class behavior is predictable. we set shouldThrow to true to expect en error
    counter.injectMock(() => FakeCounterStore(0)..shouldThrow = true);

    await tester.pumpWidget(MyApp());

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
