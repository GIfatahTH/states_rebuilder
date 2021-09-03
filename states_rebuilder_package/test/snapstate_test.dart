import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'WHEN SnapState is created with error and no onErrorRefresher'
    'THEN it throws and asssertion error',
    (tester) async {
      expect(
        () => createSnapState(
          ConnectionState.done,
          0,
          'Error',
          onErrorRefresher: null,
        ),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    'WHEN SnapState is created with stackTrace and no error'
    'THEN it throws and assertion error',
    (tester) async {
      expect(
        () => createSnapState(
          ConnectionState.done,
          0,
          null,
          stackTrace: StackTrace.empty,
        ),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
    'WHEN toString of a snapState is call '
    'THEN it returns a String representing the current state',
    (tester) async {
      SnapState<int> snapState = createSnapState(
        ConnectionState.none,
        0,
        null,
      );
      expect('$snapState', 'SnapState<int>(isIdle : 0)');
      //
      snapState = createSnapState(
        ConnectionState.waiting,
        0,
        null,
      );
      //
      expect('$snapState', 'SnapState<int>(isWaiting (): 0)');
      //
      snapState = createSnapState(
        ConnectionState.done,
        0,
        null,
      );
      //
      expect('$snapState', 'SnapState<int>(hasData: 0)');
      //
      snapState = createSnapState(
        ConnectionState.done,
        0,
        Exception('Error'),
        onErrorRefresher: () {},
      );
      expect('$snapState', 'SnapState<int>(hasError: Exception: Error)');
      //
      final snapState2 = createSnapState(
        ConnectionState.done,
        0,
        Exception('Error'),
        onErrorRefresher: () {},
      );
      expect(snapState.hashCode != snapState2.hashCode, true);
    },
  );

  testWidgets(
    ' copyWith ',
    (tester) async {
      SnapState<int> snapState = createSnapState(
        ConnectionState.none,
        0,
        null,
      );
      expect('$snapState', 'SnapState<int>(isIdle : 0)');
      //
      snapState = snapState.copyTo(isWaiting: true);
      //
      expect('$snapState', 'SnapState<int>(isWaiting (): 0)');
      //
      snapState = snapState.copyTo(data: 0);
      //
      expect('$snapState', 'SnapState<int>(hasData: 0)');
      //
      snapState = snapState.copyTo(
        error: Exception('Error'),
        stackTrace: StackTrace.empty,
      );

      expect('$snapState', 'SnapState<int>(hasError: Exception: Error)');
      //
    },
  );

  testWidgets(
    'Text SnapState.error constructor ',
    (tester) async {
      final snap = SnapState.error('err');
      snap.onErrorRefresher!();
      final newSnap = snap.copyTo(isIdle: true);
      expect(newSnap.isIdle, true);
      final newSnap2 = snap.copyTo(isActive: false);
      expect(newSnap2.isActive, false);
      final newSnap3 = snap.copyToHasError('error');
      expect(newSnap3.hasError, true);
      expect(newSnap3.toString(), 'SnapState<dynamic>(hasError: error)');
      //
      final inj = RM.inject(() => '', debugPrintWhenNotifiedPreMessage: 'inj');
      expect(
          inj.snapState.toString(), 'SnapState<String>[inj](INITIALIZING...)');
    },
  );
  testWidgets(
    'test isActive',
    (tester) async {
      var counter = 0.inj();
      expect(counter.isActive, false);
      expect(counter.isIdle, true);
      counter.setState((s) => Future.delayed(1.seconds, () => throw 'Error'));
      await tester.pump();
      expect(counter.isActive, false);
      expect(counter.isWaiting, true);
      await tester.pump(1.seconds);
      expect(counter.hasError, true);
      expect(counter.isActive, false);
      counter.state++;
      await tester.pump();
      expect(counter.hasData, true);
      expect(counter.isActive, true);
      //
      counter.setState((s) => Future.delayed(1.seconds, () => throw 'Error'));
      await tester.pump();
      expect(counter.isActive, true);
      expect(counter.isWaiting, true);
      await tester.pump(1.seconds);
      expect(counter.hasError, true);
      expect(counter.isActive, true);
      //
      counter.refresh();
      await tester.pump();
      expect(counter.isIdle, true);
      expect(counter.isActive, true);
      counter.dispose();
      expect(counter.isActive, false);
      expect(counter.isIdle, true);
      //
      counter = RM.inject(() => 0);
      expect(counter.isActive, false);
      expect(counter.isIdle, true);
      counter.setState((s) => Future.delayed(1.seconds, () => throw 'Error'));
      await tester.pump();
      expect(counter.isActive, false);
      expect(counter.isWaiting, true);
      await tester.pump(1.seconds);
      expect(counter.hasError, true);
      expect(counter.isActive, false);
      counter.state++;
      await tester.pump();
      expect(counter.hasData, true);
      expect(counter.isActive, true);
      //
      counter.setState((s) => Future.delayed(1.seconds, () => throw 'Error'));
      await tester.pump();
      expect(counter.isActive, true);
      expect(counter.isWaiting, true);
      await tester.pump(1.seconds);
      expect(counter.hasError, true);
      expect(counter.isActive, true);
      //
      counter.refresh();
      await tester.pump();
      expect(counter.isIdle, true);
      expect(counter.isActive, true);
      counter.dispose();
      expect(counter.isActive, false);
      expect(counter.isIdle, true);
      //
      bool shouldThrow = true;
      final futureCounter = RM.injectFuture(
        () => Future.delayed(1.seconds, () => shouldThrow ? throw 'error' : 1),
      );
      expect(futureCounter.isWaiting, true);
      expect(futureCounter.isActive, false);
      await tester.pump(1.seconds);
      expect(futureCounter.hasError, true);
      expect(futureCounter.isActive, false);
      futureCounter.refresh();
      expect(futureCounter.isWaiting, true);
      expect(futureCounter.isActive, false);
      await tester.pump(1.seconds);
      expect(futureCounter.hasError, true);
      expect(futureCounter.isActive, false);
      shouldThrow = false;
      futureCounter.refresh();
      expect(futureCounter.isWaiting, true);
      expect(futureCounter.isActive, false);
      await tester.pump(1.seconds);
      expect(futureCounter.hasData, true);
      expect(futureCounter.hasData, true);
      futureCounter.refresh();
      expect(futureCounter.isWaiting, true);
      expect(futureCounter.isActive, true);
      await tester.pump(1.seconds);
      expect(futureCounter.hasData, true);
      expect(futureCounter.hasData, true);
    },
  );
}
