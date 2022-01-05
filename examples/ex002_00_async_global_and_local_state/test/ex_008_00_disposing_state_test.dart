import 'dart:math';

import 'package:ex002_00_async_global_and_local_state/ex_008_00_disposing_state.dart'
    as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class MockRepository extends Mock implements app.MyRepository {}

class MockRepository1 extends Mock implements MyRepository {}

void main() {
  final mockRepository = MockRepository();
  final mockRepository1 = MockRepository1();
  setUp(() {
    app.myRepository.injectMock(() => mockRepository);
    myRepository.injectMock(() => mockRepository1);
    shouldUseDidMountWidget = false;
  });
  when(() => mockRepository.incrementAsync(0)).thenAnswer(
    (invocation) => Future.delayed(const Duration(seconds: 1), () => 1),
  );
  when(() => mockRepository1.incrementAsync(0)).thenAnswer(
    (invocation) => Future.delayed(const Duration(seconds: 1), () => 1),
  );
  when(() => mockRepository1.incrementAsync(1)).thenAnswer(
    (invocation) => Future.delayed(const Duration(seconds: 1), () => 2),
  );
  testWidgets(
    'WHEN autoDispose is true'
    'THEN the state is disposed when not used',
    (tester) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.tap(find.text('Go to counter view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to counter view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN autoDispose is false'
    'THEN the state is not disposed',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Go to counter view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to counter view'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.tap(find.text('Go to counter view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN autoDispose is false and when using DidMountWidget  '
    'THEN the state is disposed when not used',
    (tester) async {
      shouldUseDidMountWidget = true;
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Go to counter view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to counter view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
    },
  );
}

@immutable
class CounterViewModel {
  MyRepository get repository => myRepository.state;
  late final _counter = RM.inject(
    () => 0,
    debugPrintWhenNotifiedPreMessage: '_counter',
    sideEffects: SideEffects(
      initState: () => increment(),
    ),
    autoDisposeWhenNotUsed: false,
  );
  int get counter => _counter.state;
  late final onAll = _counter.onAll;
  void increment() {
    _counter.setState((s) => repository.incrementAsync(counter));
  }

  void dispose() {
    _counter.dispose();
  }
}

class MyRepository {
  Future<int> incrementAsync(int data) async {
    await Future.delayed(const Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('Unknown failure');
    }
    return data + 1;
  }
}

final myRepository = RM.inject(() => MyRepository());

final counterViewModel = CounterViewModel();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to counter view'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const CounterView();
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // manually dispose a state
        onPressed: counterViewModel.dispose,
        tooltip: 'Dispose state',
        child: const Icon(Icons.clear),
      ),
    );
  }
}

bool shouldUseDidMountWidget = false;

class CounterView extends ReactiveStatelessWidget {
  const CounterView({Key? key}) : super(key: key);
  @override
  void didMountWidget(context) {
    if (shouldUseDidMountWidget) {
      counterViewModel.increment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter view'),
      ),
      body: Center(
        child: counterViewModel.onAll(
          onWaiting: () => const CircularProgressIndicator(),
          onError: (err, refresh) => TextButton(
            onPressed: () => refresh(),
            child: Text('${err.message}. Tap to refresh'),
          ),
          onData: (data) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '${counterViewModel.counter}',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
