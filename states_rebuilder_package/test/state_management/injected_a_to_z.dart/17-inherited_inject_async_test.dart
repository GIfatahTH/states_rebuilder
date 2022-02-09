// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors
//Fetching a list of counters from a backend service
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

bool _shouldThrow = false;

class Counter {
  final String id;
  int value;
  Counter({required this.id, required this.value});
  Future<Counter> increment() async => Future.delayed(
        Duration(seconds: 1),
        () => _shouldThrow
            ? throw Exception('$id error')
            : copyWith(id, value + 1),
      );

  Counter copyWith(String? id, int? value) {
    return Counter(
      id: id ?? this.id,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Counter && o.id == id && o.value == value;
  }

  @override
  int get hashCode => id.hashCode ^ value.hashCode;
}

late List<Counter> _listOfCounters; //Will be initialized id setUp method

//Global reference to the injected state item
final injectedCounter = RM.inject<Counter>(
  () => throw UnimplementedError(),
  sideEffects: SideEffects.onAll(
    onWaiting: () {
      //Called if any of the counter item is waiting
    },
    onError: (err, stack) {
      //Called if any of the counter item has error
    },
    onData: (counter) {
      //Called if all items have data
      //
      //Whenever any of the counter items state is changed this onData is invoked,
      //with the new value of the counter item.
      //
      //get the index of the counter item
      final index = _listOfCounters.indexOf(
        _listOfCounters.firstWhere((e) => e.id == counter.id),
      );
      //
      //update the _listOfCounters
      _listOfCounters[index] = counter;
    },
  ),
);

//Use in test to track the number of rebuild of counter item widgets
late Map<String, int> numberOfRebuild;

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        //Colum here can be replaced with ListView.builder
        //I use Column for the sake of clarity
        children: [
          injectedCounter.inherited(
            stateOverride: () => _listOfCounters[0],
            builder: (_) => const CounterItem(),
          ),
          injectedCounter.inherited(
            stateOverride: () => _listOfCounters[1],
            builder: (_) => const CounterItem(),
          ),
          injectedCounter.inherited(
            stateOverride: () => _listOfCounters[2],
            builder: (_) => const CounterItem(),
          ),
        ],
      ),
    );
  }
}

class CounterItem extends StatelessWidget {
  const CounterItem();
  @override
  Widget build(BuildContext context) {
    final counter = injectedCounter(context);
    return Row(
      children: [
        OnBuilder.orElse(
          listenTo: counter,
          onWaiting: () => Text('${counter.state.id}: isWaiting'),
          onError: (e, _) => Text('${counter.state.id}: hasError'),
          orElse: (_) {
            //count the number of rebuild
            numberOfRebuild[counter.state.id] =
                numberOfRebuild[counter.state.id]! + 1;
            return Text('${counter.state.id}: ${counter.state.value}');
          },
        ),
        ElevatedButton(
          key: Key(counter.state.id),
          onPressed: () => counter.setState((s) => s.increment()),
          child: Text(counter.state.id),
        )
      ],
    );
  }
}

