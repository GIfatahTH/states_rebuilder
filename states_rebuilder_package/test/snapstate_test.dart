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
}
