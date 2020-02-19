import 'package:example/examples/counter_app_with_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  setUp(() {
    Injector.enableTestMode = true;
  });
  testWidgets(
    'pull down to refresh works',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Injector(
            inject: [Inject<Counter>(() => CounterTest())],
            builder: (context) {
              return App();
            },
          ),
        ),
      );

      //first pull
      await tester.fling(find.text('pull down to refresh the list'),
          const Offset(0.0, 300.0), 1000.0);
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // finish the scroll animation
      await tester.pump(
          const Duration(seconds: 1)); // finish the indicator settle animation
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsNothing);
      expect(find.text('3'), findsNothing);

      //second pull
      await tester.fling(find.text('pull down to refresh the list'),
          const Offset(0.0, 300.0), 1000.0);
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // finish the scroll animation
      await tester.pump(
          const Duration(seconds: 1)); // finish the indicator settle animation
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsNothing);

      //third pull
      await tester.fling(find.text('pull down to refresh the list'),
          const Offset(0.0, 300.0), 1000.0);
      await tester.pump();
      await tester
          .pump(const Duration(seconds: 1)); // finish the scroll animation
      await tester.pump(
          const Duration(seconds: 1)); // finish the indicator settle animation
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    },
  );
}

class CounterTest extends Counter {
  int _count = 0;

  increment() async {
    await Future.delayed(Duration(seconds: 1));
    _count++;
    count.add(_count);
  }
}