void main() {
  setUp(() {
    numberOfRebuild = {
      'counter1': 0,
      'counter2': 0,
      'counter3': 0,
    };
    _listOfCounters = [
      Counter(id: 'counter1', value: 0),
      Counter(id: 'counter2', value: 0),
      Counter(id: 'counter3', value: 0),
    ];
    _shouldThrow = false;
  });
  testWidgets('initial build', (tester) async {
    await tester.pumpWidget(_App());
    //We expect to see three CounterItem widgets
    expect(find.byType(CounterItem), findsNWidgets(3));
    //
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);
    expect(find.text('counter3: 0'), findsOneWidget);
    //
    //All counter widget are rebuilt one time (the initial rebuild)
    expect(numberOfRebuild['counter1'], 1);
    expect(numberOfRebuild['counter2'], 1);
    expect(numberOfRebuild['counter3'], 1);
  });

  testWidgets('increment counter1', (tester) async {
    await tester.pumpWidget(_App());

    await tester.tap(find.byKey(Key('counter1')));
    await tester.pump();

    //counter1 isWaiting
    expect(find.text('counter1: isWaiting'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);
    expect(find.text('counter3: 0'), findsOneWidget);
    //
    //injectedCounter isWaiting also
    expect(injectedCounter.isWaiting, isTrue);
    //
    //After one seconds
    await tester.pump(Duration(seconds: 1));
    //
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);
    expect(find.text('counter3: 0'), findsOneWidget);
    //
    expect(injectedCounter.hasData, isTrue);
  });

  testWidgets('increment counter2', (tester) async {
    await tester.pumpWidget(_App());

    await tester.tap(find.byKey(Key('counter2')));
    await tester.pump();

    //counter2 isWaiting
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: isWaiting'), findsOneWidget);
    expect(find.text('counter3: 0'), findsOneWidget);
    //
    //injectedCounter isWaiting also
    expect(injectedCounter.isWaiting, isTrue);
    //
    //After one seconds
    await tester.pump(Duration(seconds: 1));
    //
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);
    expect(find.text('counter3: 0'), findsOneWidget);
    //
    expect(injectedCounter.hasData, isTrue);
  });

  testWidgets('increment counter3 with error', (tester) async {
    await tester.pumpWidget(_App());
    _shouldThrow = true;
    await tester.tap(find.byKey(Key('counter3')));
    await tester.pump();

    //counter3 hasError
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);
    expect(find.text('counter3: isWaiting'), findsOneWidget);
    //
    //injectedCounter isWaiting also
    expect(injectedCounter.isWaiting, isTrue);
    //
    //After one seconds
    await tester.pump(Duration(seconds: 1));
    //
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);
    expect(find.text('counter3: hasError'), findsOneWidget);
    //
    expect(injectedCounter.hasError, isTrue);
  });

  testWidgets(
    'Check sideEffects for inherited injected ',
    (tester) async {
      SnapState? globalCounterSnap;
      SnapState? counter1Snap;
      SnapState? counter2Snap;
      final counterRM = RM.inject(
        () => 0,
        // debugPrintWhenNotifiedPreMessage: '',
        sideEffects: SideEffects(
          onSetState: (snap) {
            globalCounterSnap = snap;
          },
        ),
      );

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            counterRM.inherited(
              stateOverride: () async {
                return Future.delayed(const Duration(seconds: 1), () => 10);
              },
              builder: (context) {
                final counter = counterRM(context);
                if (counter.isWaiting) {
                  return Text('Counter1 is waiting...');
                }
                return Text('Counter1 is ${counter.state}');
              },
              sideEffects: SideEffects(
                onSetState: (snap) => counter1Snap = snap,
              ),
            ),
            counterRM.inherited(
              stateOverride: () async {
                return Future.delayed(const Duration(seconds: 2), () => 20);
              },
              sideEffects: SideEffects(
                onSetState: (snap) => counter2Snap = snap,
              ),
              builder: (context) {
                final counter = counterRM(context);
                if (counter.isWaiting) {
                  return Text('Counter2 is waiting...');
                }
                return Text('Counter2 is ${counter.state}');
              },
            ),
          ],
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('Counter1 is waiting...'), findsOneWidget);
      expect(find.text('Counter2 is waiting...'), findsOneWidget);
      expect(globalCounterSnap, null);
      expect(counter1Snap!.isWaiting, true);
      expect(counter2Snap!.isWaiting, true);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Counter1 is waiting...'), findsNothing);
      expect(find.text('Counter1 is 10'), findsOneWidget);
      expect(find.text('Counter2 is waiting...'), findsOneWidget);
      expect(counter1Snap!.hasData, true);
      expect(counter1Snap!.data, 10);
      expect(counter2Snap!.isWaiting, true);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Counter1 is waiting...'), findsNothing);
      expect(find.text('Counter1 is 10'), findsOneWidget);
      expect(find.text('Counter2 is waiting...'), findsNothing);
      expect(find.text('Counter2 is 20'), findsOneWidget);
      expect(counter1Snap!.hasData, true);
      expect(counter1Snap!.data, 10);
      expect(counter2Snap!.hasData, true);
      expect(counter2Snap!.data, 20);
    },
  );
}
