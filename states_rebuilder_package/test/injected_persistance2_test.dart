import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';
import 'package:states_rebuilder/src/common/logger.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

var counter = RM.inject<int?>(
  () => 0,
  persist: () => PersistState(
    key: 'counter',
    fromJson: (json) => int.parse(json),
    toJson: (s) => '$s',
  ),

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

void main() async {
  StatesRebuilerLogger.isTestMode = true;

  final store = await RM.storageInitializerMock();
  counter.injectMock(() => 0);
  setUp(() {
    store.clear();
    counter.dispose();
  });
  testWidgets('Persist before calling', (tester) async {
    store.store.addAll({'counter': '10'});
    expect(counter.state, 10);
    counter.state = counter.state! + 1;
    expect(store.store, {'counter': '11'});
    // counter.state;
    //
  });

  testWidgets('persist with async read', (tester) async {
    store.isAsyncRead = true;
    store.timeToWait = 1000;
    store.store.addAll({'counter': '10'});
    expect(counter.state, null);
    await tester.pump();
    expect(counter.state, null);
    await tester.pump(Duration(seconds: 1));

    expect(counter.state, 10);
    counter.state = counter.state! + 1;
    await tester.pump(Duration(seconds: 1));

    expect(store.store, {'counter': '11'});
    //
    await tester.pump(Duration(seconds: 1));

    store.store['counter'] = '20';
    counter.refresh();
    await tester.pump();
    expect(counter.state, 0);
    await tester.pump(Duration(seconds: 1));
    expect(store.store, {'counter': '0'});
  });

  testWidgets('persist with async read with error', (tester) async {
    store.isAsyncRead = true;
    store.timeToThrow = 1000;
    store.exception = Exception('Read error');
    store.store.addAll({'counter': '10'});
    expect(counter.state, null);
    await tester.pump();
    expect(counter.state, null);
    await tester.pump(Duration(seconds: 1));
    expect(counter.hasError, true);
    store.store['counter'] = '10';
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
      // onInitialized: (_) => print('onInitialized'),
      // onDisposed: (_) => print('onDisposed'),
    );

    store.store.addAll({'counter': '10'});
    expect(counter.state, null);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 10);
    counter.state = counter.state! + 1;
    await tester.pump(Duration(seconds: 1));

    expect(store.store, {'counter': '11'});
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
      initialState: 0,
      // onInitialized: (_) => print('onInitialized'),
      // onDisposed: (_) => print('onDisposed'),
    );

    store.isAsyncRead = true;
    store.store.addAll({'counter': '10'});
    expect(counter.state, 0);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 10);
    counter.state = counter.state! + 1;
    await tester.pump(Duration(seconds: 1));

    expect(store.store, {'counter': '11'});
  });

  testWidgets('Persist before calling  (check run all test) ', (tester) async {
    store.store.addAll({'counter': '10'});
    counter = RM.inject(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
      ),
    );
    expect(counter.state, 10);
    counter.state = counter.state! + 1;
    await tester.pump(Duration(seconds: 1));

    expect(store.store, {'counter': '11'});
    //
  });

  testWidgets('persist with async read with injectFuture', (tester) async {
    var counter = RM.injectFuture(
      () => Future.value(0),
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
      ),
      initialState: 0,
    );
    store.isAsyncRead = true;
    store.store.addAll({'counter': '10'});
    expect(counter.state, 0);
    await tester.pump();
    expect(counter.state, 10);
    counter.state = counter.state + 1;
    await tester.pump(Duration(seconds: 1));

    expect(store.store, {'counter': '11'});
  });

  testWidgets('persist with async read and async fromJson using InjectFuture',
      (tester) async {
    counter = RM.injectFuture(
      () => Future.value(0),
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) async {
          await Future.delayed(Duration(seconds: 1));
          return int.parse(json);
        },
        toJson: (s) => '$s',
      ),
    );

    store.isAsyncRead = true;
    store.store.addAll({'counter': '10'});
    expect(counter.state, null);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 10);
    counter.state = counter.state! + 1;
    expect(store.store, {'counter': '11'});
  });
  testWidgets('persistStateProvider', (tester) async {
    counter = RM.injectFuture(
      () => Future.delayed(Duration(seconds: 1), () => 0),
      persist: () => PersistState(
        key: 'Future_counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
        persistStateProvider: PersistStoreMockImp(),
      ),
    );
    store.store.addAll({'Future_counter': '10'});
    expect(counter.state, null);
    await tester.pump(Duration(seconds: 1));
    expect(counter.state, 10);
    counter.state = counter.state! + 1;
  });

  testWidgets('Test try catch of PersistState', (tester) async {
    String error = '';
    counter = RM.inject(() => 0,
        persist: () => PersistState(
              key: 'counter',
              fromJson: (json) => int.parse(json),
              toJson: (s) => '$s',
              catchPersistError: true,
            ),
        onError: (e, s) {
          error = e.message;
        });

    store.exception = Exception('Read Error');
    await tester.pumpWidget(App());
    expect(StatesRebuilerLogger.message.contains('Read Error'), isTrue);

    store.exception = Exception('Write Error');
    counter.state = counter.state! + 1;
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
    counter = RM.inject(() => 0,
        persist: () => PersistState(
              key: 'counter',
              fromJson: (json) => int.parse(json),
              toJson: (s) => '$s',
              // catchPersistError: true,
            ),
        onError: (e, s) {});

    await tester.pumpWidget(App());

    store.exception = Exception('Write Error');
    store.timeToThrow = 1000;
    counter.state = counter.state! + 1;
    await tester.pump();
    expect(counter.state, 1);
    expect(counter.hasData, true);
    await tester.pump(Duration(seconds: 1));
    expect(counter.hasError, true);
    expect(counter.state, 0);
  });

  testWidgets('infer fromJson and toJson of int', (tester) async {
    counter = RM.inject(
      () => 0,
      persist: () => PersistState(key: 'counter'),
    );
    store.store.addAll({'counter': '10'});
    expect(counter.state, 10);
    counter.state = counter.state! + 1;
    expect(store.store, {'counter': '11'});
  });
  testWidgets('infer fromJson and toJson of double', (tester) async {
    final counter = RM.inject<double>(
      () => 0.0,
      persist: () => PersistState(key: 'counter'),
    );
    store.store.addAll({'counter': '10.0'});
    expect(counter.state, 10.0);
    counter.state = counter.state + 1;
    expect(store.store, {'counter': '11.0'});
  });
  testWidgets('infer fromJson and toJson of String', (tester) async {
    final counter = RM.inject<String>(
      () => 'str0',
      persist: () => PersistState(key: 'counter'),
    );
    store.store.addAll({'counter': 'str1'});
    expect(counter.state, 'str1');
    counter.state = 'str2';
    expect(store.store, {'counter': 'str2'});
  });
  testWidgets('infer fromJson and toJson of bool', (tester) async {
    final counter = RM.inject<bool>(
      () => false,
      persist: () => PersistState(key: 'counter'),
    );
    store.store.addAll({'counter': '1'});
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

  testWidgets('throttle the persistance', (tester) async {
    final counter = RM.inject(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        fromJson: (json) => int.parse(json),
        toJson: (s) => '$s',
        throttleDelay: 3000,
        debugPrintOperations: true,
      ),
    );
    expect(counter.state, 0);
    expect(store.store['counter'], null);

    //first increment
    counter.state = counter.state + 1;
    //after the first second
    await tester.pump(Duration(seconds: 1));
    //the state is not persisted
    expect(store.store['counter'], null);

    //the state is mutated and displayed
    expect(counter.state, 1);
    //
    //second increment
    counter.state = counter.state + 1;
    //after the another second
    await tester.pump(Duration(seconds: 1));
    //the state is not persisted
    expect(store.store['counter'], null);
    //the state is mutated and displayed
    expect(counter.state, 2);
    //
    counter.state = counter.state + 1;
    await tester.pump(Duration(seconds: 1));
    //After three seconds as in the throttleDelay the state is persisted
    expect(store.store['counter'], '3');
    expect(counter.state, 3);
    expect(StatesRebuilerLogger.message,
        '[states_rebuilder]: PersistState: write(counter, 3)');
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
    counter.state = counter.state + 1;
    //after the first second
    await tester.pump(Duration(seconds: 1));
    expect(store.store['counter'], '1');
    RM.deleteAllPersistState();
    await tester.pump();
  });

  testWidgets('read, delete , deleteAll with mock future time', (tester) async {
    final counter = RM.inject<int>(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        debugPrintOperations: true,
      ),
    );
    store.timeToWait = 1000;
    counter.state = counter.state + 1;
    await tester.pump(Duration(seconds: 1));
    expect(store.store['counter'], '1');
    //
    counter.deletePersistState();
    await tester.pump(Duration(seconds: 1));
    expect(store.store['counter'], null);
    //
    counter.state = counter.state + 1;
    await tester.pump(Duration(seconds: 1));
    expect(store.store['counter'], '2');
    //
    RM.deleteAllPersistState();
    await tester.pump(Duration(seconds: 1));
    expect(store.store['counter'], null);
  });

  testWidgets(
    'injectedStream works persisted state'
    'Case not initially persisted state',
    (tester) async {
      counter = RM.injectStream(
        () => Stream.periodic(Duration(seconds: 1), (num) => num * 10).take(3),
        persist: () => PersistState(
          key: 'counter',
        ),
      );
      expect(counter.state, null);
      expect(store.store['counter'], null);

      await tester.pump(Duration(seconds: 1));
      expect(counter.state, 0);
      expect(store.store['counter'], '0');

      await tester.pump(Duration(seconds: 1));
      expect(counter.state, 10);
      expect(store.store['counter'], '10');

      await tester.pump(Duration(seconds: 1));
      expect(counter.state, 20);
      expect(store.store['counter'], '20');
    },
  );

  testWidgets(
    'injectedStream works persisted state'
    'Case the state is already persisted',
    (tester) async {
      counter = RM.injectStream(
        () => Stream.periodic(Duration(seconds: 1), (num) => num * 10).take(3),
        persist: () => PersistState(
          key: 'counter',
        ),
      );
      store.store.addAll({'counter': '10'});
      expect(counter.state, 10);
      expect(store.store['counter'], '10');

      await tester.pump(Duration(seconds: 1));
      expect(counter.state, 10);
      expect(store.store['counter'], '10');
    },
  );
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
