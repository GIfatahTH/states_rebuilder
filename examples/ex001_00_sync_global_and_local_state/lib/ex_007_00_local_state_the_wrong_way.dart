import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// Example of local state done the wrong way
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
// As we need to use three widgets of CounterView and we want their states to be
// independent, this global injection will not work
//
// See the next example of the correct injection of local state
final counterViewModel = CounterViewModel('1');

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
          children: const [
            CounterView(counterName: '1'),
            CounterView(counterName: '2'),
            CounterView(counterName: '3'),
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
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Counter $counterName: ',
            style: Theme.of(context).textTheme.headline4,
          ),
          Text(
            '${counterViewModel.counter}',
            style: Theme.of(context).textTheme.headline4,
          ),
          TextButton(
            onPressed: counterViewModel.increment,
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
