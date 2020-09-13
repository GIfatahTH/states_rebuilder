import 'dart:math';

import 'package:flutter/foundation.dart';

import 'counter.dart';
import 'counter_error.dart';

@immutable
class CounterState {
  CounterState(this.counter);
  final Counter counter;

  Future<CounterState> increment(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));

    if (Random().nextBool()) {
      throw CounterError();
    } else {
      return CounterState(Counter(counter.count + 1));
    }
  }
}
