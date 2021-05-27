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
}
