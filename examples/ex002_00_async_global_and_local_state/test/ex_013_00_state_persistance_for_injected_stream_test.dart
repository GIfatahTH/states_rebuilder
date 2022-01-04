import 'package:ex002_00_async_global_and_local_state/ex_013_00_state_persistance_for_injected_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  final localStorage = await RM.storageInitializerMock();

  setUp(
    () {
      counterRM1.injectStreamMock(
        () => Stream.periodic(const Duration(seconds: 1), (val) => 10 * val),
      );
      counterRM2.injectStreamMock(
        () => Stream.periodic(const Duration(seconds: 1), (val) => 20 * val),
      );
    },
  );
  testWidgets(
    'data is persisted when streams emit date'
    'THEN',
    (tester) async {
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
    'Stream with shouldRecreateTheState=true will be triggered to emit data',
    (tester) async {
      localStorage.store = {'counter1': '10', 'counter2': '20'};
      await tester.pumpWidget(const MyApp());
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      localStorage.store = {'counter1': '10', 'counter2': '20'};
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      localStorage.store = {'counter1': '10', 'counter2': '20'};
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('20'), findsNWidgets(2));
      localStorage.store = {'counter1': '20', 'counter2': '20'};
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('30'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      localStorage.store = {'counter1': '30', 'counter2': '20'};
    },
  );
}
