import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final counterFuture = RM.injectFuture(
  () => Future.delayed(Duration(seconds: 1), () => 0),
  persist: PersistState(
    key: 'counterFuture',
    fromJson: (json) => int.parse(json),
    toJson: (s) => '$s',
  ),
);

var counter = RM.inject(
  () => 0,
  persist: PersistState(
    key: 'counter',
    fromJson: (json) => int.parse(json),
    toJson: (s) => '$s',
  ),
);

final switcher = RM.inject(() => true);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          switcher.rebuilder(
            () => switcher.state
                ? counter.rebuilder(
                    () => Text('counter: ${counter.state}'),
                  )
                : Container(),
          ),
          counterFuture.whenRebuilderOr(
            onWaiting: () => Text('Waiting...'),
            builder: () => Text('counterFuture: ${counterFuture.state}'),
          ),
        ],
      ),
    );
  }
}

void main() async {
  final store = await RM.localStorageInitializerMock();
  setUp(() {
    store.clear();
  });
  testWidgets('persist state onData (Default) not initial persisted state',
      (tester) async {
    await tester.pumpWidget(App());
    expect(store.isEmpty, isTrue);
    expect(store['counter'], null);
    expect(store['counterFuture'], null);
    expect(find.text('Waiting...'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    expect(store['counter'], null);
    expect(store['counterFuture'], '0');
    expect(find.text('counterFuture: 0'), findsOneWidget);

    //
    counter.state++;
    await tester.pump();
    expect(store['counter'], '1');
    expect(store['counterFuture'], '0');

    //
    counterFuture.state++;
    await tester.pump();
    expect(store['counter'], '1');
    expect(store['counterFuture'], '1');
  });

  testWidgets('persist state onData (Default) with initial persisted state',
      (tester) async {
    store.addAll({
      'counter': '10',
      'counterFuture': '10',
    });

    await tester.pumpWidget(App());

    //
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

    counter.refresh();
    await tester.pump();
    expect(find.text('counter: 0'), findsOneWidget);
    expect(store['counter'], '0');
    //
    counterFuture.refresh();
    await tester.pump();
    expect(store['counterFuture'], '10');
    expect(find.text('Waiting...'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(store['counterFuture'], '0');
    expect(find.text('counterFuture: 0'), findsOneWidget);
  });

  testWidgets('persist state onDisposed ', (tester) async {
    counter = RM.inject(
      () => 0,
      persist: PersistState(
        key: 'counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
        persistOn: PersistOn.disposed,
      ),
    );

    await tester.pumpWidget(App());
    expect(store.isEmpty, isTrue);
    expect(store['counter'], null);
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
    //
    switcher.state = !switcher.state;
    // Or calling counter.dispose() manually
    await tester.pump();
    expect(store['counter'], '1');
    expect(store['counterFuture'], '0');
  });

  testWidgets('persist and delete state manually ', (tester) async {
    counter = RM.inject(
      () => 0,
      persist: PersistState(
        key: 'counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
        persistOn: PersistOn.disposed,
      ),
    );

    await tester.pumpWidget(App());
    expect(store.isEmpty, isTrue);
    expect(store['counter'], null);
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
    //
    counter.persistState();
    await tester.pump();
    expect(store['counter'], '1');
    expect(store['counterFuture'], '0');
    //
    counter.deletePersistState();
    await tester.pump();
    expect(store['counter'], null);
    expect(store['counterFuture'], '0');
  });

  testWidgets('throttle the persistance', (tester) async {
    counter = RM.inject(
      () => 0,
      persist: PersistState(
        key: 'counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
        throttleDelay: 3000,
      ),
    );
    await tester.pumpWidget(App());
    expect(store['counter'], null);
    expect(find.text('counter: 0'), findsOneWidget);

    //
    counter.state++;
    await tester.pump(Duration(seconds: 1));
    expect(store['counter'], null);
    expect(find.text('counter: 1'), findsOneWidget);

    //
    counter.state++;
    await tester.pump(Duration(seconds: 1));
    expect(store['counter'], null);
    expect(find.text('counter: 2'), findsOneWidget);

    counter.state++;
    await tester.pump(Duration(seconds: 1));
    expect(store['counter'], '3');
    expect(find.text('counter: 3'), findsOneWidget);
  });
}
