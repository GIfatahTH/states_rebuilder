import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injected.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

var counter = RM.inject(
  () => 0,
  persist: () => PersistState(
    key: 'counter',
    fromJson: (json) => int.parse(json),
    toJson: (s) => '$s',
  ),
  onInitialized: (_) => print('onInitialized'),
  onDisposed: (_) => print('onDisposed'),
);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: counter.rebuilder(
          () => Text('counter: ${counter.state}'),
        ));
  }
}

void main() async {
  StatesRebuilerLogger.isTestMode = true;

  final store = await RM.storageInitializerMock();
  setUp(() {
    store.clear();
  });
  testWidgets('Persist before calling getRM', (tester) async {
    store.store.addAll({'counter': '10'});
    expect(counter.state, 10);
    counter.state++;
    expect(store.store, {'counter': '11'});
    counter.getRM;
    //
    counter.dispose();
  });

  testWidgets('persist with async read', (tester) async {
    store.isAsyncRead = true;
    store.store.addAll({'counter': '10'});
    expect(counter.state, null);
    await tester.pump();
    expect(counter.state, 10);
    counter.state++;
    expect(store.store, {'counter': '11'});
    counter.getRM;
  });

  testWidgets('persist with async fromJson', (tester) async {
    counter = RM.inject(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) async {
          await Future.delayed(Duration(seconds: 1));
          return int.parse(json);
        },
        toJson: (s) => '$s',
      ),
      onInitialized: (_) => print('onInitialized'),
      onDisposed: (_) => print('onDisposed'),
    );

    store.store.addAll({'counter': '10'});
    expect(counter.state, null);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 10);
    counter.state++;
    expect(store.store, {'counter': '11'});
    counter.dispose();
  });

  testWidgets('persist with async read and async fromJson', (tester) async {
    counter = RM.inject(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) async {
          await Future.delayed(Duration(seconds: 1));
          return int.parse(json);
        },
        toJson: (s) => '$s',
      ),
      onInitialized: (_) => print('onInitialized'),
      onDisposed: (_) => print('onDisposed'),
    );

    store.isAsyncRead = true;
    store.store.addAll({'counter': '10'});
    expect(counter.state, null);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 10);
    counter.state++;
    expect(store.store, {'counter': '11'});
    counter.dispose();
  });

  testWidgets('Persist before calling getRM1 (check run all test) ',
      (tester) async {
    store.store.addAll({'counter': '10'});
    counter = RM.inject(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
      ),
      onInitialized: (_) => print('onInitialized'),
      onDisposed: (_) => print('onDisposed'),
    );
    expect(counter.state, 10);
    counter.state++;
    expect(store.store, {'counter': '11'});
    counter.getRM;
    //
    counter.dispose();
  });
}
