import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'common_widgets/refresh_widget.dart';
/*
* This is similar to the last async counter app. Here we will use the states_rebuild
* flags.
*
* In most useful cases, we are interested in four state flags:
* 1. the initial state ( isIdle )
* 2. the loading state ( isWaiting )
* 1. the error state ( hasError )
* 1. the data state ( hasData )
*
* states_rebuilder provide you with these four state flags
*/

// We no longer need the CounterState
//
// class CounterState {
//   final int data;
//   final dynamic error;
//   final bool isIdle;
//   final bool isWaiting;
//   CounterState._({
//     required this.data,
//     this.error,
//     this.isIdle = false,
//     this.isWaiting = false,
//   });

//   bool get hasError => error != null;
//   bool get hasData => !hasError && !isWaiting && !isIdle;

//   factory CounterState.idle() => CounterState._(data: 0, isIdle: true);
//   CounterState setToIsWaiting() => CounterState._(data: data, isWaiting: true);
//   CounterState setToHasError(dynamic error) => CounterState._(
//         data: data,
//         error: error,
//       );
//   CounterState setToHasData(int data) => CounterState._(data: data);
// }

// As you will see this is a lot easier than the first example.
// The next example is even more simpler
@immutable
class CounterViewModel {
  // Our state is a simple integer
  final _counterState = RM.inject(() => 0);
  int get counter => _counterState.state;
  bool get isWaiting => _counterState.isWaiting;
  bool get hasError => _counterState.hasError;
  String get error => _counterState.error.message;

  void increment() async {
    try {
      // Set the state to the isWaiting state and notify listeners
      _counterState.setToIsWaiting();
      final result = await myRepository.state.incrementAsync(counter);
      // set the state to the hasData state and notify listeners
      _counterState.setToHasData(result);
    } catch (e, s) {
      if (e is Error) {
        rethrow;
      }
      // set the state to the error state and notify listeners
      _counterState.setToHasError(
        e,
        stackTrace: s,
        // refresher is used to recall the callback the causes the error.
        //
        // This maybe useful in case of network failure to lel the user fix the
        // network and try again
        refresher: increment,
      );
    }
  }

  Future<void> refreshCounter() async {
    try {
      // Skipping the waiting state
      final result = await myRepository.state.incrementAsync(counter);
      _counterState.setToHasData(result);
    } catch (e) {
      if (e is Error) {
        rethrow;
      }
      // Skipping the hasError state
      _counterState.setToHasData(counter);
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
                        // refresh the counter. isWaiting and hasError are skipped
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
