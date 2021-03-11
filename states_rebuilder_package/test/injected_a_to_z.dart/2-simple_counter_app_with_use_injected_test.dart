import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//Define a global variable 'counter' to hold the a
//reference to the injected creation function of the state.
//
//One demonstration that the state is not global is the easiness to test it.
final Injected<int> counter = RM.inject<int>(
  () => 0,
  //If you set autoClean to false you have to dispose it manually
  autoDisposeWhenNotUsed: false,

  //onDispose will be called when the app is closed
  // onDisposed: (int state) => print('disposed'),
);

class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return On.data(
      () {
        return MaterialApp(
          home: On.data(
            () => Text('${counter.state}'),
          ).listenTo(counter),
        );
      },
    ).listenTo(
      RM.inject(() => ''),
      dispose: () {
        RM.disposeAll();
      },
    );
  }
}

void main() {
  testWidgets('First test : should increment counter', (tester) async {
    await tester.pumpWidget(CounterApp());
    //
    expect(find.text('0'), findsOneWidget);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Second test: should increment counter', (tester) async {
    await tester.pumpWidget(CounterApp());
    //
    //If the state is global this will fail when running all testes
    expect(find.text('0'), findsOneWidget);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Override the mock injection For this test', (tester) async {
    //override the mock injection
    //This will be available only inside this test.
    counter.injectMock(() => 100);

    await tester.pumpWidget(CounterApp());
    //
    //Note '100 'which comes from the overridden mock injection
    expect(find.text('100'), findsOneWidget);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('101'), findsOneWidget);

    //the next test the default counter mock will be used
  });

  testWidgets('Third test: should use the default mock', (tester) async {
    counter.injectMock(() => 0);
    await tester.pumpWidget(CounterApp());
    //
    //Note '0' which comes from the default mock
    expect(find.text('0'), findsOneWidget);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
