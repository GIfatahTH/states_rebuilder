import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

var counter = RM.inject<int>(
  () => 0,
  persist: () => PersistState(
    key: 'counter',
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
  // testWidgets('throw if not localStorage provider is given', (tester) async {
  //   await tester.pumpWidget(App());
  //   expect(tester.takeException(), isAssertionError);
  // });
  group('', () {
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

    testWidgets('persistStateProvider, catchPersistError and onError',
        (tester) async {
      await RM.storageInitializer(PersistStoreMockImp());

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

      await tester.pump(Duration(seconds: 1));
      counter.dispose();
    });
  });
}
