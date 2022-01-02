import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Fixing the last example.
*
* The right way of injecting local states
*/

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

// Create a global instance of CounterViewModel
//
// This time we inject the CounterViewModel and postpone it initialization in
// the UI
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // use of inherited method to scop local states
            counterViewModel.inherited(
              stateOverride: () => CounterViewModel('1'),
              builder: (context) {
                return const CounterView(counterName: '1');
              },
            ),
            counterViewModel.inherited(
              stateOverride: () => CounterViewModel('2'),
              builder: (context) {
                return const CounterView(counterName: '2');
              },
            ),
            counterViewModel.inherited(
              stateOverride: () => CounterViewModel('3'),
              builder: (context) {
                return const CounterView(counterName: '3');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CounterView extends ReactiveStatelessWidget {
  const CounterView({
    Key? key,
    required this.counterName,
  }) : super(key: key);
  final String counterName;

  @override
  Widget build(BuildContext context) {
    final _counterViewModel = counterViewModel.of(context);
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Counter $counterName: ',
            style: Theme.of(context).textTheme.headline4,
          ),
          Text(
            '${_counterViewModel.counter}',
            style: Theme.of(context).textTheme.headline4,
          ),
          TextButton(
            onPressed: _counterViewModel.increment,
            child: const Icon(
              Icons.add,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
