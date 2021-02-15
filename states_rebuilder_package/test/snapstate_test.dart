import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

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
      expect('$snapState', 'isIdle : 0');
      //
      snapState = createSnapState(
        ConnectionState.waiting,
        0,
        null,
      );
      //
      expect('$snapState', 'isWaiting : 0');
      //
      snapState = createSnapState(
        ConnectionState.done,
        0,
        null,
      );
      //
      print(snapState);
      expect('$snapState', 'hasData: 0');
      //
      snapState = createSnapState(
        ConnectionState.done,
        0,
        Exception('Error'),
        onErrorRefresher: () {},
      );
      expect('$snapState', 'hasError: Exception: Error');
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
