import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'WHEN middleSnapState is defined'
    'THEN it is called when the app is initialized and when '
    'a notification is emitted'
    'ALL possible case are test for RM.inject',
    (tester) async {
      SnapState<int>? _snapState;
      SnapState<int>? _nextSnapState;
      final model = RM.inject<int>(
        () => 0,
        middleSnapState: (snapState, nextSnapState) {
          print(
            SnapState.log(
              snapState,
              nextSnapState,
              state: (snap) => '[${snap.data}]',
              preMessage: 'Counter',
            ),
          );
          _snapState = snapState;
          _nextSnapState = nextSnapState;
        },
      );
      expect(_snapState, null);
      expect(_nextSnapState, null);
      //
      expect(model.isIdle, true);
      //model is initialized
      expect(_snapState!.isIdle, true);
      expect(_snapState!.data, null);
      expect(_nextSnapState!.isIdle, true);
      expect(_nextSnapState!.data, 0);
      //
      model.state++;
      expect(_snapState!.isIdle, true);
      expect(_snapState!.data, 0);
      expect(_nextSnapState!.hasData, true);
      expect(_nextSnapState!.data, 1);
      expect(model.state, 1);
      //
      model.setState(
        (s) => throw Exception('Error'), /*catchError: true*/
      );
      expect(_snapState!.hasData, true);
      expect(_snapState!.data, 1);
      expect(_nextSnapState!.hasError, true);
      expect(_nextSnapState!.data, 1);
      expect(model.state, 1);
      //
      model.setState((s) => Future.delayed(Duration(seconds: 1), () => 2));
      expect(_snapState!.hasError, true);
      expect(_snapState!.data, 1);
      expect(_nextSnapState!.isWaiting, true);
      expect(_nextSnapState!.data, 1);
      expect(model.state, 1);
      //
      await tester.pump(Duration(seconds: 1));
      expect(_snapState!.isWaiting, true);
      expect(_snapState!.data, 1);
      expect(_nextSnapState!.hasData, true);
      expect(_nextSnapState!.data, 2);
      expect(model.state, 2);
      //
      model.setState(
        (s) => Future.delayed(
          Duration(seconds: 1),
          () => throw Exception('Error'),
        ),
      );
      expect(_snapState!.hasData, true);
      expect(_snapState!.data, 2);
      expect(_nextSnapState!.isWaiting, true);
      expect(_nextSnapState!.data, 2);
      expect(model.state, 2);
      //
      await tester.pump(Duration(seconds: 1));
      expect(_snapState!.isWaiting, true);
      expect(_snapState!.data, 2);
      expect(_nextSnapState!.hasError, true);
      expect(_nextSnapState!.data, 2);
      expect(model.state, 2);
      //
      model.onErrorRefresher!();
      expect(_snapState!.hasError, true);
      expect(_snapState!.data, 2);
      expect(_nextSnapState!.isWaiting, true);
      expect(_nextSnapState!.data, 2);
      expect(model.state, 2);
      //
      await tester.pump(Duration(seconds: 1));
      expect(_snapState!.isWaiting, true);
      expect(_snapState!.data, 2);
      expect(_nextSnapState!.hasError, true);
      expect(_nextSnapState!.data, 2);
      expect(model.state, 2);
      //
      model.refresh();
      expect(_snapState!.isIdle, true);
      expect(_snapState!.data, null);
      expect('$_snapState', 'REFRESHING');
      expect(_nextSnapState!.isIdle, true);
      expect(_nextSnapState!.data, 0);
      expect(model.state, 0);
      model.dispose();
      await tester.pump();
    },
  );
}
