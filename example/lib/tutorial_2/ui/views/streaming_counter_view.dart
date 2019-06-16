import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'package:states_rebuilder_demo/tutorial_2/logic/viewModels/streaming_counter_model.dart';

class StreamingCounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<StreamingCounterModel>(
      models: [() => StreamingCounterModel()],
      disposeModels: true,
      builder: (_, model) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (model.snapshot.hasData)
                Text("${model.snapshot.data}")
              else
                Text("no Data"),
              RaisedButton(
                child: Text("Increment"),
                onPressed: model.increment,
              ),
              Divider(),
              Expanded(
                child: Markdown(data: _firstExample),
              )
            ],
          ),
    );
  }
}

final String _firstExample = """
## streaming_counter_model.dart file:

class StreamingCounterModel extends StatesRebuilder {
  final StreamController<int> controller = StreamController(); // (1)
  __Streaming<int, int> streamingCounter;__ // (2)

  StreamingCounterModel() {
    __streamingCounter = Streaming(controllers: [_controller]);__ // (3)
    __streamingCounter.addListener(this);__ // (4)
  }

  Function(int) get counterSink => controller.sink.add; //(1)

  __AsyncSnapshot<int> get snapshot => streamingCounter.snapshots[0];__ // (5)

  increment() {
    __counterSink((snapshot.data ?? 0) + 1);__ // (6)
  }

  dispose() {
    controller.close();
    print("stream Controller is disposed");
  }
}

## streaming_counter_view.dart file:

class StreamingCounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<StreamingCounterModel>(
      models: [() => StreamingCounterModel()],
      disposeModels: true,
      builder: (_, model) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              __if (model.snapshot.hasData)__ // (7)
                __Text("\${model.snapshot.data}")__
              else
                Text("no Data"),
              RaisedButton(
                child: Text("Increment"),
                onPressed: model.increment,
              ),
            ],
          ),
    );
  }
}

- (1) : _Define two variables for StreamController and Sink._
- (2) : _Declare a variable `streamingCounter` of type `Streaming` to hold all streaming staff. The first type of the generic type is the type of the streams and snapshots, whereas the second type is for the snapshot of the resulted combination of streams.The tow types may differ. The second type, although defined, it is not used for this particular case._
- (3) : _`streamingCounter` is instantiated inside the constructor. This is the typical place. the `Streaming` class takes four arguments:_
        _1- `controllers`: It is a List of controllers. You can define as many controllers as you want._
        _2- `streams` : Instead of controllers you can define a List of streams. If can not defined both, you have to define either controllers or streams._
        _3- `initialData` : It is a list of initialData. The order is very important, and it must follows the same order of the controllers list. That is: the first element in initialData list is the initialData of the first element in the controllers list and so on. If you define only on initialData element then It will be applied to all controllers._
        _4- `transforms` : It is a list of transforms you want to apply to streams. Again the order is very important and if you define only one transform element it will be applied to all streams._
        _5- `combineFn` : If you define many streams or controllers, you have the ability to combine then to get a new type of stream.`combineFn` is a closure with a list of snapshots as argument. The order of the snapshots in the list follows the same order in the controllers or streams arguments._
- (4) : _`addListener` is used to link this `streamingCounter` object with this viewModel. Now each time the stream gets data the view class attached to the viewModel will rebuild. The benefic of this approach is that from one single subscription controller you can link many viewModels to the same `Streaming` object by calling `addListener` inside viewModels._
- (5) : _Define a snapshot getter. `streamingCounter` has three getters:
        _1- `snapshots` to get the snapshot of each controller or stream. It is a list of snapshots. The order is the same as in controllers list._
        _2- `snapshotMerged` to get the merged snapshot of all the provided controllers or streamers._
        _3- `snapshotCombined` to get the combined resulted snapshot of streams. the combination function is given by the `combineFn` argument. The combine snapshot can have different type then the original streams._
- (6) : _Add to the Sink of the StreamController._
- (7) : _In the UI you do not have to use `StreamBuilder`. Use the data form the snapshot of the model and this view will rebuild each time any of the streams emits a value._
""";
