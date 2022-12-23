import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'common_widgets/refresh_widget.dart';

/*
* The async counter app, rewritten using custom user flags for initial, loading
* data, and error status.
*
* Using the approach defined here, you can build the most complex app. This
* approach is similar to the BloC approach
*
* Define our Counter state,
*/
class CounterState {
  // the Counter state holds the data, the error and its status flags
  final int data;
  final dynamic error;
  final bool isIdle;
  final bool isWaiting;
  bool get hasError => error != null;
  bool get hasData => !hasError && !isWaiting && !isIdle;

  // Default constructor is private. We want to control what counter state is
  // created via a named constructor
  CounterState._({
    required this.data,
    this.error,
    this.isIdle = false,
    this.isWaiting = false,
  });

  // The starting state of the counter
  factory CounterState.idle() => CounterState._(data: 0, isIdle: true);

  // Counter is waiting for some async task
  CounterState setToIsWaiting() => CounterState._(data: data, isWaiting: true);

  // Counter is in the error state
  CounterState setToHasError(dynamic error) => CounterState._(
        data: data,
        error: error,
      );

  // Counter has a valid data
  CounterState setToHasData(int data) => CounterState._(data: data);
}

@immutable
class CounterViewModel {
  MyRepository get repository => myRepository.state;
  // This is our injected CounterState.
  // It is private because we want to control it via getters and setters
  final _counterState = RM.inject(() => CounterState.idle());
  //
  // Getter to expose the need data
  int get counter => _counterState.state.data;
  bool get isWaiting => _counterState.state.isWaiting;
  bool get hasError => _counterState.state.hasError;
  String get error => _counterState.state.error.message;

  // Method to mutate the state

  // This is the common pattern to use with async method:
  // We set the state to the awaiting state before calling the async method.
  // If the future resolved with valid date, we set the state to hasData.
  // In case of error, we set the state to hold the error.
  void increment() async {
    try {
      // Set the CounterState to the waiting state and notify listeners
      // Widget listeners will display a CircularProgressIndicator
      _counterState.state = _counterState.state.setToIsWaiting();
      final result = await repository.incrementAsync(counter);
      // Set the Counter state with valid data
      _counterState.state = _counterState.state.setToHasData(result);
    } catch (e) {
      if (e is Error) {
        // In real situation, we want to capture the exception and let error be
        // rethrown
        rethrow;
      }
      // Set the Counter state in the error state
      _counterState.state = _counterState.state.setToHasError(e);
    }
  }

  // Some times we need to skip the waiting or error state.
  Future<void> refreshCounter() async {
    try {
      // Skipping the waiting state
      final result = await repository.incrementAsync(counter);
      _counterState.state = _counterState.state.setToHasData(result);
    } catch (e) {
      if (e is Error) {
        //
        rethrow;
      }
      // Skipping the hasError state
      _counterState.state = _counterState.state.setToHasData(counter);
    }
  }
}

// This repo must be mocked in tests
class MyRepository {
  Future<int> incrementAsync(int data) async {
    await Future.delayed(const Duration(seconds: 2));
    if (Random().nextBool()) {
      throw Exception('Unknown failure');
    }
    return data + 1;
  }
}

// To make our repository mockable, we inject it using RM.inject.
//
// In tests, we can mock it using myRepository.injectMock(()=> MockRepository()),
//
// See test folder
final myRepository = RM.inject(() => MyRepository());

// As this is a global state, and MyHomePageViewModel is immutable,
// it is safe to instantiate it globally.
final counterViewModel = CounterViewModel();

void main() {
  runApp(const MyApp());
}

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

// No logic inside MyHomePage
class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: counterViewModel.isWaiting
            ? const CircularProgressIndicator()
            : counterViewModel.hasError
                ? Text(counterViewModel.error)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'You have pushed the button this many times:',
                      ),
                      Text(
                        '${counterViewModel.counter}',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      const SizedBox(height: 12),
                      RefreshWidget(
                        child: const Icon(Icons.refresh),
                        // Refresh the counter, waiting and error status are skipped
                        onPressed: counterViewModel.refreshCounter,
                      )
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => counterViewModel.increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
