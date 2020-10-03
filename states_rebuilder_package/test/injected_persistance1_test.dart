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
    catchPersistError: true,
  ),
  onError: (e, s) => print('error'),
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

class PersistStoreMockImp extends IPersistStore {
  Map<dynamic, dynamic> store;
  @override
  Future<void> init() {
    store = {};
    return Future.value();
  }

  @override
  Future<void> delete(String key) {
    throw Exception('Delete Error');
  }

  @override
  Future<void> deleteAll() {
    throw Exception('Delete All Error');
  }

  @override
  Object read(String key) {
    throw Exception('Read Error');
  }

  @override
  Future<void> write<T>(String key, T value) {
    throw Exception('Write Error');
  }
}

void main() {
  StatesRebuilerLogger.isTestMode = true;
  testWidgets('throw if not localStorage provider is given', (tester) async {
    await tester.pumpWidget(App());
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('Test try catch of PersistState', (tester) async {
    await RM.storageInitializer(PersistStoreMockImp());
    await tester.pumpWidget(App());
    // persistState.read();
    expect(StatesRebuilerLogger.message.contains('Read Error'), isTrue);

    // expect(() => counter.state++, throwsException);
    counter.state++;
    await tester.pump();
    // expect(tester.takeException(), isException);
    // // expect(StatesRebuilerLogger.message.contains('Write Error'), isTrue);
    // // //
    // expect(() => counter.persistState(), throwsException);

    // await tester.pump();
    // expect(StatesRebuilerLogger.message.contains('Write Error'), isTrue);

    //
    counter.deletePersistState();
    await tester.pump();
    expect(StatesRebuilerLogger.message.contains('Delete Error'), isTrue);
    //
    counter.deleteAllPersistState();
    await tester.pump();
    expect(StatesRebuilerLogger.message.contains('Delete All Error'), isTrue);
  });
}
