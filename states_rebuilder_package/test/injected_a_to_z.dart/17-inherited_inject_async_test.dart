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
  Widget build(BuildContext context) {
    final counter = injectedCounter(context)!;
    return Row(
      children: [
        On.or(
          onWaiting: () => Text('${counter.state.id}: isWaiting'),
          onError: (e, _) => Text('${counter.state.id}: hasError'),
          or: () {
            //count the number of rebuild
            numberOfRebuild[counter.state.id] =
                numberOfRebuild[counter.state.id]! + 1;
            return Text('${counter.state.id}: ${counter.state.value}');
          },
        ).listenTo(counter),
        RaisedButton(
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
}
