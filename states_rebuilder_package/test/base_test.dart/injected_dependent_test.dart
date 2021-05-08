import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'common.dart';

void main() {
  testWidgets(
    'WHEN modelB depends on ModelA (sync) '
    'THEN the state of modelB is recalculated when the state of ModelA changes'
    'AND WHEN the state of modelA is mutated async '
    'THEN the modelB follow the state status of modelA and is recalculated onData only',
    (tester) async {
      final modelA = RM.inject(() => 1);
      final modelB = RM.inject<int>(
        () => modelA.state * 2,
        dependsOn: DependsOn({modelA}),
      );
      expect(modelB.state, 2);
      expect(modelB.isIdle, true);
      modelA.state++;
      expect(modelB.state, 4);
      expect(modelB.hasData, true);
      //
      modelA.setState((s) => future(20));
      expect(modelB.isWaiting, true);
      expect(modelB.state, 4);
      await tester.pump(Duration(seconds: 1));
      expect(modelB.state, 40);
      expect(modelB.hasData, true);
      //
      modelA.setState((s) => future(20, Exception('Error')));
      expect(modelB.isWaiting, true);
      expect(modelB.state, 40);
      await tester.pump(Duration(seconds: 1));
      expect(modelB.state, 40);
      expect(modelB.hasError, true);
      expect(modelB.error.message, 'Error');
    },
  );

  testWidgets(
    'WHEN modelB depends on ModelA (RM.injectFuture) '
    'THEN the modelB follow the state status of modelA and is recalculated onData only'
    'Case future ends with data',
    (tester) async {
      final modelA = RM.injectFuture<int>(() => future(2), initialState: 1);
      final modelB = RM.inject<int?>(
        () => modelA.state * 2,
        dependsOn: DependsOn({modelA}),
      );
      expect(modelB.state, null);
      expect(modelB.isWaiting, true);
      await tester.pump(Duration(seconds: 1));
      expect(modelB.state, 4);
      expect(modelB.hasData, true);
    },
  );

  testWidgets(
    'WHEN modelB depends on ModelA (RM.injectFuture) '
    'THEN the modelB follow the state status of modelA and is recalculated onData only'
    'Case future ends with error',
    (tester) async {
      final modelA = RM.injectFuture(() => future(2, Exception('Error')));
      final modelB = RM.inject<int>(
        () => modelA.state * 2,
        dependsOn: DependsOn({modelA}),
        initialState: 0,
      );
      expect(modelB.state, 0);
      expect(modelB.isWaiting, true);
      await tester.pump(Duration(seconds: 1));
      expect(modelB.state, 0);
      expect(modelB.hasError, true);
    },
  );

  testWidgets(
    'WHEN modelB depends on ModelA (RM.injectStream) '
    'THEN the modelB follow the state status of modelA and is recalculated onData only'
    'Case stream emits data',
    (tester) async {
      final modelA = RM.injectStream(() => stream(3));
      final modelB = RM.inject<int?>(
        () => modelA.state * 2,
        dependsOn: DependsOn({modelA}),
      );
      expect(modelB.state, null);
      expect(modelB.isWaiting, true);
      await tester.pump(Duration(seconds: 1));
      expect(modelB.state, 2);
      expect(modelB.hasData, true);
      await tester.pump(Duration(seconds: 1));
      expect(modelB.state, 4);
      expect(modelB.hasData, true);
      await tester.pump(Duration(seconds: 1));
      expect(modelB.state, 6);
      expect(modelB.hasData, true);
    },
  );
  testWidgets(
    'WHEN modelB depends on ModelA (RM.injectStream) '
    'THEN the modelB follow the state status of modelA and is recalculated onData only'
    'Case stream ends with error',
    (tester) async {
      final modelA = RM.injectStream(() => stream(3, Exception('Error')));
      final modelB = RM.inject<int>(
        () => modelA.state * 2,
        dependsOn: DependsOn({modelA}),
        initialState: 0,
      );
      expect(modelB.state, 0);
      expect(modelB.isWaiting, true);
      await tester.pump(Duration(seconds: 1));
      expect(modelB.state, 2);
      expect(modelB.hasData, true);
      await tester.pump(Duration(seconds: 1));
      expect(modelB.state, 4);
      expect(modelB.hasData, true);
      await tester.pump(Duration(seconds: 1));
      expect(modelB.state, 4);
      expect(modelB.hasError, true);
    },
  );

  testWidgets(
    'WHEN modelC depends on ModelA and ModelB (sync) '
    'THEN the state of modelC is recalculated when the state of ModelA or ModelB changes'
    'AND WHEN the state of modelA or ModelB is mutated async '
    'THEN the modelC follow the state status of modelA or ModelB and is recalculated onData only',
    (tester) async {
      final modelA = RM.inject(
        () => 1,
        // debugPrintWhenNotifiedPreMessage: 'modelA',
      );
      final modelB = RM.inject(
        () => 1,
        // debugPrintWhenNotifiedPreMessage: 'modelB',
      );
      final modelC = RM.inject<int>(
        () => modelA.state + modelB.state,
        dependsOn: DependsOn({modelA, modelB}),
        // debugPrintWhenNotifiedPreMessage: 'modelC',
      );
      expect(modelC.state, 2);
      expect(modelC.isIdle, true);
      modelA.state++;
      expect(modelC.state, 3);
      expect(modelC.hasData, true);
      //
      modelB.state++;
      expect(modelC.state, 4);
      expect(modelC.hasData, true);
      //
      modelA.setState((s) => future(3));
      expect(modelC.isWaiting, true);
      expect(modelC.state, 4);
      await tester.pump(Duration(seconds: 1));
      expect(modelC.hasData, true);
      expect(modelC.state, 5);
      //
      modelB.setState((s) => future(3, Exception('Error')));
      expect(modelC.isWaiting, true);
      expect(modelC.state, 5);
      await tester.pump(Duration(seconds: 1));
      expect(modelC.hasError, true);
      expect(modelC.state, 5);
      //Waiting state dominate over error state
      modelA.setState((s) => future(4));
      modelB.setState(
        (s) => Future.delayed(
          Duration(milliseconds: 500),
          () => throw Exception('Error'),
        ),
      );
      expect(modelA.isWaiting, true);
      expect(modelB.isWaiting, true);
      expect(modelC.isWaiting, true);
      expect(modelC.state, 5);
      await tester.pump(Duration(milliseconds: 500));
      expect(modelA.isWaiting, true);
      expect(modelB.hasError, true);
      expect(modelC.isWaiting, true);
      expect(modelC.state, 5);
      await tester.pump(Duration(milliseconds: 500));
      expect(modelA.hasData, true);
      expect(modelB.hasError, true);
      expect(modelC.hasError, true);
      expect(modelC.error.message, 'Error');
      expect(modelC.state, 5);
    },
  );

  testWidgets(
    'WHEN shouldNotify is defined'
    'THEN when it returns false, the combined state will not recalculate',
    (tester) async {
      final modelA = RM.inject(() => 1);
      final modelB = RM.inject<int>(
        () => modelA.state * 2,
        dependsOn: DependsOn(
          {modelA},
          shouldNotify: (s) => (s ?? 0) < 6,
        ),
      );
      expect(modelB.state, 2);
      modelA.state++;
      expect(modelB.state, 4);
      modelA.state++;
      expect(modelB.state, 6);
      modelA.state++;
      expect(modelB.state, 6);
      modelA.state++;
      expect(modelB.state, 6);
    },
  );

  testWidgets(
    'WHEN debounceDelay is defined '
    'THEN the recalculation of the combined state is debounced',
    (tester) async {
      final modelA = RM.inject(() => 1);
      final modelB = RM.inject<int>(
        () => modelA.state * 2,
        dependsOn: DependsOn(
          {modelA},
          debounceDelay: 1000,
        ),
      );
      expect(modelB.state, 2);
      modelA.state++;
      expect(modelB.state, 2);
      await tester.pump(Duration(milliseconds: 500));
      expect(modelB.state, 2);
      await tester.pump(Duration(milliseconds: 400));
      expect(modelB.state, 2);
      await tester.pump(Duration(milliseconds: 100));
      expect(modelB.state, 4);
      //
      modelA.state++;
      expect(modelB.state, 4);
      await tester.pump(Duration(milliseconds: 500));
      expect(modelB.state, 4);
      await tester.pump(Duration(milliseconds: 400));
      expect(modelB.state, 4);
      //before debounce time ends
      modelA.state++;
      await tester.pump(Duration(milliseconds: 500));
      expect(modelB.state, 4);
      await tester.pump(Duration(milliseconds: 400));
      expect(modelB.state, 4);
      await tester.pump(Duration(milliseconds: 100));
      expect(modelB.state, 8);
    },
  );

  testWidgets(
    'WHEN throttleDelay is defined '
    'THEN the recalculation of the combined state is throttled',
    (tester) async {
      final modelA = RM.inject(() => 1);
      final modelB = RM.inject<int>(
        () => modelA.state * 2,
        dependsOn: DependsOn(
          {modelA},
          throttleDelay: 1000,
        ),
      );
      expect(modelB.state, 2);
      modelA.state++;
      expect(modelB.state, 4);
      await tester.pump(Duration(milliseconds: 500));
      modelA.state++;
      expect(modelB.state, 4);
      await tester.pump(Duration(milliseconds: 400));
      modelA.state++;
      expect(modelB.state, 4);
      await tester.pump(Duration(milliseconds: 100));
      expect(modelB.state, 4);
      await tester.pump(Duration(milliseconds: 1000));
      expect(modelB.state, 4);
      //
      modelA.state++;
      expect(modelB.state, 10);
      await tester.pump(Duration(milliseconds: 1000));
      expect(modelB.state, 10);
    },
  );

  testWidgets(
    'WHEN Dependent model has no widget observer, il will register as a side effect'
    'Once it has a widget observer, it will dispose the side effect and register the widget',
    (tester) async {
      final modelA = RM.inject(() => 1);
      final modelB = RM.inject<int>(
        () => modelA.state * 2,
        dependsOn: DependsOn({modelA}),
      );
      expect(modelB.state, 2);
      expect(modelB.isIdle, true);
      modelA.state++;
      expect(modelB.state, 4);
      expect(modelB.hasData, true);
      //

      final widget = On(() => Container()).listenTo(modelA);
      await tester.pumpWidget(widget);
      modelA.state++;
      expect(modelB.state, 6);
      modelA.state++;
      expect(modelB.state, 8);
    },
  );
}
