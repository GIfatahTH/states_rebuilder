import 'package:ex002_00_async_global_and_local_state/ex_013_00_state_persistance_for_injected_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  final localStorage = await RM.storageInitializerMock();
  setUp(() {
    localStorage.store.clear();
  });
  testWidgets(
    'data is persisted when streams emit date'
    'THEN',
    (tester) async {
      counterRM1.injectStreamMock(
        () => Stream.periodic(const Duration(seconds: 1), (val) => 10 * val),
      );
      counterRM2.injectStreamMock(
        () => Stream.periodic(const Duration(seconds: 1), (val) => 20 * val),
      );
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('0'), findsNWidgets(2));
      expect(localStorage.store, {'counter1': '0', 'counter2': '0'});
      //
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(localStorage.store, {'counter1': '10', 'counter2': '20'});
    },
  );

  testWidgets(
    'Stream with shouldRecreateTheState=true without pre stored data',
    (tester) async {
      Set<int> counter1Values = {};
      Set<int> counter2Values = {};
      await tester.pumpWidget(const MyApp());
      // Streams are triggered
      expect(counterRM1.isWaiting, true);
      expect(counterRM2.isWaiting, true);
      expect(counterRM1.subscription, isNotNull);
      expect(counterRM2.subscription, isNotNull);
      await tester.pump(const Duration(seconds: 5));
      counter1Values.add(counterRM1.state);
      counter2Values.add(counterRM2.state);
      await tester.pump(const Duration(seconds: 5));
      counter1Values.add(counterRM1.state);
      counter2Values.add(counterRM2.state);
      await tester.pump(const Duration(seconds: 5));
      counter1Values.add(counterRM1.state);
      counter2Values.add(counterRM2.state);
      await tester.pump(const Duration(seconds: 5));
      counter1Values.add(counterRM1.state);
      counter2Values.add(counterRM2.state);
      // counter values are changed
      expect(counter1Values.length > 1, true);
      expect(counter2Values.length > 1, true);
      expect(counterRM1.subscription, isNotNull);
      expect(counterRM2.subscription, isNotNull);
    },
  );
  testWidgets(
    'Stream with shouldRecreateTheState=true will be triggered to emit data',
    (tester) async {
      localStorage.store = {'counter1': '10', 'counter2': '20'};
      Set<int> counter1Values = {};
      Set<int> counter2Values = {};
      await tester.pumpWidget(const MyApp());
      // getting the pre stored date
      expect(counterRM1.isWaiting, false);
      expect(counterRM2.isWaiting, false);
      expect(counterRM1.subscription, isNotNull);
      expect(counterRM2.subscription, isNull);
      //
      counter1Values.add(counterRM1.state);
      counter2Values.add(counterRM2.state);

      await tester.pump(const Duration(seconds: 5));
      counter1Values.add(counterRM1.state);
      counter2Values.add(counterRM2.state);
      await tester.pump(const Duration(seconds: 5));
      counter1Values.add(counterRM1.state);
      counter2Values.add(counterRM2.state);
      await tester.pump(const Duration(seconds: 5));
      counter1Values.add(counterRM1.state);
      counter2Values.add(counterRM2.state);
      await tester.pump(const Duration(seconds: 5));
      counter1Values.add(counterRM1.state);
      counter2Values.add(counterRM2.state);
      // stream1 is triggered
      expect(counter1Values.length > 1, true);
      // stream 2 is not triggered
      expect(counter2Values.length == 1, true);
      expect(counterRM1.subscription, isNotNull);
      expect(counterRM2.subscription, isNull);
    },
  );
}
