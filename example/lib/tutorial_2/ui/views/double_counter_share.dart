import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder_demo/tutorial_2/logic/services/counter_service.dart';
import 'package:states_rebuilder_demo/tutorial_2/ui/views/counter1_share_view.dart';
import 'package:states_rebuilder_demo/tutorial_2/ui/views/counter2_share_view.dart';

class DoubleCounterShare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      models: [() => CounterService()],
      builder: (_, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("Go to counter 1"),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Counter1ShareView())),
              ),
              RaisedButton(
                child: Text("Go to counter 2"),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Counter2ShareView())),
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

In case you want many views (viewModels) to share the same value, you use what is called __services__.

__services__: are classes that hold data and methods to be shared between many viewModels. They should be small and with one single responsibility. They can not communicate directly with a view. They should do that through the corresponding viewModel. For this reason services must no extend `StatesRebuilder`

## counter_service.dart file:

class CounterService {
  final StreamController<int> _controller = StreamController();
  __Streaming<int, int> streamingCounter;__ // (1)

  CounterService() {
    __streamingCounter = Streaming(controllers: [_controller]);__ //(1)
  }

  Function(int) get counterSink => _controller.sink.add;

  dispose() {
    _controller.close();
    print("stream Controller is disposed");
  }
}



## double_counter_share.dart file:

class DoubleCounterShare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      __models: [() => CounterService()],__ // (2)
      builder: (_, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("Go to counter 1"),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Counter1ShareView())),
              ),
              RaisedButton(
                child: Text("Go to counter 2"),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Counter2ShareView())),
              ),
            ],
          ),
    );
  }
}

- (1) : _All what we want to do in service is to instantiate the `streamingCounter`. Any viewModel can access this class and register as listener using tha `addListener()` method and get snapshots._
- (2) : _Injector is used to register the `CounterService`. Now child widgets throw their viewModels can access to the registered instance._
""";
