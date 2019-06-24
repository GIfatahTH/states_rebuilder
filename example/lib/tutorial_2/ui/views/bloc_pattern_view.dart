import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../logic/viewModels/bloc_pattern_model.dart';

class BlocPatternView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => BlocPatternModel()],
      disposeModels: true,
      builder: (_, __) {
        final model = Injector.get<BlocPatternModel>();
        return StreamBuilder<int>(
            stream: model.counterStream,
            builder: (context, snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (snapshot.hasData)
                    Text("${snapshot.data}")
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
              );
            });
      },
    );
  }
}

final String _firstExample = """
## bloc_pattern_model.dart file:

class BlocPatternModel {
  final StreamController<int> _controller = StreamController(); // (1)

  Function(int) get counterSink => _controller.sink.add; // (1)

  Stream<int> get counterStream => _controller.stream; // (1)

  int _counter;
  increment() {
    _counter = (_counter ?? 0) + 1;
    counterSink(_counter); // (2)
  }

  dispose() {
    _controller.close();
  }
}

## bloc_pattern_view.dart file:

class BlocPatternView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => BlocPatternModel()],
      disposeModels: true,
      builder: (_, __) {
        final model = Injector.get<BlocPatternModel>();
        return __StreamBuilder<int>(__ // (3)
           __ stream: model.counterStream,__
           __ builder: (context, snapshot) {__
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                 __ if (snapshot.hasData)__ //(4)
                    __Text("\${snapshot.data}")__
                  else
                    Text("no Data"),
                  RaisedButton(
                    child: Text("Increment"),
                    onPressed: model.increment,
                  ),
                ],
              );
            });
      },
    );
  }
}

- (1) : _Define three properties for StreamController, Sink and Stream._
- (2) : _When `increment()` method is invoked, the local `counter` variable in incremented and the new value is add to the Sink._
- (3) : _ `StreamBuilder` widget is used to consume the stream. the model class is provided using `Injector`._
- (4) : _We check if the snapshot has data and display the snapshot value._
""";
