import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// Fixes the last local state example
void main() {
  runApp(const MyApp());
}

@immutable
class CounterViewModel {
  CounterViewModel(this.counterName);
  final String counterName;
  late final _counter = RM.inject(
    () => 0,
    debugPrintWhenNotifiedPreMessage: '_counter $counterName',
  );

  int get counter => _counter.state;
  void increment() {
    _counter.state++;
  }
}

final counterViewModel = RM.inject<CounterViewModel>(
  () => throw UnimplementedError(),
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: counterViewModel.inherited(
        stateOverride: () => CounterViewModel('1'),
        builder: (context) {
          return const CounterView(counterId: 1);
        },
      ),
    );
  }
}

class CounterView extends ReactiveStatelessWidget {
  const CounterView({
    Key? key,
    this.counterId = 1,
  }) : super(key: key);
  final int counterId;

  @override
  Widget build(BuildContext context) {
    final _counterViewModel = counterViewModel.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Counter $counterId view'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${_counterViewModel.counter}',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return counterViewModel.inherited(
                      stateOverride: () => CounterViewModel('${counterId + 1}'),
                      builder: (context) {
                        return CounterView(counterId: counterId + 1);
                      },
                    );
                  },
                ),
              ),
              child: const Text('Go to next counter'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _counterViewModel.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
