import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// Example of state cleaning (disposing off)
void main() {
  runApp(const MyApp());
}

@immutable
class CounterViewModel {
  final MyRepository repository;
  CounterViewModel({
    required this.repository,
  });

  // By default injected state is disposed of when no longer listened to.
  //
  // A state never listen to, never auto dispose.
  late final _counter = RM.inject(
    () => 0,
    // See the console log
    debugPrintWhenNotifiedPreMessage: '_counter',
    //
    // IF you set autoDisposeWhenNotUsed to false, initState is called once
    sideEffects: SideEffects(
      initState: () => increment(),
    ),
    // TODO uncomment the next line to prevent _counter from disposing of
    // autoDisposeWhenNotUsed: false,
  );
  int get counter => _counter.state;
  // As I want to encapsulate the _counter state, I expose the API that I need
  //
  // This is a matter of personal preference, you can make the _counter state
  // public
  late final onAll = _counter.onAll;
  void increment() {
    // One of the cases where you should use setState instead of stateAsync is when you
    // want to refresh the error.
    _counter.setState((s) => repository.incrementAsync(counter));
  }

  void dispose() {
    // IF a state is set to not disposed of automatically (autoDisposeWhenNotUsed: false)
    // it is a good practice to dispose of it manually
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

// Although _counter is used only in a part of the app (in CounterView), it is
// considered as global state. because only one instance of it is active at any
// instant.
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
class CounterView extends ReactiveStatelessWidget {
  const CounterView({Key? key}) : super(key: key);

  // TODO: set autoDisposeWhenNotUsed to false, and uncomment the following lines
  //
  // @override
  // void didMountWidget() {
  //   // The hook will be called each time this widget is created
  //   counterViewModel.increment();
  // }

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
