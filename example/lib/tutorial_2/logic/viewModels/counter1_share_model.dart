import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder_demo/tutorial_2/logic/services/counter_service.dart';

class Counter1ShareModel extends StatesRebuilder {
  final counterService = Injector.get<CounterService>();
  Counter1ShareModel() {
    counterService.streamingCounter.addListener(this);
  }
  AsyncSnapshot<int> get snapshot =>
      counterService.streamingCounter.snapshots[0];
  increment() {
    counterService.counterSink((snapshot.data ?? 0) + 1);
  }
}
