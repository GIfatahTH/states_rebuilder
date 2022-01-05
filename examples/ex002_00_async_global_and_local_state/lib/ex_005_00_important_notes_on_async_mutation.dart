import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
/*
* In async state mutation, the state is supposed to wait only for one async task.
*
* If the state is waiting for an async task, and another async task is called,
* the state will cancel the old async task and start waiting for the new task.
*
* To let both async tasks work together, you have to await for the first async task
* before invoking the second, or just use two injected state of the same type and
* link them.
*/

// case1 waiting for the first async task to finish
@immutable
class CounterLogic1 {
  final _counter = RM.inject(() => 1, debugPrintWhenNotifiedPreMessage: '');

  void increment() async {
    await _counter.stateAsync;
    _counter.stateAsync = Future.delayed(
      const Duration(seconds: 2),
      () => _counter.state + 1,
    );
  }

  void multiplyBy10() async {
    await _counter.stateAsync;
    _counter.setState(
      (s) async {
        return Future.delayed(
          const Duration(seconds: 1),
          () => _counter.state * 10,
        );
      },
    );
  }
}

// case2: creating two state for the same object and link them
// see ex_016/00 (pessimistic update) of a concrete example of this case

@immutable
class CounterLogic2 {
  final _counter = RM.inject(() => 1);
  late final _counter2 = RM.inject(() => _counter.state);

  void increment() async {
    _counter.stateAsync = Future.delayed(
      const Duration(seconds: 2),
      () => _counter.state + 1,
    );
    await _counter.stateAsync;
    // after getting data
    _counter2.state = _counter.state;
  }

  void multiplyBy10() async {
    _counter2.setState(
      (s) async {
        return Future.delayed(
          const Duration(seconds: 1),
          () => _counter.state * 10,
        );
      },
      sideEffects: SideEffects.onData(
        (data) {
          _counter.state = data;
        },
      ),
    );
  }
}
