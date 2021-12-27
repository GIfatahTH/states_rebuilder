import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// Example of use of OnBuilder widget with async state
void main() {
  runApp(const MyApp());
}

@immutable
class CounterViewModel {
  final MyRepository repository;
  CounterViewModel({
    required this.repository,
  });
  late final counterRM = RM.inject(
    () => 0,
    debugPrintWhenNotifiedPreMessage: '_counter',
    autoDisposeWhenNotUsed: false,
  );

  void increment() {
    counterRM.setState((s) => repository.incrementAsync(counterRM.state));
  }

  void dispose() {
    // IF a state is set to not disposed of automatically (autoDisposeWhenNotUsed: false)
    // it is a good practice to dispose of it manually
    counterRM.dispose();
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

final counterViewModel = CounterViewModel(repository: MyRepository());

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

// Try to navigate back and forth until you see the error message
class CounterView extends StatelessWidget {
  const CounterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter view'),
      ),
      body: Center(
        // On
        child: OnBuilder.all(
          listenTo: counterViewModel.counterRM,
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
                '$data ',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
          sideEffects: SideEffects(
            initState: () => counterViewModel.increment(),
          ),
        ),
      ),
    );
  }
}
