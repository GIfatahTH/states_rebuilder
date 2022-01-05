import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* In this example the sumCounter depends on the other two counter. When any of 
* the counter state changes, the sumCounter state will be recalculated.
*/
class CounterViewModel {
  final _counter1 = 0.inj();
  int get counter1 => _counter1.state;

  final _counter2 = 0.inj();
  int get counter2 => _counter2.state;

  // the _sumCounter depends on counter1 and counter2
  late final _sumCounter = RM.inject<int>(
    () {
      return _counter1.state + _counter2.state;
    },
    // the _sumCounter will listen to _counter1 and _counter2
    dependsOn: DependsOn(
      {_counter1, _counter2},
      // TODO try debounceDelay and throttleDelay
      // debounceDelay: 600,
      // throttleDelay: 600,
    ),
    debugPrintWhenNotifiedPreMessage: 'sumCounter',
  );
  int get sumCounter => _sumCounter.state;

  void incrementCounter1() {
    _counter1.state++;
  }

  void incrementCounter2() {
    _counter2.state++;
  }
}

final counterViewModel = CounterViewModel();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync dependent counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CountIncrementorWidget(
                  value: 'Counter1:  ${counterViewModel.counter1}',
                  onPressed: counterViewModel.incrementCounter1,
                ),
                const SizedBox(width: 32),
                _CountIncrementorWidget(
                  value: 'Counter2:  ${counterViewModel.counter2}',
                  onPressed: counterViewModel.incrementCounter2,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'The Sum is:  ${counterViewModel.sumCounter}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountIncrementorWidget extends StatelessWidget {
  const _CountIncrementorWidget({
    Key? key,
    required this.value,
    required this.onPressed,
  }) : super(key: key);
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headline4,
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onPressed,
          icon: const Icon(
            Icons.add,
            size: 24,
          ),
        ),
      ],
    );
  }
}
