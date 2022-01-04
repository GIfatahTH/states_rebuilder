import 'package:ex001_00_sync_global_and_local_state/ex_003_00_default_counter_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'Counter increments smoke test (use OnReactive)',
    (WidgetTester tester) async {
      useOnReactive = true;
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);
      expect(numberOfMyHomePageRebuild, 0);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
      expect(numberOfMyHomePageRebuild, 0);
    },
  );
  testWidgets(
    'Counter increments smoke test (use CounterWidget)',
    (WidgetTester tester) async {
      useOnReactive = false;
      numberOfMyHomePageRebuild = -1;
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);
      expect(numberOfMyHomePageRebuild, 0);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
      expect(numberOfMyHomePageRebuild, 0);
    },
  );
}

int numberOfMyHomePageRebuild = -1;
bool useOnReactive = true;

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

class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  void _incrementCounter() {
    counter.state++;
  }

  @override
  Widget build(BuildContext context) {
    numberOfMyHomePageRebuild++;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            useOnReactive
                ? OnReactive(
                    () {
                      return Text(
                        '${counter.state}',
                        style: Theme.of(context).textTheme.headline4,
                      );
                    },
                  )
                : const CounterWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CounterWidget extends ReactiveStatelessWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '${counter.state}',
      style: Theme.of(context).textTheme.headline4,
    );
  }
}
