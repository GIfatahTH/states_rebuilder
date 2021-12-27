import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'common_widgets/refresh_widget.dart';

// This is similar to the two previous examples. Here we will use the full
// states_rebuilder api for async state mutation.

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

@immutable
class CounterViewModel {
  final _counterState = RM.inject(() => 0);
  int get counter => _counterState.state;
  bool get isWaiting => _counterState.isWaiting;
  bool get hasError => _counterState.hasError;
  String get error => _counterState.error.message;

  void increment() async {
    // Simply this replaces all the old code.
    //
    // state flags are set automatically for us.
    //
    // To get more options and to skip the waiting or error use setState
    //
    _counterState.stateAsync = myRepository.state.incrementAsync(counter);
    // try {
    //   _counterState.setToIsWaiting();
    //   final result = await myRepository.state.incrementAsync(counter);
    //   _counterState.setToHasData(result);
    // } catch (e) {
    //   if (e is Error) {
    //     rethrow;
    //   }
    //   _counterState.setToHasError(e);
    // }
  }

  Future refreshCounter() async {
    // Here we use setState to skip the waiting and error state
    return _counterState.setState(
      (s) => myRepository.state.incrementAsync(counter),
      //
      // stateInterceptor is called after next state calculation, and just before
      // state mutation. It exposes the current and the next snapState
      stateInterceptor: (currentSnap, nextSnap) {
        // if the next state will be the waiting or the error state,
        // just return the current sate
        if (nextSnap.isWaiting || nextSnap.hasError) {
          return currentSnap;
        }
        //
        // This is the right place to do some state validation before mutation
      },
    );

    // try {
    //   final result = await myRepository.state.incrementAsync(counter);
    //   _counterState.setToHasData(result);
    // } catch (e) {
    //   if (e is Error) {
    //     rethrow;
    //   }
    //   _counterState.setToHasData(counter);
    // }
  }
}

// NOTE: One be difference between example 1 and 2 with this example is the following:
// - when you call increment method while waiting for refresh async task,
//   the latter task is canceled. Because when using states_rebuilder full api,
//   only one async task is executed in any time, if a second async task is called,
//   while the state is waiting for an async task the older is canceled.
//   See further examples for more information.

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
