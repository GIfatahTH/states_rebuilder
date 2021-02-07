import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

var counter = RM.inject<int>(
  () => 0,
  persist: () => PersistState(
    key: 'counter',
    catchPersistError: true,
    // debugPrintOperations: true,
  ),
  // onError: (e, s) => print('error'),
  // onInitialized: (_) => print('onInitialized'),
  // onDisposed: (_) => print('onDisposed'),
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
  late Map<dynamic, dynamic> store;
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

void main() async {
  StatesRebuilerLogger.isTestMode = true;
  await RM.storageInitializer(PersistStoreMockImp());
  testWidgets('Test try catch of PersistState', (tester) async {
    await tester.pumpWidget(App());

    counter.state++;
    await tester.pump();

    //
    counter.deletePersistState();
    await tester.pump();
    expect(StatesRebuilerLogger.message.contains('Delete Error'), isTrue);
    //
    counter.deleteAllPersistState();
    await tester.pump();
    expect(StatesRebuilerLogger.message.contains('Delete All Error'), isTrue);
  });
  testWidgets('persistStateProvider, catchPersistError and onError',
      (tester) async {
    counter = RM.injectFuture<int>(
        () => Future.delayed(Duration(seconds: 1), () => 10),
        persist: () => PersistState(
              key: 'Future_counter',
              persistStateProvider: PersistStoreMockImp(),
              catchPersistError: true,
            ),
        onError: (e, s) {
          StatesRebuilerLogger.log('', e);
        });
    expect(counter.state, 0);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 10);
    counter.state++;
    await tester.pump(Duration(seconds: 1));
    expect(StatesRebuilerLogger.message.contains('Write Error'), isTrue);
    await tester.pump(Duration(seconds: 1));

    await tester.pumpAndSettle(Duration(seconds: 1));
    counter.dispose();
    await tester.pump(Duration(seconds: 10));
  });
}
