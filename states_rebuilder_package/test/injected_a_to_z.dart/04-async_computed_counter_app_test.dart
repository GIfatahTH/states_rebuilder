import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter1 {
  final int _incrementBy;
  final bool shouldThrow;
  Counter1({int incrementBy = 1, this.shouldThrow = false})
      : _incrementBy = incrementBy;
  int _count = 0;
  int get count => _count * _incrementBy;
  void increment() {
    if (shouldThrow) {
      throw Exception('Counter Error');
    }
    _count++;
  }
}

class Counter2 {
  final int _incrementBy;
  final bool shouldThrow;
  Counter2({int incrementBy = 1, this.shouldThrow = false})
      : _incrementBy = incrementBy;
  int _count = 0;
  int get count => _count * _incrementBy;
  Future<void> increment() async {
    await Future.delayed(Duration(seconds: 1));
    if (shouldThrow) {
      throw Exception('Counter Error');
    }
    _count++;
  }
}

final counter1 = RM.inject(
  () => Counter1(),
);
final counter2 = RM.inject(
  () => Counter2(),
);

final computedCounter = RM.inject<int>(
  () => counter1.state.count * counter2.state.count,
  dependsOn: DependsOn({counter1, counter2}),
);

//this is an example fo a computed counter the depends on another computed counter
final anOtherComputedCounter = RM.inject<String>(
  () => '${computedCounter.state * 10}',
  dependsOn: DependsOn({computedCounter}),
);

int counter1NbrOfRebuilds = 0;
int counter2NbrOfRebuilds = 0;
int computedCounterNbrOfRebuilds = 0;

class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          On.data(() {
            counter1NbrOfRebuilds++;
            return Text('counter1 :${counter1.state.count}');
          }).listenTo(counter1),
          On.all(
            onIdle: () => Text('Idle'),
            onWaiting: () => Text('Waiting...'),
            onError: (e, _) => Text(e.message),
            onData: () {
              counter2NbrOfRebuilds++;
              return Text('counter2 :${counter2.state.count}');
            },
          ).listenTo(counter2),
          On.or(
              onWaiting: () => Text('Waiting...'),
              onError: (e, _) {
                return Text(e.message);
              },
              or: () {
                computedCounterNbrOfRebuilds++;
                return Text('computedCounter :${computedCounter.state}');
              }).listenTo(computedCounter),
          On.data(
            () => Text('rebuilder :${computedCounter.state}'),
          ).listenTo(computedCounter),
        ],
      ),
    );
  }
}

class CounterApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          //this is an example fo a computed counter the depends on another computed counter
          On.or(
            onWaiting: () => Text('Waiting...'),
            onError: (e, _) => Text(e.message),
            or: () {
              computedCounterNbrOfRebuilds++;
              return Text('${anOtherComputedCounter.state}');
            },
          ).listenTo(anOtherComputedCounter),
        ],
      ),
    );
  }
}

void main() {
  setUp(() {
    counter1NbrOfRebuilds = 0;
    counter2NbrOfRebuilds = 0;
    computedCounterNbrOfRebuilds = 0;
    counter1.injectMock(() => Counter1(incrementBy: 2));
    counter2.injectMock(() => Counter2());
  });

  testWidgets('initial state ', (tester) async {
    await tester.pumpWidget(CounterApp());
    //
    expect(find.text('counter1 :0'), findsNWidgets(1));
    expect(find.text('Idle'), findsNWidgets(1));
    expect(find.text('computedCounter :0'), findsNWidgets(1));
    //
    expect(counter1NbrOfRebuilds, 1);
    expect(counter2NbrOfRebuilds, 0);
    expect(computedCounterNbrOfRebuilds, 1);
  });

  testWidgets('increment one counter, change the computed counter',
      (tester) async {
    await tester.pumpWidget(CounterApp());
    //
    counter1.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('counter1 :2'), findsNWidgets(1));
    expect(find.text('Idle'), findsNWidgets(1));
    expect(find.text('computedCounter :0'), findsNWidgets(1));
    expect(counter1NbrOfRebuilds, 2);
    expect(counter2NbrOfRebuilds, 0);
    //computed counter did not change (1*0 =0) so its listeners are not rebuilt.
    expect(computedCounterNbrOfRebuilds, 1);
    //
    counter2.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('counter1 :2'), findsNWidgets(1));
    //both counter 2 and computed counter are waiting
    expect(find.text('Waiting...'), findsNWidgets(2));
    expect(counter1NbrOfRebuilds, 2);
    expect(counter2NbrOfRebuilds, 0);
    expect(computedCounterNbrOfRebuilds, 1);
    //
    await tester.pump(Duration(seconds: 1));
    expect(find.text('counter1 :2'), findsNWidgets(1));
    expect(find.text('counter2 :1'), findsNWidgets(1));
    expect(find.text('computedCounter :2'), findsNWidgets(1));
    expect(counter1NbrOfRebuilds, 2);
    expect(counter2NbrOfRebuilds, 1);
    expect(computedCounterNbrOfRebuilds, 2);
  });

  testWidgets('counter2 throws error', (tester) async {
    counter2.injectMock(() => Counter2(shouldThrow: true));

    await tester.pumpWidget(CounterApp());
    expect(find.text('rebuilder :0'), findsNWidgets(1));

    //
    counter1.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('counter1 :2'), findsNWidgets(1));
    expect(find.text('Idle'), findsNWidgets(1));
    expect(find.text('computedCounter :0'), findsNWidgets(1));
    expect(find.text('rebuilder :0'), findsNWidgets(1));
    expect(counter1NbrOfRebuilds, 2);
    expect(counter2NbrOfRebuilds, 0);
    //computed counter did not change (1*0 =0) so its listener are not rebuilt.
    expect(computedCounterNbrOfRebuilds, 1);
    //
    counter2.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('counter1 :2'), findsNWidgets(1));
    expect(find.text('Waiting...'), findsNWidgets(2));
    expect(find.text('rebuilder :0'), findsNWidgets(1));

    expect(counter1NbrOfRebuilds, 2);
    expect(counter2NbrOfRebuilds, 0);
    expect(computedCounterNbrOfRebuilds, 1);
    //
    await tester.pump(Duration(seconds: 1));
    expect(find.text('counter1 :2'), findsNWidgets(1));
    //both counter2 and computed counter are in the error state
    expect(find.text('Counter Error'), findsNWidgets(2));
    expect(find.text('rebuilder :0'), findsNWidgets(1));

    expect(counter1NbrOfRebuilds, 2);
    expect(counter2NbrOfRebuilds, 0);
    expect(computedCounterNbrOfRebuilds, 1);
  });

  testWidgets('computed of a computed counter', (tester) async {
    //this is an example of a computed counter the depends on another computed counter
    await tester.pumpWidget(CounterApp1());
    expect(find.text('0'), findsNWidgets(1));
    computedCounter.state++;
    await tester.pump();
    expect(find.text('10'), findsNWidgets(1));

    counter1.setState((s) => s.increment());
    counter2.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('Waiting...'), findsNWidgets(1));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('20'), findsNWidgets(1));
    //
    counter1.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('40'), findsNWidgets(1));
  });
}
