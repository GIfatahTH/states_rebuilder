import 'package:ex002_00_async_global_and_local_state/ex_012_00_state_persistence_for_injected_future.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  final localStorage = await RM.storageInitializerMock();

  testWidgets(
    'WHEN app first starts, '
    'THEN the future is triggered and '
    'AND WHEN the future resolves'
    'THEN the date is stored',
    (tester) async {
      counterRM.injectFutureMock(
        () => Future.delayed(const Duration(seconds: 1), () => 100),
      );
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
      expect(localStorage.store, {'counter': '100'});
    },
  );
  testWidgets(
    'WHEN app first starts again, '
    'THEN the future is not triggered '
    'AND we get the stored date',
    (tester) async {
      localStorage.store = {'counter': '100'};
      await tester.pumpWidget(const MyApp());
      expect(find.text('100'), findsOneWidget);
      expect(localStorage.store, {'counter': '100'});
      //
      RM.deleteAllPersistState();
      localStorage.store = {};
    },
  );
}
