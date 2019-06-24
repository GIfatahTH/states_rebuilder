import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../../logic/services/counter_service.dart';

class Counter2ShareModel extends StatesRebuilder {
  final counterService = Injector.get<CounterService>();
  Counter2ShareModel() {
    counterService.streamingCounter.addListener(this);
  }
  AsyncSnapshot<int> get snapshot =>
      counterService.streamingCounter.snapshots[0];
  increment() {
    counterService.counterSink((snapshot.data ?? 0) + 1);
  }
}
