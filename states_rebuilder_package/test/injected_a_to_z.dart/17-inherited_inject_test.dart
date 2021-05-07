//Fetching a list of counters from a backend service
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  final String id;
  int value;
  Counter({required this.id, required this.value});
  Counter increment() => copyWith(id, value + 1);

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
    return MaterialApp(
      navigatorKey: RM.navigate.navigatorKey,
      home: Scaffold(
        body: Column(
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
        On.data(
          () {
            //count the number of rebuild
            numberOfRebuild[counter.state.id] =
                numberOfRebuild[counter.state.id]! + 1;
            return Text('${counter.state.id}: ${counter.state.value}');
          },
        ).listenTo(counter),
        ElevatedButton(
          key: Key(counter.state.id),
          onPressed: () => counter.setState((s) => s.increment()),
          child: Text(counter.state.id),
        ),
        ElevatedButton(
          key: Key('Navigate to ' + counter.state.id),
          onPressed: () {
            RM.navigate.to(
              counter.reInherited(
                context: context,
                builder: (context) => const CounterItemDetailed(),
              ),
            );
          },
          child: Text('Navigate to counter detailed'),
        )
      ],
    );
  }
}

//Detailed counter. used to test the availability of inherited counter state
//in a new route page
class CounterItemDetailed extends StatelessWidget {
  const CounterItemDetailed();
  @override
  Widget build(BuildContext context) {
    final counter = injectedCounter(context);
    return Text('Detailed of ${counter.state.id}: ${counter.state.value}');
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

  testWidgets(
      'Inherited counter state is available in a new route using reInherit',
      (tester) async {
    await tester.pumpWidget(_App());
    //top to increment counter 1
    await tester.tap(find.byKey(Key('counter1')));
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    //
    //Tap on counter to navigate to detailed page
    await tester.tap(find.byKey(Key('Navigate to counter1')));
    await tester.pumpAndSettle();
    //We are in the detailed screen
    expect(find.byType(CounterItemDetailed), findsOneWidget);
    //And we get the counter1 state using the context.
    expect(find.text('Detailed of counter1: 1'), findsOneWidget);
    //
    //Pop back to list of counter page
    RM.navigate.back();
    await tester.pumpAndSettle();
    //
    //Tap on counter to navigate to detailed page
    await tester.tap(find.byKey(Key('Navigate to counter2')));
    await tester.pumpAndSettle();
    //We are in the detailed screen
    expect(find.byType(CounterItemDetailed), findsOneWidget);
    //And we get the counter2 state using the context.
    expect(find.text('Detailed of counter2: 0'), findsOneWidget);
    expect(find.byType(CounterItem), findsNWidgets(0));

    //
    //Pop back to list of counter page
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.byType(CounterItem), findsNWidgets(3));

    await tester.tap(find.byKey(Key('counter1'))); //TODO to check
    await tester.pump();
    //
    //top to increment counter 3 twice
    await tester.tap(find.byKey(Key('counter3')));
    await tester.pump();
    await tester.tap(find.byKey(Key('counter3')));
    await tester.pump();
    expect(find.text('counter3: 2'), findsOneWidget);
    //
    //Tap on counter to navigate to detailed page
    await tester.tap(find.byKey(Key('Navigate to counter3')));
    await tester.pumpAndSettle();
    //We are in the detailed screen
    expect(find.byType(CounterItemDetailed), findsOneWidget);
    //And we get the counter3 state using the context.
    expect(find.text('Detailed of counter3: 2'), findsOneWidget);
  });
}
