import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injected.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final counter = RM.inject(
  () => 0,
  persist: PersistState(
    key: 'counter',
    fromJson: (json) => int.parse(json),
    toJson: (s) => '$s',
  ),
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
  T read<T>(String key) {
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
    await RM.localStorageInitializer(PersistStoreMockImp());
    await tester.pumpWidget(App());
    // persistState.read();
    expect(StatesRebuilerLogger.message.contains('Read Error'), isTrue);

    counter.state++;
    await tester.pump();
    expect(StatesRebuilerLogger.message.contains('Write Error'), isTrue);
    //
    counter.persistState();
    await tester.pump();
    expect(StatesRebuilerLogger.message.contains('Write Error'), isTrue);

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
