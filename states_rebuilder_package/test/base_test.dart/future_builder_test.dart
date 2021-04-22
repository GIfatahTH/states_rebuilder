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
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: counter.futureBuilder<void>(
          future: (s, asycS) => s?.increment(),
          onWaiting: () => Text('Waiting...'),
          onError: (err) => Text('Error'),
          onData: (data) => Text('data'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN  '
    'THEN',
    (tester) async {
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: counter.futureBuilder<Counter>(
          future: (s, asycS) => s?.incrementImmutable(),
          onWaiting: () => Text('Waiting...'),
          onError: (err) => Text('Error'),
          onData: (data) => Text('${data?._count}'),
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
        child: counter.futureBuilder(
          onWaiting: () => Text('Waiting...'),
          onError: (err) => Text('Error'),
          onData: (data) => Text('$data'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('10'), findsOneWidget);
    },
  );
}
