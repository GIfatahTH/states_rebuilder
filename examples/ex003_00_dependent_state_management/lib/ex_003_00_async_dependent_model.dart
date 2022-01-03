import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterViewModel {
  final counter1 = 0.inj();

  final counter2 = 0.inj();

  late final sumCounter = RM.inject<int>(
    () {
      return counter1.state + counter2.state;
    },
    dependsOn: DependsOn(
      {counter1, counter2},
      // // Try shouldNotify.
      // shouldNotify: (_) {
      //   // Skip waiting
      //   return !counter1.isWaiting && !counter2.isWaiting;
      // },
    ),
    debugPrintWhenNotifiedPreMessage: 'sumCounter',
  );

  void incrementCounter1() async {
    counter1.setState(
      (s) => Future.delayed(
        const Duration(seconds: 2),
        () => Random().nextBool()
            ? counter1.state + 1
            : throw Exception('Error counter1'),
      ),
    );
  }

  void incrementCounter2() {
    counter2.setState(
      (s) => Future.delayed(
        const Duration(seconds: 1),
        () => Random().nextBool()
            ? counter2.state + 1
            : throw Exception('Error counter2'),
      ),
    );
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
                Text(
                  'Counter1 :  ',
                  style: Theme.of(context).textTheme.headline4,
                ),
                counterViewModel.counter1.onAll(
                  onWaiting: () => const CircularProgressIndicator(),
                  onError: (err, refresh) => TextButton.icon(
                    onPressed: refresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(err.message),
                  ),
                  onData: (_) => _CountIncrementorWidget(
                    value: '${counterViewModel.counter1.state}',
                    onPressed: counterViewModel.incrementCounter1,
                  ),
                ),
                const SizedBox(width: 32),
                Text(
                  'Counter2 :  ',
                  style: Theme.of(context).textTheme.headline4,
                ),
                counterViewModel.counter2.onAll(
                  onWaiting: () => const CircularProgressIndicator(),
                  onError: (err, refresh) => TextButton.icon(
                    onPressed: refresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(err.message),
                  ),
                  onData: (data) => _CountIncrementorWidget(
                    value: '$data',
                    onPressed: counterViewModel.incrementCounter2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            counterViewModel.sumCounter.onAll(
              onWaiting: () => const CircularProgressIndicator(),
              onError: (err, refresh) => TextButton.icon(
                onPressed: refresh,
                icon: const Icon(Icons.refresh),
                label: Text(err.message),
              ),
              onData: (data) => Text(
                'The Sum is:  $data',
                style: Theme.of(context).textTheme.headline4,
              ),
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
