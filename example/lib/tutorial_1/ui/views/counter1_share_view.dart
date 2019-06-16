import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:states_rebuilder_demo/tutorial_1/logic/viewModels/counter1_share_model.dart';

class Counter1ShareView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter1ShareModel>(
        models: [() => Counter1ShareModel()],
        builder: (context, Counter1ShareModel model) => Scaffold(
              appBar: AppBar(),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("${model.counter}"),
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
            ));
  }
}

final String _firstExample = """
## counter1_share_model.dart file:

class Counter1ShareModel extends StatesRebuilder {
  final counterService = Injector.get<CounterService>();// (1)
  int get counter => counterService.counter;

  increment() {
    counterService.increment();
    rebuildStates();
  }
}

## counter1_share_view.dart file:

class Counter1ShareView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<Counter1ShareModel>(
        models: [() => Counter1ShareModel()],
        builder: (context, Counter1ShareModel model) => Scaffold(
              appBar: AppBar(),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("\${model.counter}"),
                  RaisedButton(
                    child: Text("Increment"),
                    onPressed: model.increment,
                  ),
                ],
              ),
            ));
  }
}

- (1) : Get the registered instance of `CounterService`.
""";
