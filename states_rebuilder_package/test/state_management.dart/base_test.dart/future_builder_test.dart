// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'common.dart';

class Counter {
  int _count = 0;
  Future<void> increment() async {
    await future(0);
    _count++;
  }

  Future<Counter> incrementImmutable() async {
    await future(0);
    _count++;
    return this;
  }
}

final counter = RM.inject(() => Counter());

void main() {
  testWidgets(
    'WHEN'
    'THEN',
    (tester) async {
      var message = '';
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        // child: counter.futureBuilder<void>(
        child: OnBuilder<void>.createFuture(
          creator: () {
            message = 'isWaiting';
            return counter.state.increment();
          },
          // future: (s, asyncS) => s?.increment(),
          sideEffects: SideEffects(
            onSetState: (snap) {
              if (snap.isWaiting) {
                message = '';
              } else {
                message = 'hasData';
              }
            },
            dispose: () => counter.disposeIfNotUsed(),
          ),
          builder: (rm) {
            return rm.onAll(
              onWaiting: () => Text('Waiting...'),
              onError: (err, _) => Text('Error'),
              onData: (data) => Text('data'),
            );
          },
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      expect(message, 'isWaiting');
      await tester.pump(Duration(seconds: 1));
      expect(find.text('data'), findsOneWidget);
      expect(message, 'hasData');
    },
  );

  testWidgets(
    'WHEN  '
    'THEN',
    (tester) async {
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        // child: counter.futureBuilder<Counter>(
        //   future: (s, asycS) => s?.incrementImmutable(),
        //   onWaiting: () => Text('Waiting...'),
        //   onError: (err) => Text('Error'),
        //   onData: (data) => Text('${data?._count}'),
        // ),
        child: OnBuilder<Counter>.createFuture(
          creator: () {
            return counter.state.incrementImmutable();
          },
          builder: (rm) {
            return rm.onAll(
              onWaiting: () => Text('Waiting...'),
              onError: (err, _) => Text('Error'),
              onData: (data) => Text('${data._count}'),
            );
          },
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN  1'
    'THEN  ',
    (tester) async {
      final counter = RM.injectFuture(() => future(10));
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        // child: counter.futureBuilder(
        //   onWaiting: () => Text('Waiting...'),
        //   onError: (err) => Text('Error'),
        //   onData: (data) => Text('$data'),
        // ),
        child: OnBuilder<int>.createFuture(
          creator: () {
            return counter.stateAsync;
          },
          builder: (rm) {
            return rm.onAll(
              onWaiting: () => Text('Waiting...'),
              onError: (err, _) => Text('Error'),
              onData: (data) => Text('$data'),
            );
          },
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('10'), findsOneWidget);
    },
  );
}
