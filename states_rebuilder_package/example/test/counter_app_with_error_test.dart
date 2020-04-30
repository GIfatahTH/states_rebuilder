import 'package:example/examples/counter_app_with_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  setUp(() {
    Injector.enableTestMode = true;
  });
  testWidgets(
    'Counter with error works',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Injector(
            inject: [Inject<CounterStore>(() => CounterTest())],
            builder: (context) {
              return App();
            },
          ),
        ),
      );

      //
      expect(find.text('0'), findsOneWidget);

      // tap FAB no error is expected
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);

      // tap FAB an error is expected
      (Injector.get<CounterStore>() as CounterTest).shouldThrow = true;
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    },
  );
}

class CounterTest extends CounterStore {
  int _count = 0;

  @override
  int get count => _count;

  bool shouldThrow = false;

  @override
  void increment() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (shouldThrow) {
      throw Exception('test error');
    }
    _count++;
  }
}
