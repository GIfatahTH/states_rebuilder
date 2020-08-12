import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  final int _incrementBy;
  final bool shouldThrow;
  Counter({int incrementBy = 1, this.shouldThrow = false})
      : _incrementBy = incrementBy;
  int _count = 0;
  int get count => _count * _incrementBy;
  void increment() {
    if (shouldThrow) {
      throw Exception('Counter Error');
    }
    _count++;
  }
}

int dataFromInjection;
String errorFromInjection;

final counter = RM.inject(
  () => Counter(),
  onData: (counter) => dataFromInjection = counter.count,
  onError: (e, s) => errorFromInjection = e.message,
);

class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: counter.rebuilder(
        () => Text('${counter.state.count}'),
      ),
    );
  }
}

void main() {
  //Default injected mock
  counter.injectMock(() => Counter(incrementBy: 2));
  testWidgets('should increment counter', (tester) async {
    await tester.pumpWidget(CounterApp());
    expect(find.text('0'), findsOneWidget);
    counter.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    counter.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
  });
  testWidgets('should override counter injection', (tester) async {
    counter.injectMock(() => Counter(incrementBy: 5));
    await tester.pumpWidget(CounterApp());
    expect(find.text('0'), findsOneWidget);
    counter.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
    counter.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('should use the default injected mock (when run all tests)',
      (tester) async {
    await tester.pumpWidget(CounterApp());
    expect(find.text('0'), findsOneWidget);
    counter.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(dataFromInjection, 2);
    counter.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
    expect(dataFromInjection, 4);
  });
  testWidgets('should throw error (override injection to throw error)',
      (tester) async {
    counter.injectMock(() => Counter(incrementBy: 10, shouldThrow: true));
    await tester.pumpWidget(CounterApp());
    expect(find.text('0'), findsOneWidget);
    counter.setState((s) => s.increment());
    await tester.pump();
    expect(errorFromInjection, 'Counter Error');
    errorFromInjection = null;
  });

  testWidgets('onSetState error override error defined in the injection',
      (tester) async {
    counter.injectMock(() => Counter(incrementBy: 10, shouldThrow: true));
    String _errorMessage;
    await tester.pumpWidget(CounterApp());
    expect(find.text('0'), findsOneWidget);
    counter.setState(
      (s) => s.increment(),
      onError: (_, error) => _errorMessage = error.message,
    );
    await tester.pump();
    expect(_errorMessage, 'Counter Error');
    expect(errorFromInjection, null);
  });
  testWidgets('should use the default injected mock (when run all tests)',
      (tester) async {
    await tester.pumpWidget(CounterApp());
    expect(find.text('0'), findsOneWidget);
    counter.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    counter.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
  });
}
