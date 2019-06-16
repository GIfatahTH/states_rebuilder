import 'dart:async';

import 'package:states_rebuilder/states_rebuilder.dart';

class CounterService {
  final StreamController<int> _controller = StreamController();
  Streaming<int, int> streamingCounter;

  CounterService() {
    streamingCounter = Streaming(controllers: [_controller]);
  }

  Function(int) get counterSink => _controller.sink.add;

  dispose() {
    _controller.close();
    print("stream Controller is disposed");
  }
}
