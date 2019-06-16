import 'dart:async';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class StreamingCounterModel extends StatesRebuilder {
  final StreamController<int> _controller = StreamController();
  Streaming<int, int> _streamingCounter;

  StreamingCounterModel() {
    _streamingCounter = Streaming(controllers: [_controller]);
    _streamingCounter.addListener(this);
  }

  Function(int) get counterSink => _controller.sink.add;

  AsyncSnapshot<int> get snapshot => _streamingCounter.snapshots[0];

  increment() {
    counterSink((snapshot.data ?? 0) + 1);
  }

  dispose() {
    _controller.close();
    print("stream Controller is disposed");
  }
}
