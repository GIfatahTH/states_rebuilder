import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

bool shouldThrow = false;

class CounterStore {
  //methods can mutate the value of the counter field
  int counter;

  CounterStore(this.counter);

  //1- Synchronous mutation
  void incrementSync() {
    if (shouldThrow) {
      throw Exception('ERROR 😠');
    }
    counter++;
  }

  //2- Async mutation Future
  Future<void> futureIncrement() async {
    //Pessimistic 😢: wait until future completes without error to increment
    await Future.delayed(Duration(seconds: 1));
    if (shouldThrow) {
      throw Exception('ERROR 😠');
    }
    counter++;
  }

  //3- Async Stream
  Stream<void> streamIncrement() async* {
    //Optimistic 😄: start incrementing and if the future completes with error
    //go back the the initial state
    final oldState = counter;
    yield counter++;

    await Future.delayed(Duration(seconds: 1));
    if (shouldThrow) {
      yield counter = oldState;
      throw Exception('ERROR 😠');
    }
  }
}

final counter = RM.inject(() => CounterStore(0));

//variable use to track the number of rebuilds
int rebuilderCount = 0;
int whenRebuilderCount = 0;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          //rebuilder will rebuild only if counter has data
          On.data(
            () {
              rebuilderCount++;
              return Text('rebuilder: ${counter.state.counter}');
            },
          ).listenTo(counter),

          //whenRebuilder will rebuild each time the counter change its state,
          //and call the corresponding callback.
          On.all(
            onIdle: () {
              whenRebuilderCount++;
              return Text('whenRebuilder: Idle');
            },
            onWaiting: () {
              whenRebuilderCount++;
              return Text('whenRebuilder: Waiting');
            },
            onError: (e, _) {
              whenRebuilderCount++;
              return Text('whenRebuilder: ${e.message}');
            },
            onData: () {
              whenRebuilderCount++;
              return Text('whenRebuilder: ${counter.state.counter}');
            },
          ).listenTo(counter),
        ],
      ),
    );
  }
}

void main() {
  setUp(() {
    shouldThrow = false;
    rebuilderCount = 0;
    whenRebuilderCount = 0;
  });
  testWidgets('Initial build', (tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('rebuilder: 0'), findsOneWidget);
    //first build
    expect(rebuilderCount, 1);
    //
    expect(find.text('whenRebuilder: Idle'), findsOneWidget);
    //first build
    expect(whenRebuilderCount, 1);
  });

  testWidgets('incrementSync without error', (tester) async {
    await tester.pumpWidget(MyApp());
    //first build
    expect(rebuilderCount, 1);
    expect(whenRebuilderCount, 1);

    counter.setState((s) => s.incrementSync());
    await tester.pump();

    expect(find.text('rebuilder: 1'), findsOneWidget);
    //rebuilder is notified to rebuild
    expect(rebuilderCount, 2);

    expect(find.text('whenRebuilder: 1'), findsOneWidget);
    //whenRebuilder is notified to rebuild
    expect(whenRebuilderCount, 2);
  });

  testWidgets('incrementSync with error', (tester) async {
    shouldThrow = true;
    await tester.pumpWidget(MyApp());

    counter.setState((s) => s.incrementSync());
    await tester.pump();

    expect(find.text('rebuilder: 0'), findsOneWidget);
    //rebuilder is not notified to rebuild, because counter is not in the hasData state
    expect(rebuilderCount, 1);

    expect(find.text('whenRebuilder: ERROR 😠'), findsOneWidget);
    //whenRebuilder is notified to rebuild and call the onError callback.
    expect(whenRebuilderCount, 2);
  });

  testWidgets('futureIncrement without error', (tester) async {
    await tester.pumpWidget(MyApp());

    counter.setState((s) => s.futureIncrement());
    await tester.pump();

    expect(find.text('rebuilder: 0'), findsOneWidget);
    //rebuilder is not notified to rebuild, because counter is not in the hasData state
    expect(rebuilderCount, 1);

    expect(find.text('whenRebuilder: Waiting'), findsOneWidget);
    //whenRebuilder is notified to rebuild and call the onWaiting callback.
    expect(whenRebuilderCount, 2);

    //
    await tester.pump(Duration(seconds: 1));

    expect(find.text('rebuilder: 1'), findsOneWidget);
    //rebuilder is notified to rebuild
    expect(rebuilderCount, 2);

    expect(find.text('whenRebuilder: 1'), findsOneWidget);
    //whenRebuilder is notified to rebuild for the third time and call the onData callback.
    expect(whenRebuilderCount, 3);
  });

  testWidgets('futureIncrement with error', (tester) async {
    shouldThrow = true;
    await tester.pumpWidget(MyApp());

    counter.setState((s) => s.futureIncrement());
    await tester.pump();

    expect(find.text('rebuilder: 0'), findsOneWidget);
    expect(rebuilderCount, 1);
    expect(find.text('whenRebuilder: Waiting'), findsOneWidget);
    expect(whenRebuilderCount, 2);

    //
    await tester.pump(Duration(seconds: 1));

    expect(find.text('rebuilder: 0'), findsOneWidget);
    //rebuilder is not notified to rebuild, because counter is not in the hasData state
    expect(rebuilderCount, 1);

    expect(find.text('whenRebuilder: ERROR 😠'), findsOneWidget);
    //whenRebuilder is notified to rebuild for the third time and call the onError callback.
    expect(whenRebuilderCount, 3);
  });

  testWidgets('streamIncrement without error', (tester) async {
    await tester.pumpWidget(MyApp());

    counter.setState((s) => s.streamIncrement());
    await tester.pump();

    expect(find.text('rebuilder: 1'), findsOneWidget);
    //rebuilder is notified to rebuild, because stream emits data,
    expect(rebuilderCount, 2);

    expect(find.text('whenRebuilder: 1'), findsOneWidget);
    //whenRebuilder is notified to rebuild, because stream emits data,
    expect(whenRebuilderCount, 2);
    //
    await tester.pump(Duration(seconds: 1));

    expect(find.text('rebuilder: 1'), findsOneWidget);
    //rebuilder is not notified to rebuild, because stream is done,
    expect(rebuilderCount, 2);

    expect(find.text('whenRebuilder: 1'), findsOneWidget);
    //whenRebuilder is not notified to rebuild, because stream is done,
    expect(whenRebuilderCount, 2);
  });

  testWidgets('streamIncrement with error', (tester) async {
    shouldThrow = true;
    await tester.pumpWidget(MyApp());

    counter.setState((s) => s.streamIncrement());
    await tester.pump();

    expect(find.text('rebuilder: 1'), findsOneWidget);
    expect(rebuilderCount, 2);

    expect(find.text('whenRebuilder: 1'), findsOneWidget);
    expect(whenRebuilderCount, 2);

    //
    await tester.pump(Duration(seconds: 1));

    expect(find.text('rebuilder: 0'), findsOneWidget);
    //rebuilder is notified to rebuild, because stream emits data with the old state before error,
    expect(rebuilderCount, 3);

    expect(find.text('whenRebuilder: ERROR 😠'), findsOneWidget);
    //whenRebuilder is notified to rebuild, because stream emits an error,
    expect(whenRebuilderCount, 3);
  });
}
