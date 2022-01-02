import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Example on how to instantiate local async state using InheritedWidget concepts.
*
* The case of List of local states is illustrated here.
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
            // use of inherited method to scop the state
            counterViewModel.inherited(
              stateOverride: () async {
                // Async initialization of the state
                await Future.delayed(const Duration(milliseconds: 1000));
                return CounterViewModel('1');
              },
              builder: (context) {
                return const CounterView(counterName: '1');
              },
            ),
            counterViewModel.inherited(
              stateOverride: () async {
                await Future.delayed(const Duration(milliseconds: 2000));
                return CounterViewModel('2');
              },
              builder: (context) {
                return const CounterView(counterName: '2');
              },
            ),
            counterViewModel.inherited(
              stateOverride: () async {
                await Future.delayed(const Duration(milliseconds: 1500));
                return CounterViewModel('3');
              },
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
    // Get the scoped local state
    //
    // Notice the difference between :
    // * counterViewModel(context) // returns the injected reactive state
    // * counterViewModel.of(context) // returns the model object
    final _counterViewModelRM = counterViewModel(context);
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Counter $counterName: ',
            style: Theme.of(context).textTheme.headline4,
          ),
          if (_counterViewModelRM.isWaiting)
            const CircularProgressIndicator()
          else
            Text(
              '${_counterViewModelRM.state.counter}',
              style: Theme.of(context).textTheme.headline4,
            ),
          TextButton(
            onPressed: () => _counterViewModelRM.state.increment(),
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
