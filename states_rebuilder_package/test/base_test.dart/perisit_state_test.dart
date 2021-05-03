import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';

import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder/src/common/logger.dart';

import 'common.dart';

var counter = RM.inject<int>(
  () => 0,
  persist: () => PersistState(
    key: 'counter',
  ),
);

final counterFuture = RM.injectFuture<int>(
  () => Future.delayed(Duration(seconds: 1), () => 0),
  //Once the persist parameter is defined the state is persisted
  persist: () => PersistState(
    key: 'counterFuture',
  ),
);
void main() async {
  //Inject a mocked implementation of ILocalStorage
  //it return a store of type Mao
  final store = await RM.storageInitializerMock();
  setUp(() {
    try {
      store.clear();
      counter.dispose();
      counterFuture.dispose();
    } catch (e) {
      print(e);
    }
  });
  testWidgets(
    'WHEN Injected state is persisted'
    'THEN the state is persisted after is first created and after mutation'
    'CASE no initial stored state',
    (tester) async {
      expect(store.store!.isEmpty, isTrue);
      expect(store.store!['counter'], null);
      expect(store.store!['counterFuture'], null);
      expect(counter.state, 0);
      expect(store.store!['counter'], '0');
      expect(counterFuture.isWaiting, true);
      expect(store.store!['counterFuture'], null);
      await tester.pump(Duration(seconds: 1));
      expect(store.store!['counterFuture'], '0');
      //change the state of counter
      counter.state++; //0+1=1

      //verify  the new state is persisted
      expect(store.store!['counter'], '1');
      expect(store.store!['counterFuture'], '0');

      //change the state of counterFuture
      counterFuture.state++;
      expect(store.store!['counter'], '1');
      expect(store.store!['counterFuture'], '1');
    },
  );

  testWidgets(
    'WHEN Injected state is persisted AND if it is initially stored'
    'THEN the state is obtained form the store and injected future are not called',
    (tester) async {
      //Fil the store with what would be persisted store form older session
      store.store!.addAll({
        'counter': '10',
        'counterFuture': '10',
      });

      //The state is recreated from the store,
      //The future does not started
      expect(counter.state, 10);
      expect(counterFuture.state, 10);
    },
  );

  testWidgets(
    'WHEN refresh is called on a persisted state'
    'The stored value is deleted and the new state after refresh is persisted',
    (tester) async {
      store.store!.addAll({
        'counter': '10',
        'counterFuture': '10',
      });

      //
      expect(counter.state, 10);
      expect(counterFuture.state, 10);

      //Refresh the counter state
      await counter.refresh();

      //Back to 0
      expect(counter.state, 0);
      expect(store.store!['counter'], '0');
      //
      //Refresh counterFuture
      counterFuture.refresh();
      await tester.pump();

      expect(store.store!['counterFuture'], '10');
      //It is waiting for the future
      expect(counterFuture.isWaiting, true);
      //
      //After one second
      await tester.pump(Duration(seconds: 1));
      //the counterFuture store is reset
      expect(store.store!['counterFuture'], '0');
      expect(counterFuture.state, 0);
    },
  );

  testWidgets(
    'WHEN persistOn is set to PersistOn.disposed'
    'THEN the state is not persisted until it is disposed',
    (tester) async {
      final counter = RM.inject(
        () => 0,
        persist: () => PersistState<int>(
          key: 'counter',
          persistOn: PersistOn.disposed,
        ),
      );

      expect(store.store!.isEmpty, isTrue);
      expect(store.store!['counter'], null);
      expect(counter.state, 0);
      expect(counterFuture.isWaiting, true);
      expect(store.store!['counter'], null);
      expect(store.store!['counterFuture'], null);
      //
      await tester.pump(Duration(seconds: 1));
      expect(store.store!['counter'], null);
      expect(store.store!['counterFuture'], '0');

      //increment counter
      counter.state++;
      //the new state is not persisted
      expect(store.store!['counter'], null);
      expect(store.store!['counterFuture'], '0');
      //
      //Dispose the state
      counter.dispose();
      counterFuture.dispose();

      //the counter state is persist after it is disposed
      expect(store.store!['counter'], '1');
      expect(store.store!['counterFuture'], '0');
    },
  );

  testWidgets(
    'WHEN persistOn is set to PersistOn.manualPersist'
    'THEN the state is only persisted manually',
    (tester) async {
      final counter = RM.inject(
        () => 0,
        persist: () => PersistState(
          key: 'counter',
          fromJson: (json) => int.parse(json),
          toJson: (s) => '$s',
          persistOn: PersistOn.manualPersist,
        ),
      );

      expect(store.store!.isEmpty, isTrue);
      expect(store.store!['counter'], null);
      expect(store.store!['counterFuture'], null);
      //
      expect(counter.state, 0);
      expect(counterFuture.isWaiting, true);
      await tester.pump(Duration(seconds: 1));
      expect(store.store!['counter'], null);
      expect(store.store!['counterFuture'], '0');

      //
      counter.state++;
      expect(store.store!['counter'], null);
      expect(store.store!['counterFuture'], '0');
      //manually persist the state
      counter.persistState();
      await tester.pump();
      expect(store.store!['counter'], '1');
      expect(store.store!['counterFuture'], '0');
      //delete the persisted state
      counter.deletePersistState();
      await tester.pump();
      expect(store.store!['counter'], null);
      expect(store.store!['counterFuture'], '0');
    },
  );

  testWidgets(
    'WHEN throttleDelay is defined, '
    'THEN the state is throttled',
    (tester) async {
      final counter = RM.inject(
        () => 0,
        persist: () => PersistState(
          key: 'counter',
          fromJson: (json) => int.parse(json),
          toJson: (s) => '$s',
          throttleDelay: 3000,
        ),
      );

      expect(store.store!['counter'], null);
      expect(counter.state, 0);

      //first increment
      counter.state++;
      //after the first second
      await tester.pump(Duration(seconds: 1));
      //the state is not persisted
      expect(store.store!['counter'], null);
      //the state is mutated and displayed
      expect(counter.state, 1);
      //
      //second increment
      counter.state++;
      //after the another second
      await tester.pump(Duration(seconds: 1));
      //the state is not persisted
      expect(store.store!['counter'], null);
      //the state is mutated and displayed
      expect(counter.state, 2);
      //
      counter.state++;
      await tester.pump(Duration(seconds: 1));
      //After three seconds as in the throttleDelay the state is persisted
      expect(store.store!['counter'], '3');
      expect(counter.state, 3);
    },
  );

  testWidgets(
      'WHEN storage provider has an async read '
      'THEN reading is done asynchronously', (tester) async {
    store.isAsyncRead = true;
    store.timeToWait = 1000;
    store.store?.addAll({'counter': '10'});
    expect(counter.isWaiting, true);
    await tester.pump(Duration(seconds: 1));

    expect(counter.state, 10);
    counter.state++;
    await tester.pump(Duration(seconds: 1));

    expect(store.store, {'counter': '11'});
    //
    await tester.pump(Duration(seconds: 1));

    store.store?['counter'] = '20';
    counter.refresh();
    await tester.pump(Duration(seconds: 1));

    expect(counter.state, 0);
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    expect(store.store, {'counter': '0'});
  });

  testWidgets(
      'WHEN reading fails'
      'THEN the state captures the exception', (tester) async {
    store.isAsyncRead = true;
    store.timeToThrow = 1000;
    store.exception = Exception('Read error');
    store.store?.addAll({'counter': '10'});
    expect(counter.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(counter.hasError, true);
    expect(counter.error.message, 'Read error');
    store.store?['counter'] = '10';
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
  });

  testWidgets('WHEN formJson method is async method', (tester) async {
    final counter = RM.inject(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) async {
          await Future.delayed(Duration(seconds: 1));
          return int.parse(json);
        },
        toJson: (s) => '$s',
      ),
    );

    store.store?.addAll({'counter': '10'});
    expect(counter.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 10);
    counter.state++;
    await tester.pump(Duration(seconds: 1));

    expect(store.store, {'counter': '11'});
  });

  testWidgets('WHEN formJson and read methods are async method',
      (tester) async {
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
      initialState: 0,
      // onInitialized: (_) => print('onInitialized'),
      // onDisposed: (_) => print('onDisposed'),
    );

    store.isAsyncRead = true;
    store.store?.addAll({'counter': '10'});
    expect(counter.state, 0);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 10);
    counter.state++;
    await tester.pump(Duration(seconds: 1));

    expect(store.store, {'counter': '11'});
  });

  testWidgets(
      'WHEN a persistStateProvider is defined to override'
      'the global storage provider', (tester) async {
    counter = RM.injectFuture(
      () => Future.delayed(Duration(seconds: 1), () => 0),
      persist: () => PersistState(
        key: 'Future_counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
        persistStateProvider: PersistStoreMockImp(),
      ),
      initialState: 0,
    );
    store.store?.addAll({'Future_counter': '10'});
    expect(counter.state, 0);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 10);
    counter.state++;
  });
  StatesRebuilerLogger.isTestMode = true;
  testWidgets(
      'WHEN catchPersistError is true'
      'THEN persisted exceptions are caught and a print message is logged',
      (tester) async {
    final counter = RM.inject(() => 0,
        persist: () => PersistState(
              key: 'counter',
              fromJson: (json) => int.parse(json),
              toJson: (s) => '$s',
              catchPersistError: true,
            ),
        onError: (e, s) {
          // error = e.message;
        });

    store.exception = Exception('Read Error');
    expect(counter.state, 0);
    expect(StatesRebuilerLogger.message.contains('Read Error'), isTrue);
    await tester.pump(Duration(seconds: 1));

    store.exception = Exception('Write Error');
    counter.state++;
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    expect(StatesRebuilerLogger.message.contains('Write Error'), isTrue);

    //
    store.exception = Exception('Delete Error');
    counter.deletePersistState();
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    expect(StatesRebuilerLogger.message.contains('Delete Error'), isTrue);
    //
  });

  testWidgets('Return to previous state and notify listeners when throw error',
      (tester) async {
    final counter = RM.inject(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
      ),
    );
    expect(counter.state, 0);
    store.exception = Exception('Write Error');
    store.timeToThrow = 1000;
    counter.state++;
    expect(counter.state, 1);
    expect(counter.hasData, true);
    await tester.pump(Duration(seconds: 1));
    expect(counter.hasError, true);
    expect(counter.state, 0);
  });

  testWidgets('infer fromJson and toJson of int', (tester) async {
    final counter = RM.inject<int>(
      () => 0,
      persist: () => PersistState(key: 'counter'),
    );
    store.store?.addAll({'counter': '10'});
    expect(counter.state, 10);
    counter.state++;
    expect(store.store, {'counter': '11'});
  });
  testWidgets('infer fromJson and toJson of double', (tester) async {
    final counter = RM.inject<double>(
      () => 0.0,
      persist: () => PersistState(key: 'counter'),
    );
    store.store?.addAll({'counter': '10.0'});
    expect(counter.state, 10.0);
    counter.state++;
    expect(store.store, {'counter': '11.0'});
  });
  testWidgets('infer fromJson and toJson of String', (tester) async {
    final counter = RM.inject<String>(
      () => 'str0',
      persist: () => PersistState(key: 'counter'),
    );
    store.store?.addAll({'counter': 'str1'});
    expect(counter.state, 'str1');
    counter.state = 'str2';
    expect(store.store, {'counter': 'str2'});
  });

  testWidgets('infer fromJson and toJson of bool', (tester) async {
    final counter = RM.inject<bool>(
      () => false,
      persist: () => PersistState(key: 'counter'),
    );
    store.store?.addAll({'counter': '1'});
    expect(counter.state, true);
    counter.toggle();
    await tester.pump();
    expect(counter.state, false);
    expect(store.store, {'counter': '0'});
  });
  testWidgets('can not infer fromJson for non primitive, it throws',
      (tester) async {
    expect(
      () => RM.inject<List<int>>(
        () => [0],
        persist: () => PersistState(key: 'counter'),
      ),
      throwsArgumentError,
    );
  });

  testWidgets('can not infer toJson for non primitive, it throws',
      (tester) async {
    expect(
      () => RM.inject<List<int>>(
        () => [0],
        persist: () => PersistState(
          key: 'counter',
          fromJson: (json) => [0],
        ),
      ),
      throwsArgumentError,
    );
  });

  testWidgets('deleteAll the persistance', (tester) async {
    final counter = RM.inject<int>(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        debugPrintOperations: true,
      ),
    );
    //first increment
    counter.state++;
    //after the first second
    await tester.pump(Duration(seconds: 1));
    expect(store.store!['counter'], '1');
    RM.deleteAllPersistState();
    await tester.pump();
    expect(store.store!['counter'], null);
    expect(counter.state, 1);
    //DeleteAll deletes the ca
    counter.setState((s) => future(1));
    expect(store.store!['counter'], null);
    expect(counter.state, 1);
    await tester.pump(Duration(seconds: 1));
    expect(store.store!['counter'], '1');
    expect(counter.state, 1);
  });
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
