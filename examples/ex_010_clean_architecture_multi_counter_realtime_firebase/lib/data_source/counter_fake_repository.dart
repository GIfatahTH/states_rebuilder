import 'dart:async';

import '../domain/entities/counter.dart';
import '../service/interfaces/i_counter_repository.dart';

class CounterFakeRepository implements ICounterRepository {
  CounterFakeRepository() {
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(Duration(seconds: 2));
    _controller.sink.add(_counters.values.toList());
  }

  @override
  Stream<List<Counter>> countersStream() {
    return _controller.stream;
  }

  @override
  Future<void> createCounter() async {
    await Future.delayed(Duration(milliseconds: 200));
    _counters[++_id] = Counter(id: _id, value: 0);
    _controller.sink.add(_counters.values.toList());
  }

  @override
  Future<void> deleteCounter(Counter counter) async {
    await Future.delayed(Duration(milliseconds: 200));
    _counters.remove(counter.id);
    _controller.sink.add(_counters.values.toList());
  }

  @override
  Future<void> setCounter(Counter counter) async {
    await Future.delayed(Duration(milliseconds: 200));
    _counters[counter.id] = counter;
    _controller.sink.add(_counters.values.toList());
  }

  StreamController<List<Counter>> _controller = StreamController();

  int _id = 1000000000001;

  Map<int, Counter> _counters = {
    1000000000001: Counter(id: 1000000000001, value: 0)
  };

  void dispose() {
    _controller.close();
  }
}
