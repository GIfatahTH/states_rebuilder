import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final counterFuture = RM.injectFuture(
  () => Future.delayed(Duration(seconds: 1), () => 0),
  //Once the persist parameter is defined the state is persisted
  persist: () => PersistState(
    key: 'counterFuture',
    fromJson: (json) => int.parse(json),
    toJson: (s) => '$s',
    debugPrintOperations: true,
  ),
  autoDisposeWhenNotUsed: true,
  debugPrintWhenNotifiedPreMessage: 'counterFuture',
);

//We use var here to set counter for another options in test
var counter = RM.inject(
  () => 0,
  persist: () => PersistState(
    key: 'counter',
    fromJson: (json) => int.parse(json),
    toJson: (s) => '$s',
    debugPrintOperations: true,
  ),
  debugPrintWhenNotifiedPreMessage: 'counter',
);

//Used to dispose counter for test
final switcher = RM.inject(
  () => true,
  debugPrintWhenNotifiedPreMessage: 'switcher',
);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          On.data(
            () => switcher.state
                ? On.data(
                    () => Text('counter: ${counter.state}'),
                  ).listenTo(
                    counter,
                    debugPrintWhenRebuild: 'counter',
                  )
                : Container(),
          ).listenTo(switcher),
          On.or(
            onWaiting: () => Text('Waiting...'),
            or: () => Text('counterFuture: ${counterFuture.state}'),
          ).listenTo(
            counterFuture,
            debugPrintWhenRebuild: 'App',
          ),
        ],
      ),
    );
  }
}

void main() async {
  //Inject a mocked implementation of ILocalStorage
  //it return a store of type Mao
  final store = (await RM.storageInitializerMock()).store!;
  setUp(() {
    store.clear();
  });
  testWidgets('persist state onData (Default) no initial persisted state',
      (tester) async {
    expect(store.isEmpty, isTrue);
    expect(store['counter'], null);
    await tester.pumpWidget(App());
    //verify store is empty
    expect(store['counterFuture'], null);
    //verify that counterFuture is waiting
    expect(find.text('Waiting...'), findsOneWidget);
    //
    //After on second
    await tester.pump(Duration(seconds: 1));
    //counterFuture has data '0'
    expect(find.text('counterFuture: 0'), findsOneWidget);
    //verify the the  obtained value is persisted
    expect(store['counter'], '0');
    expect(store['counterFuture'], '0');

    //change the state of counter
    counter.state++; //0+1=1
    await tester.pump();
    //verify  the new state is persisted
    expect(store['counter'], '1');
    expect(store['counterFuture'], '0');

    //change the state of counterFuture
    counterFuture.state++;
    await tester.pump();
    expect(store['counter'], '1');
    expect(store['counterFuture'], '1');
  });

  testWidgets('persist state onData (Default) with initial persisted state',
      (tester) async {
    //Fil the store with what would be persisted store form older session
    store.addAll({
      'counter': '10',
      'counterFuture': '10',
    });

    await tester.pumpWidget(App());

    //The state is recreated from the store,
    //The future does not started
    expect(find.text('counter: 10'), findsOneWidget);
    expect(find.text('counterFuture: 10'), findsOneWidget);
  });

  testWidgets('refresh state should reset the persistent state',
      (tester) async {
    store.addAll({
      'counter': '10',
      'counterFuture': '10',
    });

    await tester.pumpWidget(App());

    //
    expect(find.text('counter: 10'), findsOneWidget);
    expect(find.text('counterFuture: 10'), findsOneWidget);

    //Refresh the counter state
    counter.refresh();
    await tester.pump();
    //Back to 0
    expect(find.text('counter: 0'), findsOneWidget);
    expect(store['counter'], '0');
    //
    //Refresh counterFuture
    counterFuture.refresh();
    await tester.pump();
    //The counterFuture store is removed
    expect(store['counterFuture'], '10');
    //It is waiting for the future
    expect(find.text('Waiting...'), findsOneWidget);
    //
    //After one second
    await tester.pump(Duration(seconds: 1));
    //the counterFuture store is reset
    expect(store['counterFuture'], '0');
    expect(find.text('counterFuture: 0'), findsOneWidget);
  });

  testWidgets('persist state onDisposed ', (tester) async {
    counter = RM.inject(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        persistOn: PersistOn.disposed,
      ),
    );

    expect(store.isEmpty, isTrue);
    expect(store['counter'], null);
    await tester.pumpWidget(App());
    expect(store['counter'], null);
    expect(store['counterFuture'], null);
    //
    await tester.pump(Duration(seconds: 1));
    expect(store['counter'], null);
    expect(store['counterFuture'], '0');

    //increment counter
    counter.state++;
    await tester.pump();
    //the new state is not persisted
    expect(store['counter'], null);
    expect(store['counterFuture'], '0');
    //
    //Dispose the state
    switcher.state = !switcher.state;
    // Or calling counter.dispose() manually
    await tester.pump();
    //the counter state is persist after it is disposed
    expect(store['counter'], '1');
    expect(store['counterFuture'], '0');
  });

  testWidgets('persist and delete state manually ', (tester) async {
    counter = RM.inject(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
        persistOn: PersistOn.manualPersist,
      ),
    );

    expect(store.isEmpty, isTrue);
    expect(store['counter'], null);
    await tester.pumpWidget(App());
    expect(store['counterFuture'], null);
    //
    await tester.pump(Duration(seconds: 1));
    expect(store['counter'], null);
    expect(store['counterFuture'], '0');

    //
    counter.state++;
    await tester.pump();
    expect(store['counter'], null);
    expect(store['counterFuture'], '0');
    //manually persist the state
    counter.persistState();
    await tester.pump();
    expect(store['counter'], '1');
    expect(store['counterFuture'], '0');
    //delete the persisted state
    counter.deletePersistState();
    await tester.pump();
    expect(store['counter'], null);
    expect(store['counterFuture'], '0');
  });

  testWidgets('throttle the persistance', (tester) async {
    counter = RM.inject(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
        throttleDelay: 3000,
      ),
    );
    await tester.pumpWidget(App());
    expect(store['counter'], null);
    expect(find.text('counter: 0'), findsOneWidget);

    //first increment
    counter.state++;
    //after the first second
    await tester.pump(Duration(seconds: 1));
    //the state is not persisted
    expect(store['counter'], null);
    //the state is mutated and displayed
    expect(find.text('counter: 1'), findsOneWidget);
    //
    //second increment
    counter.state++;
    //after the another second
    await tester.pump(Duration(seconds: 1));
    //the state is not persisted
    expect(store['counter'], null);
    //the state is mutated and displayed
    expect(find.text('counter: 2'), findsOneWidget);
    //
    counter.state++;
    await tester.pump(Duration(seconds: 1));
    //After three seconds as in the throttleDelay the state is persisted
    expect(store['counter'], '3');
    expect(find.text('counter: 3'), findsOneWidget);
  });
}
