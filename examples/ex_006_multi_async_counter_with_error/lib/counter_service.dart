import 'dart:math';

import 'counter.dart';
import 'counter_error.dart';

class CounterService {
  CounterService() {
    counter = Counter(0);
  }
  Counter counter;

  Future<void> increment(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));

    if (Random().nextBool()) {
      throw CounterError();
    }
    counter.increment();
  }
}
