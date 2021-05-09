import 'package:async_counter_app_with_injector/home_page.dart';
import 'package:async_counter_app_with_injector/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  setUp(() {
    RM.disposeAll();
    //Here we override the flavor to be FakeCounterStore.
    //
    //We put it inside setUp method so to be applicable for all individual tests
    counterStore.injectMock(() => FakeCounterStore(0));
  });
  testWidgets('async counter without error (IncrByOne flavor)', (tester) async {
    //
    //We choose the flavor
    RM.env = Flavor.IncrByOne;

    await tester.pumpWidget(MyApp());

    //As our navigation is BuildContext free, from here we navigate to MyHomePage
    RM.navigate.to(MyHomePage());
    await tester.pumpAndSettle();
    //
    //We expect the app to display (Increment By one Flavor)
    expect(config.state.appName, 'Increment By one Flavor');
    expect(find.text('Increment By one Flavor'), findsOneWidget);

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
    counterStore.injectMock(() => FakeCounterStore(0)..shouldThrow = true);

    await tester.pumpWidget(MyApp());
    //
    RM.env = Flavor.IncrByOne;
    RM.navigate.to(MyHomePage());
    await tester.pumpAndSettle();
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

  testWidgets('async counter without error (IncrByTwo flavor)', (tester) async {
    await tester.pumpWidget(MyApp());
    //
    //Here we choose IncrByTwo flavor
    RM.env = Flavor.IncrByTwo;
    RM.navigate.to(MyHomePage());
    await tester.pumpAndSettle();
    //
    //We expect the app to display (Increment By one Flavor)
    expect(config.state.appName, 'Increment By two Flavor');
    expect(find.text('Increment By two Flavor'), findsOneWidget);
    //
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

    //on data state, we expect to see the value of 1. (should be 2 but we
    //override it to be 1)
    expect(find.text('1'), findsOneWidget);
  });
}

//fake class must extends the real class
class FakeCounterStore extends ICounterStore {
  FakeCounterStore(this.count);
  int count;
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

  @override
  String toString() {
    return 'FakeCounterStore($count)';
  }
}
