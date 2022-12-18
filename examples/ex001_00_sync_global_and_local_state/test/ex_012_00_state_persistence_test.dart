import 'package:ex001_00_sync_global_and_local_state/ex_012_00_state_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  final store = await RM.storageInitializerMock();
  setUp(() {
    store.clear();
  });
  testWidgets(
    'Counter increments smoke test',
    (WidgetTester tester) async {
      expect(store.store.isEmpty, true);
      await tester.pumpWidget(const MyApp());
      expect(find.text('0'), findsOneWidget);
      expect(store.store, {'counter': '0'});
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      expect(store.store, {'counter': '1'});
      //
      await tester.tap(find.text('Clear persisted State'));
      await tester.pump();
      expect(store.store.isEmpty, true);
      //
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      expect(store.store, {'counter': '2'});
      //
      counterViewModel.refreshTheState();
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      expect(store.store, {'counter': '0'});
    },
  );
}
