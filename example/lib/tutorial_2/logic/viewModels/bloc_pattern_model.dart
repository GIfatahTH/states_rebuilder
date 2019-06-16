import 'dart:async';

class BlocPatternModel {
  final StreamController<int> _controller = StreamController();

  Function(int) get counterSink => _controller.sink.add;

  Stream<int> get counterStream => _controller.stream;
  int _counter;
  increment() {
    _counter = (_counter ?? 0) + 1;
    counterSink(_counter);
  }

  dispose() {
    _controller.close();
  }
}
