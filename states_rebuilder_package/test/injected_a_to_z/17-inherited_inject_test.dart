//Fetching a list of counters from a backend service
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  final String id;
  int value;
  Counter({this.id, this.value});
  Counter increment() => copyWith(id, value + 1);

  Counter copyWith(String id, int value) {
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

List<Counter> _listOfCounters; //Will be initialized id setUp method

//Global reference to the injected state item
final injectedCounter = RM.inject<Counter>(
  () => null,
  onWaiting: () {
    //Called if any of the counter item is waiting
    print('onWaiting');
  },
  onError: (err, stack) {
    //Called if any of the counter item has error
    print('onWaiting');
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
Map<String, int> numberOfRebuild;

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
            state: () => _listOfCounters[0],
            builder: (_) => const CounterItem(),
          ),
          injectedCounter.inherited(
            state: () => _listOfCounters[1],
            builder: (_) => const CounterItem(),
          ),
          injectedCounter.inherited(
            state: () => _listOfCounters[2],
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
    final counter = injectedCounter(context);
    return Row(
      children: [
        counter.rebuilder(
          () {
            //count the number of rebuild
            numberOfRebuild[counter.state.id] =
                numberOfRebuild[counter.state.id] + 1;
            return Text('${counter.state.id}: ${counter.state.value}');
          },
        ),
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

    //
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);
    expect(find.text('counter3: 0'), findsOneWidget);

    // Only the the counter1 widget is rebuilt
    expect(numberOfRebuild['counter1'], 2);
    expect(numberOfRebuild['counter2'], 1);
    expect(numberOfRebuild['counter3'], 1);
    //
    //_listOfCounters is updated
    expect(_listOfCounters[0].value, 1);
    expect(_listOfCounters[1].value, 0);
    expect(_listOfCounters[2].value, 0);
  });

  testWidgets('increment counter2', (tester) async {
    await tester.pumpWidget(_App());

    await tester.tap(find.byKey(Key('counter2')));
    await tester.pump();

    //
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);
    expect(find.text('counter3: 0'), findsOneWidget);

    // Only the the counter2 widget is rebuilt
    expect(numberOfRebuild['counter1'], 1);
    expect(numberOfRebuild['counter2'], 2);
    expect(numberOfRebuild['counter3'], 1);
    //
    //_listOfCounters is updated
    expect(_listOfCounters[0].value, 0);
    expect(_listOfCounters[1].value, 1);
    expect(_listOfCounters[2].value, 0);
  });

  testWidgets('increment counter3', (tester) async {
    await tester.pumpWidget(_App());

    await tester.tap(find.byKey(Key('counter3')));
    await tester.pump();

    //
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);
    expect(find.text('counter3: 1'), findsOneWidget);

    // Only the the counter3 widget is rebuilt
    expect(numberOfRebuild['counter1'], 1);
    expect(numberOfRebuild['counter2'], 1);
    expect(numberOfRebuild['counter3'], 2);
    //
    //_listOfCounters is updated
    expect(_listOfCounters[0].value, 0);
    expect(_listOfCounters[1].value, 0);
    expect(_listOfCounters[2].value, 1);
  });

  testWidgets('refresh injected counter', (tester) async {
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

    //Let's imagine _listOfCounters is updated
    _listOfCounters = [
      Counter(id: 'counter1', value: 1), // 1 instead of 0
      Counter(id: 'counter2', value: 1),
      Counter(id: 'counter3', value: 1),
    ];
    //Because CounterItem are const, they will not rebuild even if
    //a parent widget rebuild. [This is how const optimize rebuild]

    //To fore CounterItem to rebuild we call refresh method on the injectedCounter
    injectedCounter.refresh();
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);
    expect(find.text('counter3: 1'), findsOneWidget);
  });
}
