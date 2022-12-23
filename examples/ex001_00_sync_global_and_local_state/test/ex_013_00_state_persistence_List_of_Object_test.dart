import 'package:ex001_00_sync_global_and_local_state/ex_013_00_state_persistence_List_of_Object.dart';
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
      await tester.pumpWidget(const MaterialApp(home: MyApp()));
      expect(store.store, {});
      //
      await tester.tap(find.text('Go to counter view'));
      await tester.pumpAndSettle();
      expect(store.store, {});
      expect(find.byType(CounterView), findsNothing);
      //
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(CounterView), findsOneWidget);
      expect(store.store, {});
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.pump();
      expect(store.store, {'counter': '["{\\"value\\":0}"]'});
      //
      await tester.tap(find.text('Go to counter view'));
      await tester.pumpAndSettle();
      expect(find.byType(CounterView), findsOneWidget);
      expect(store.store, {'counter': '["{\\"value\\":0}"]'});
      //
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(CounterView), findsNWidgets(2));
      expect(find.text('0'), findsNWidgets(2));
      //
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      expect(find.text('0'), findsNWidgets(1));
      expect(find.text('1'), findsNWidgets(1));
      expect(store.store, {'counter': '["{\\"value\\":0}"]'});
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.pump();
      expect(store.store, {'counter': '["{\\"value\\":1}","{\\"value\\":0}"]'});
      //
      await tester.tap(find.text('Clear all persisted states'));
      await tester.tap(find.text('Go to counter view'));
      await tester.pumpAndSettle();
      expect(find.byType(CounterView), findsNothing);
      expect(store.store, {});
    },
  );
}
